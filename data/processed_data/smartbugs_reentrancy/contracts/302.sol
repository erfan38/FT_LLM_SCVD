

pragma solidity ^0.5.0;





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.0;









library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}



pragma solidity ^0.5.0;

contract DutchAuction is SignatureBouncer, Ownable {
    using SafeERC20 for ERC20Burnable;

    


    event BidSubmission(address indexed sender, uint256 amount);

    


    uint constant public WAITING_PERIOD = 0; 

    


    ERC20Burnable public token;
    address public ambix;
    address payable public wallet;
    uint public maxTokenSold;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;

    


    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    


    modifier atStage(Stages _stage) {
        
        require(stage == _stage);
        _;
    }

    modifier isValidPayload() {
        require(msg.data.length == 4 || msg.data.length == 164);
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

    


    
    
    
    
    
    constructor(address payable _wallet, uint _maxTokenSold, uint _ceiling, uint _priceFactor)
        public
    {
        require(_wallet != address(0) && _ceiling > 0 && _priceFactor > 0);

        wallet = _wallet;
        maxTokenSold = _maxTokenSold;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    
    
    
    function setup(ERC20Burnable _token, address _ambix)
        public
        onlyOwner
        atStage(Stages.AuctionDeployed)
    {
        
        require(_token != ERC20Burnable(0) && _ambix != address(0));

        token = _token;
        ambix = _ambix;

        
        require(token.balanceOf(address(this)) == maxTokenSold);

        stage = Stages.AuctionSetUp;
    }

    
    function startAuction()
        public
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

    
    
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

    
    
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

    
    
    function bid(bytes calldata signature)
        external
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        onlyValidSignature(signature)
        returns (uint amount)
    {
        require(msg.value > 0);
        amount = msg.value;

        address payable receiver = msg.sender;

        
        uint maxWei = maxTokenSold * calcTokenPrice() / 10**9 - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;

        
        if (amount > maxWei) {
            amount = maxWei;
            
            receiver.transfer(msg.value - amount);
        }

        
        (bool success,) = wallet.call.value(amount)("");
        require(success);

        bids[receiver] += amount;
        totalReceived += amount;
        emit BidSubmission(receiver, amount);

        
        if (amount == maxWei)
            finalizeAuction();
    }

    
    function claimTokens()
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        address receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**9 / finalPrice;
        bids[receiver] = 0;
        token.safeTransfer(receiver, tokenCount);
    }

    
    
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**9 / maxTokenSold + 1;
    }

    
    
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }

    


    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
        uint soldTokens = totalReceived * 10**9 / finalPrice;

        if (totalReceived == ceiling) {
            
            token.safeTransfer(ambix, maxTokenSold - soldTokens);
        } else {
            
            token.burn(maxTokenSold - soldTokens);
        }

        endTime = now;
    }
}



pragma solidity ^0.5.0;


library SharedCode {
    



    function proxy(address _shared) internal returns (address instance) {
        bytes memory code = abi.encodePacked(
            hex"603160008181600b9039f3600080808080368092803773",
            _shared, hex"5af43d828181803e808314603057f35bfd"
        );
        assembly {
            instance := create(0, add(code, 0x20), 60)
            if iszero(extcodesize(instance)) {
                revert(0, 0)
            }
        }
    }
}



pragma solidity ^0.5.0;



