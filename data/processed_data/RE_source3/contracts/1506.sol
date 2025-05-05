contract ITT is ERC20Token, ITTInterface
{

/* Structs */

/* Modifiers */

    /// @dev Passes if token is currently trading
    modifier isTrading() {
        if (!trading) throw;
        _;
    }

    /// @dev Validate buy parameters
    modifier isValidBuy(uint _bidPrice, uint _amount) {
        if ((etherBalance[msg.sender] + msg.value) < (_amount * _bidPrice) ||
            _amount == 0 || _amount > totalSupply ||
            _bidPrice <= MINPRICE || _bidPrice >= MAXNUM) throw; // has insufficient ether.
        _;
    }

    /// @dev Validates sell parameters. Price must be larger than 1.
    modifier isValidSell(uint _askPrice, uint _amount) {
        if (_amount > balance[msg.sender] || _amount == 0 ||
            _askPrice < MINPRICE || _askPrice > MAXNUM) throw;
        _;
    }
    
    /// @dev Validates ether balance
    modifier hasEther(address _member, uint _ether) {
        if (etherBalance[_member] < _ether) throw;
        _;
    }

    /// @dev Validates token balance
    modifier hasBalance(address _member, uint _amount) {
        if (balance[_member] < _amount) throw;
        _;
    }

/* Functions */

    function ITT(
        uint _totalSupply,
        uint8 _decimalPlaces,
        string _symbol,
        string _name
        )
            ERC20Token(
                _totalSupply,
                _decimalPlaces,
                _symbol,
                _name
                )
    {
        // setup pricebook and maximum spread.
        priceBook.cll[HEAD][PREV] = MINPRICE;
        priceBook.cll[MINPRICE][PREV] = MAXNUM;
        priceBook.cll[HEAD][NEXT] = MAXNUM;
        priceBook.cll[MAXNUM][NEXT] = MINPRICE;
        trading = true;
        balance[owner] = totalSupply;
    }

/* Functions Getters */

    function version() public constant returns(string) {
        return VERSION;
    }

    function etherBalanceOf(address _addr) public constant returns (uint) {
        return etherBalance[_addr];
    }

    function spread(bool _side) public constant returns(uint) {
        return priceBook.step(HEAD, _side);
    }

    function getAmount(uint _price, address _trader) 
        public constant returns(uint) {
        return amounts[sha3(_price, _trader)];
    }

    function sizeOf(uint l) constant returns (uint s) {
        if(l == 0) return priceBook.sizeOf();
        return orderFIFOs[l].sizeOf();
    }
    
    function getPriceVolume(uint _price) public constant returns (uint v_)
    {
        uint n = orderFIFOs[_price].step(HEAD,NEXT);
        while (n != HEAD) { 
            v_ += amounts[sha3(_price, address(n))];
            n = orderFIFOs[_price].step(n, NEXT);
        }
        return;
    }

    function getBook() public constant returns (uint[])
    {
        uint i; 
        uint p = priceBook.step(MINNUM, NEXT);
        uint[] memory volumes = new uint[](priceBook.sizeOf() * 2 - 2);
        while (p < MAXNUM) {
            volumes[i++] = p;
            volumes[i++] = getPriceVolume(p);
            p = priceBook.step(p, NEXT);
        }
        return volumes; 
    }
    
    function numOrdersOf(address _addr) public constant returns (uint)
    {
        uint c;
        uint p = MINNUM;
        while (p < MAXNUM) {
            if (amounts[sha3(p, _addr)] > 0) c++;
            p = priceBook.step(p, NEXT);
        }
        return c;
    }
    
    function getOpenOrdersOf(address _addr) public constant returns (uint[])
    {
        uint i;
        uint c;
        uint p = MINNUM;
        uint[] memory open = new uint[](numOrdersOf(_addr)*2);
        p = MINNUM;
        while (p < MAXNUM) {
            if (amounts[sha3(p, _addr)] > 0) {
                open[i++] = p;
                open[i++] = amounts[sha3(p, _addr)];
            }
            p = priceBook.step(p, NEXT);
        }
        return open;
    }

    function getNode(uint _list, uint _node) public constant returns(uint[2])
    {
        return [orderFIFOs[_list].cll[_node][PREV], 
            orderFIFOs[_list].cll[_node][NEXT]];
    }
    
/* Functions Public */

// Here non-constant public functions act as a security layer. They are re-entry
// protected so cannot call each other. For this reason, they
// are being used for parameter and enterance validation, while internal
// functions manage the logic. This also allows for deriving contracts to
// overload the public function with customised validations and not have to
// worry about rewritting the logic.

    function buy (uint _bidPrice, uint _amount, bool _make)
        payable
        canEnter
        isTrading
        isValidBuy(_bidPrice, _amount)
        returns (bool)
    {
        trade(_bidPrice, _amount, BID, _make);
        return true;
    }

    function sell (uint _askPrice, uint _amount, bool _make)
        external
        canEnter
        isTrading
        isValidSell(_askPrice, _amount)
        returns (bool)
    {
        trade(_askPrice, _amount, ASK, _make);
        return true;
    }

    function withdraw(uint _ether)
        external
        canEnter
        hasEther(msg.sender, _ether)
        returns (bool success_)
    {
        etherBalance[msg.sender] -= _ether;
        safeSend(msg.sender, _ether);
        success_ = true;
    }

    function cancel(uint _price)
        external
        canEnter
        returns (bool)
    {
        TradeMessage memory tmsg;
        tmsg.price = _price;
        tmsg.balance = balance[msg.sender];
        tmsg.etherBalance = etherBalance[msg.sender];
        cancelIntl(tmsg);
        balance[msg.sender] = tmsg.balance;
        etherBalance[msg.sender] = tmsg.etherBalance;
        return true;
    }
    
    function setTrading(bool _trading)
        external
        onlyOwner
        canEnter
        returns (bool)
    {
        trading = _trading;
        Trading(true);
        return true;
    }

/* Functions Internal */

// Internal functions handle this contract's logic.

    function trade (uint _price, uint _amount, bool _side, bool _make) internal {
        TradeMessage memory tmsg;
        tmsg.price = _price;
        tmsg.tradeAmount = _amount;
        tmsg.side = _side;
        tmsg.make = _make;
        
        // Cache state balances to memory and commit to storage only once after trade.
        tmsg.balance  = balance[msg.sender];
        tmsg.etherBalance = etherBalance[msg.sender] + msg.value;

        take(tmsg);
        make(tmsg);
        
        balance[msg.sender] = tmsg.balance;
        etherBalance[msg.sender] = tmsg.etherBalance;
    }
    
    function take (TradeMessage tmsg)
        internal
    {
        address maker;
        bytes32 orderHash;
        uint takeAmount;
        uint takeEther;
        // use of signed math on unsigned ints is intentional
        uint sign = tmsg.side ? uint(1) : uint(-1);
        uint bestPrice = spread(!tmsg.side);

        // Loop with available gas to take orders
        while (
            tmsg.tradeAmount > 0 &&
            cmpEq(tmsg.price, bestPrice, !tmsg.side) && 
            msg.gas > MINGAS
        )
        {
            maker = address(orderFIFOs[bestPrice].step(HEAD, NEXT));
            orderHash = sha3(bestPrice, maker);
            if (tmsg.tradeAmount < amounts[orderHash]) {
                // Prepare to take partial order
                amounts[orderHash] = safeSub(amounts[orderHash], tmsg.tradeAmount);
                takeAmount = tmsg.tradeAmount;
                tmsg.tradeAmount = 0;
            } else {
                // Prepare to take full order
                takeAmount = amounts[orderHash];
                tmsg.tradeAmount = safeSub(tmsg.tradeAmount, takeAmount);
                closeOrder(bestPrice, maker);
            }
            takeEther = safeMul(bestPrice, takeAmount);
            // signed multiply on uints is intentional and so safeMaths will 
            // break here. Valid range for exit balances are 0..2**128 
            tmsg.etherBalance += takeEther * sign;
            tmsg.balance -= takeAmount * sign;
            if (tmsg.side) {
                // Sell to bidder
                if (msg.sender == maker) {
                    // bidder is self
                    tmsg.balance += takeAmount;
                } else {
                    balance[maker] += takeAmount;
                }
            } else {
                // Buy from asker;
                if (msg.sender == maker) {
                    // asker is self
                    tmsg.etherBalance += takeEther;
                } else {                
                    etherBalance[maker] += takeEther;
                }
            }
            // prep for next order
            bestPrice = spread(!tmsg.side);
            Sale (bestPrice, takeAmount, msg.sender, maker);
        }
    }

    function make(TradeMessage tmsg)
        internal
    {
        bytes32 orderHash;
        if (tmsg.tradeAmount == 0 || !tmsg.make || msg.gas < MINGAS) return;
        orderHash = sha3(tmsg.price, msg.sender);
        if (amounts[orderHash] != 0) {
            // Cancel any pre-existing owned order at this price
            cancelIntl(tmsg);
        }
        if (!orderFIFOs[tmsg.price].exists()) {
            // Register price in pricebook
            priceBook.insert(
                priceBook.seek(HEAD, tmsg.price, tmsg.side),
                tmsg.price, !tmsg.side);
        }

        amounts[orderHash] = tmsg.tradeAmount;
        orderFIFOs[tmsg.price].push(uint(msg.sender), PREV); 

        if (tmsg.side) {
            tmsg.balance -= tmsg.tradeAmount;
            Ask (tmsg.price, tmsg.tradeAmount, msg.sender);
        } else {
            tmsg.etherBalance -= tmsg.tradeAmount * tmsg.price;
            Bid (tmsg.price, tmsg.tradeAmount, msg.sender);
        }
    }

    function cancelIntl(TradeMessage tmsg) internal {
        uint amount = amounts[sha3(tmsg.price, msg.sender)];
        if (amount == 0) return;
        if (tmsg.price > spread(BID)) tmsg.balance += amount; // was ask
        else tmsg.etherBalance += tmsg.price * amount; // was bid
        closeOrder(tmsg.price, msg.sender);
    }

    function closeOrder(uint _price, address _trader) internal {
        orderFIFOs[_price].remove(uint(_trader));
        if (!orderFIFOs[_price].exists())  {
            priceBook.remove(_price);
        }
        delete amounts[sha3(_price, _trader)];
    }
}