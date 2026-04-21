pragma solidity >=0.4.4;

contract ICO is EventDefinitions, Testable, SafeMath, Owned {
    Token public token;
    address public controller;
    address public payee;

    Sale[] public sales;
    
    
    mapping (uint => uint) saleMinimumPurchases;

    
    mapping (address => uint) public nextClaim;

    
    mapping (address => uint) refundInStop;

    modifier tokenIsSet() {
        if (address(token) == 0) throw;
        _;
    }

    modifier onlyController() {
        if (msg.sender != address(controller)) throw;
        _;
    }

    function ICO() { 
        owner = msg.sender;
        payee = msg.sender;
        allStopper = msg.sender;
    }

    
    
    
    
    function changePayee(address newPayee) 
    onlyOwner notAllStopped {
        payee = newPayee;
    }

    function setToken(address _token) onlyOwner {
        if (address(token) != 0x0) throw;
        token = Token(_token);
    }

    
    
    function setAsTest() onlyOwner {
        if (sales.length == 0) {
            testing = true;
        }
    }

    function setController(address _controller) 
    onlyOwner notAllStopped {
        if (address(controller) != 0x0) throw;
        controller = _controller; 
    }

    
    
    

    function addSale(address sale, uint minimumPurchase) 
    onlyController notAllStopped {
        uint salenum = sales.length;
        sales.push(Sale(sale));
        saleMinimumPurchases[salenum] = minimumPurchase;
        logSaleStart(Sale(sale).startTime(), Sale(sale).stopTime());
    }

    function addSale(address sale) onlyController {
        addSale(sale, 0);
    }

    function getCurrSale() constant returns (uint) {
        if (sales.length == 0) throw; 
        return sales.length - 1;
    }

    function currSaleActive() constant returns (bool) {
        return sales[getCurrSale()].isActive(currTime());
    }

    function currSaleComplete() constant returns (bool) {
        return sales[getCurrSale()].isComplete(currTime());
    }

    function numSales() constant returns (uint) {
        return sales.length;
    }

    function numContributors(uint salenum) constant returns (uint) {
        return sales[salenum].numContributors();
    }

    
    
    

    event logPurchase(address indexed purchaser, uint value);

    function () payable {
        deposit();
    }

    function deposit() payable notAllStopped {
        doDeposit(msg.sender, msg.value);

        
        uint contrib = refundInStop[msg.sender];
        refundInStop[msg.sender] = contrib + msg.value;

        logPurchase(msg.sender, msg.value);
    }

    
    function doDeposit(address _for, uint _value) private {
        uint currSale = getCurrSale();
        if (!currSaleActive()) throw;
        if (_value < saleMinimumPurchases[currSale]) throw;

        uint tokensToMintNow = sales[currSale].buyTokens(_for, _value, currTime());

        if (tokensToMintNow > 0) {
            token.mint(_for, tokensToMintNow);
        }
    }

    
    
    

    
    
    
    
    
    

    event logPurchaseViaToken(
                        address indexed purchaser, address indexed token, 
                        uint depositedTokens, uint ethValue, 
                        bytes32 _reference);

    event logPurchaseViaFiat(
                        address indexed purchaser, uint ethValue, 
                        bytes32 _reference);

    mapping (bytes32 => bool) public mintRefs;
    mapping (address => uint) public raisedFromToken;
    uint public raisedFromFiat;

    function depositFiat(address _for, uint _ethValue, bytes32 _reference) 
    notAllStopped onlyOwner {
        if (getCurrSale() > 0) throw; 
        if (mintRefs[_reference]) throw; 
        mintRefs[_reference] = true;
        raisedFromFiat = safeAdd(raisedFromFiat, _ethValue);

        doDeposit(_for, _ethValue);
        logPurchaseViaFiat(_for, _ethValue, _reference);
    }

    function depositTokens(address _for, address _token, 
                           uint _ethValue, uint _depositedTokens, 
                           bytes32 _reference) 
    notAllStopped onlyOwner {
        if (getCurrSale() > 0) throw; 
        if (mintRefs[_reference]) throw; 
        mintRefs[_reference] = true;
        raisedFromToken[_token] = safeAdd(raisedFromToken[_token], _ethValue);

        
        
        uint tokensPerEth = sales[0].tokensPerEth();
        uint tkn = safeMul(_ethValue, tokensPerEth) / weiPerEth();
        token.mint(_for, tkn);
        
        logPurchaseViaToken(_for, _token, _depositedTokens, _ethValue, _reference);
    }

    
    
    
    
    
    function safebalance(uint bal) private returns (uint) {
        if (bal > this.balance) {
            return this.balance;
        } else {
            return bal;
        }
    }

    
    
    
    

    uint public topUpAmount;

    function topUp() payable onlyOwner notAllStopped {
        topUpAmount = safeAdd(topUpAmount, msg.value);
    }

    function withdrawTopUp() onlyOwner notAllStopped {
        uint amount = topUpAmount;
        topUpAmount = 0;
        if (!msg.sender.call.value(safebalance(amount))()) throw;
    }

    
    
    

    
    
    
    
    function claim() notAllStopped {
        var (tokens, refund, nc) = claimable(msg.sender, true);
        nextClaim[msg.sender] = nc;
        logClaim(msg.sender, refund, tokens);
        if (tokens > 0) {
            token.mint(msg.sender, tokens);
        }
        if (refund > 0) {
            refundInStop[msg.sender] = safeSub(refundInStop[msg.sender], refund);
            if (!msg.sender.send(safebalance(refund))) throw;
        }
    }

    
    
    
    
    
    
    
    function claimFor(address _from, address _to) 
    onlyOwner notAllStopped {
        var (tokens, refund, nc) = claimable(_from, false);
        nextClaim[_from] = nc;

        logClaim(_from, refund, tokens);

        if (tokens > 0) {
            token.mint(_to, tokens);
        }
        if (refund > 0) {
            refundInStop[_from] = safeSub(refundInStop[_from], refund);
            if (!_to.send(safebalance(refund))) throw;
        }
    }

    function claimable(address _a, bool _includeRecent) 
    constant private tokenIsSet 
    returns (uint tokens, uint refund, uint nc) {
        nc = nextClaim[_a];

        while (nc < sales.length &&
               sales[nc].isComplete(currTime()) &&
               ( _includeRecent || 
                 sales[nc].stopTime() + 1 years < currTime() )) 
        {
            refund = safeAdd(refund, sales[nc].getRefund(_a));
            tokens = safeAdd(tokens, sales[nc].getTokens(_a));
            nc += 1;
        }
    }

    function claimableTokens(address a) constant returns (uint) {
        var (tokens, refund, nc) = claimable(a, true);
        return tokens;
    }

    function claimableRefund(address a) constant returns (uint) {
        var (tokens, refund, nc) = claimable(a, true);
        return refund;
    }

    function claimableTokens() constant returns (uint) {
        return claimableTokens(msg.sender);
    }

    function claimableRefund() constant returns (uint) {
        return claimableRefund(msg.sender);
    }

    
    
    

    mapping (uint => bool) ownerClaimed;

    function claimableOwnerEth(uint salenum) constant returns (uint) {
        uint time = currTime();
        if (!sales[salenum].isComplete(time)) return 0;
        return sales[salenum].getOwnerEth();
    }

    function claimOwnerEth(uint salenum) onlyOwner notAllStopped {
        if (ownerClaimed[salenum]) throw;

        uint ownereth = claimableOwnerEth(salenum);
        if (ownereth > 0) {
            ownerClaimed[salenum] = true;
            if ( !payee.call.value(safebalance(ownereth))() ) throw;
        }
    }

    
    
    

    
    

    event logTokenTransfer(address token, address to, uint amount);

    function transferTokens(address _token, address _to) onlyOwner {
        Token token = Token(_token);
        uint balance = token.balanceOf(this);
        token.transfer(_to, balance);
        logTokenTransfer(_token, _to, balance);
    }

    
    
    

    bool allstopped;
    bool permastopped;

    
    
    address allStopper;
    function setAllStopper(address _a) onlyOwner {
        if (allStopper != owner) return;
        allStopper = _a;
    }
    modifier onlyAllStopper() {
        if (msg.sender != allStopper) throw;
        _;
    }

    event logAllStop();
    event logAllStart();

    modifier allStopped() {
        if (!allstopped) throw;
        _;
    }

    modifier notAllStopped() {
        if (allstopped) throw;
        _;
    }

    function allStop() onlyAllStopper {
        allstopped = true;    
        logAllStop();
    }

    function allStart() onlyAllStopper {
        if (!permastopped) {
            allstopped = false;
            logAllStart();
        }
    }

    function emergencyRefund(address _a, uint _amt) 
    allStopped 
    onlyAllStopper {
        
        
        permastopped = true;

        uint amt = _amt;

        uint ethbal = refundInStop[_a];

        
        
        if (amt == 0) amt = ethbal; 

        
        if (amt > ethbal) amt = ethbal;

        
        
        if ( !_a.call.value(safebalance(amt))() ) throw;
    }

    function raised() constant returns (uint) {
        return sales[getCurrSale()].raised();
    }

    function tokensPerEth() constant returns (uint) {
        return sales[getCurrSale()].tokensPerEth();
    }
}