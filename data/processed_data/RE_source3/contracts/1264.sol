contract TradersWallet {
    
    address public owner;
    string public version;
    etherDelta private ethDelta;
    address public ethDeltaDepositAddress;
    
    // init the TradersWallet()
    function TradersWallet() {
        owner = msg.sender;
        version = "ALPHA 0.1";
        ethDeltaDepositAddress = 0x8d12A197cB00D4747a1fe03395095ce2A5CC6819;
        ethDelta = etherDelta(ethDeltaDepositAddress);
    }
    
    // default function
    function() payable {
        
    }
    
    // standard erc20 token balance in wallet from specific token address
    function tokenBalance(address tokenAddress) constant returns (uint) {
        Token token = Token(tokenAddress);
        return token.balanceOf(this);
    }
    
    // standard erc20 transferFrom function
    function transferFromToken(address tokenAddress, address sendTo, address sendFrom, uint256 amount) external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.transferFrom(sendTo, sendFrom, amount);
    }
    
    // change owner this this trader wallet
    function changeOwner(address newOwner) external {
        require(msg.sender==owner);
        owner = newOwner;
    }
    
    // send ether to another wallet
    function sendEther(address toAddress, uint amount) external {
        require(msg.sender==owner);
        toAddress.transfer(amount);
    }
    
    // standard erc20 transfer/send function
    function sendToken(address tokenAddress, address sendTo, uint256 amount) external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.transfer(sendTo, amount);
    }
    
    // let the owner execute with data
    function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r) {
        require(msg.sender==owner);
        require(_to.call.value(_value)(_data));
        return 0;
    }
    
    // get ether delta token balance from token address
    function EtherDeltaTokenBalance(address tokenAddress) constant returns (uint) {
        return ethDelta.balanceOf(tokenAddress, this);
    }
    
    // withdraw a token from etherdelta
    function EtherDeltaWithdrawToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.withdrawToken(tokenAddress, amount);
    }
    
    // change etherdelta exchange address
    function changeEtherDeltaDeposit(address newEthDelta) external {
        require(msg.sender==owner);
        ethDeltaDepositAddress = newEthDelta;
        ethDelta = etherDelta(newEthDelta);
    }
    
    // deposit tokens to etherdelta
    function EtherDeltaDepositToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.depositToken(tokenAddress, amount);
    }
    
    // approve etherdelta to take take a specific amount
    function EtherDeltaApproveToken(address tokenAddress, uint amount) payable external {
        require(msg.sender==owner);
        Token token = Token(tokenAddress);
        token.approve(ethDeltaDepositAddress, amount);
    }
    
    // deposit ether to etherdelta
    function EtherDeltaDeposit(uint amount) payable external {
        require(msg.sender==owner);
        ethDelta.deposit.value(amount)();
    }
    
    // withdraw ether from etherdelta
    function EtherDeltaWithdraw(uint amount) external {
        require(msg.sender==owner);
        ethDelta.withdraw(amount);
    }
    
    // destroy this wallet and send all ether to sender
    // THIS DOES NOT INCLUDE ERC20 TOKENS
    function kill() {
        require(msg.sender==owner);
        suicide(msg.sender);
    }
    
}