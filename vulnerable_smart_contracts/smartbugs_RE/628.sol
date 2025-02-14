
























pragma solidity ^0.4.10;

contract Bakt is BaktInterface
{
    bytes32 constant public VERSION = "Bakt 0.3.4-beta";





    
    function Bakt(address _creator, bytes32 _regName, address _trustee)
    {
        regName = _regName;
        trustee = _trustee != 0x0 ? _trustee : 
                _creator != 0x0 ? _creator : msg.sender;
        join(trustee);
    }

    
    
    function()
        payable
    {
        require(msg.value > 0 &&
            msg.value + this.balance < MAXETHER &&
            acceptingPayments);
        Deposit(msg.value);
    }

    
    
    
    function destroy()
        public
        canEnter
        onlyTrustee
    {
        require(totalSupply == 0 && committedEther == 0);
        
        delete holders[trustee];
        selfdestruct(msg.sender);
    }

    
    
    function _init(uint40 _panicPeriodInSeconds, uint40 _pendingPeriodInSeconds)
        onlyTrustee
        returns (bool)
    {
        require(__initFuse);
        PANICPERIOD = _panicPeriodInSeconds;
        TXDELAY = _pendingPeriodInSeconds;
        acceptingPayments = true;
        delete __initFuse;
        return true;
    }

    
    function fundBalance()
        public
        constant
        returns (uint)
    {
        return this.balance - committedEther;
    }

    
    function tokenPrice()
        public
        constant
        returns (uint)
    {
        return TOKENPRICE;
    }

    
    
    function changeResource(bytes32 _resource)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        resource = _resource;
        return true;
    }





    
    function balanceOf(address _addr) 
        public
        constant
        returns (uint)
    {
        return holders[_addr].tokenBalance;
    }

    
    function transfer(address _to, uint _amount)
        public
        canEnter
        isHolder(_to)
        returns (bool)
    {
        Holder from = holders[msg.sender];
        Holder to = holders[_to];

        Transfer(msg.sender, _to, _amount);
        return xfer(from, to, _amount);
    }

    
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        canEnter
        isHolder(_to)
        returns (bool)
    {
        require(_amount <= holders[_from].allowances[msg.sender]);
        
        Holder from = holders[_from];
        Holder to = holders[_to];

        from.allowances[msg.sender] -= _amount;
        Transfer(_from, _to, _amount);
        return xfer(from, to, _amount);
    }

    
    function approve(address _spender, uint256 _amount)
        public
        canEnter
        returns (bool)
    {
        holders[msg.sender].allowances[_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    function allowance(address _owner, address _spender)
        constant
        returns (uint256)
    {
        return holders[_owner].allowances[_spender];
    }

    
    function xfer(Holder storage _from, Holder storage _to, uint _amount)
        internal
        returns (bool)
    {
        
        updateDividendsFor(_from);
        updateDividendsFor(_to);

        
        revoke(_from);
        revoke(_to);

        
        _from.tokenBalance -= _amount;
        _to.tokenBalance += _amount;

        
        revote(_from);
        revote(_to);

        
        election();
        return true;
    }





    
    
    function PANIC()
        public
        isHolder(msg.sender)
        returns (bool)
    {
        
        require(holders[msg.sender].tokenBalance >= totalSupply / 10);
        
        panicked = true;
        timeToCalm = uint40(now + PANICPERIOD);
        Panicked(msg.sender);
        return true;
    }

    
    function calm()
        public
        isHolder(msg.sender)
        returns (bool)
    {
        require(uint40(now) > timeToCalm && panicked);
        
        panicked = false;
        Calm();
        return true;
    }

    
    function timeLockSend(address _from, address _to, uint _value, bytes _data)
        internal
        returns (uint8)
    {
        
        require(ptxHead + 1 != ptxTail);

        TX memory tx = TX({
            from: _from,
            to: _to,
            value: _value,
            data: _data,
            blocked: false,
            timeLock: uint40(now + TXDELAY)
        });
        TransactionPending(ptxHead, _from, _to, _value, now + TXDELAY);
        pendingTxs[ptxHead++] = tx;
        return  ptxHead - 1;
    }

    
    
    function sendPending()
        public
        preventReentry
        isHolder(msg.sender)
        returns (bool)
    {
        if (ptxTail == ptxHead) return false; 
        
        TX memory tx = pendingTxs[ptxTail];
        if(now < tx.timeLock) return false;
        
        
        
        delete pendingTxs[ptxTail++];
        
        if(!tx.blocked) {
            if(tx.to.call.value(tx.value)(tx.data)) {
                
                committedEther -= tx.value;
                
                Withdrawal(tx.from, tx.to, tx.value);
                return true;
            }
        }
        
        
        
        if (tx.from == address(this)) {
            
            committedEther -= tx.value;
        } else {
            
            holders[tx.from].etherBalance += tx.value;
        }
        
        TransactionFailed(tx.from, tx.to, tx.value);
        return false;
    }

    
    function blockPendingTx(uint _txIdx)
        public
        returns (bool)
    {
        
        require(!__reMutex);
        
        
        
        require(holders[msg.sender].tokenBalance >= totalSupply / BLOCKPCNT ||
            msg.sender == pendingTxs[ptxTail].from ||
            msg.sender == trustee);
        
        pendingTxs[_txIdx].blocked = true;
        TransactionBlocked(msg.sender, _txIdx);
        return true;
    }





    
    
    function execute(address _to, uint _value, bytes _data)
        public
        canEnter
        onlyTrustee
        returns (uint8)
    {
        require(_value <= fundBalance());

        committedEther += _value;
        return timeLockSend(address(this), _to, _value, _data);
    }

    
    function payDividends(uint _value)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        require(_value <= fundBalance());
        
        
        dividendPoints += 10**18 * _value / totalSupply;
        totalDividends += _value;
        committedEther += _value;
        return true;
    }
    
    
    function addHolder(address _addr)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        return join(_addr);
    }

    
    function join(address _addr)
        internal
        returns (bool)
    {
        if(0 != holders[_addr].id) return true;
        
        require(_addr != address(this));
        
        uint8 id;
        
        while (holderIndex[++id] != 0) {}
        
        
        if(id == 0) revert();
        
        Holder holder = holders[_addr];
        holder.id = id;
        holder.lastClaimed = dividendPoints;
        holder.votingFor = trustee;
        holderIndex[id] = _addr;
        NewHolder(_addr);
        return true;
    }

    
    function acceptPayments(bool _accepting)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        acceptingPayments = _accepting;
        return true;
    }

    
    function issue(address _addr, uint _amount)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        
        assert(totalSupply + _amount < MAXTOKENS);
        
        join(_addr);
        Holder holder = holders[_addr];
        holder.offerAmount = _amount;
        holder.offerExpiry = uint40(now + 7 days);
        IssueOffer(_addr);
        return true;
    }

    
    function revokeOffer(address _addr)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        Holder holder = holders[_addr];
        delete holder.offerAmount;
        delete holder.offerExpiry;
        return true;
    }





    
    function getHolders()
        public
        constant
        returns(address[256])
    {
        return holderIndex;
    }

    
    function etherBalanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        Holder holder = holders[_addr];
        return holder.etherBalance + dividendsOwing(holder);
    }

    
    function withdraw()
        public
        canEnter
        returns(uint8 pTxId_)
    {
        Holder holder = holders[msg.sender];
        updateDividendsFor(holder);
        
        pTxId_ = timeLockSend(msg.sender, msg.sender, holder.etherBalance, "");
        holder.etherBalance = 0;
    }

    
    function vacate(address _addr)
        public
        canEnter
        isHolder(msg.sender)
        isHolder(_addr)
        returns (bool)
    {
        Holder holder = holders[_addr];
        
        
        require(_addr != trustee);
        require(holder.tokenBalance == 0);
        require(holder.etherBalance == 0);
        require(holder.lastClaimed == dividendPoints);
        require(ptxHead == ptxTail);
        
        delete holderIndex[holder.id];
        delete holders[_addr];
        
        return (true);
    }





    
    function purchase()
        payable
        canEnter
        returns (bool)
    {
        Holder holder = holders[msg.sender];
        
        require(holder.offerAmount > 0);
        
        require(holder.offerExpiry > now);
        
        require(msg.value == holder.offerAmount * TOKENPRICE);
        
        updateDividendsFor(holder);
                
        revoke(holder);
                
        totalSupply += holder.offerAmount;
        holder.tokenBalance += holder.offerAmount;
        TokensCreated(msg.sender, holder.offerAmount);
        
        delete holder.offerAmount;
        delete holder.offerExpiry;
        
        revote(holder);
        election();
        return true;
    }

    
    
    function redeem(uint _amount)
        public
        canEnter
        isHolder(msg.sender)
        returns (bool)
    {
        uint redeemPrice;
        uint eth;
        
        Holder holder = holders[msg.sender];
        require(_amount <= holder.tokenBalance);
        
        updateDividendsFor(holder);
        
        revoke(holder);
        
        redeemPrice = fundBalance() / totalSupply;
        
        
        redeemPrice = redeemPrice < TOKENPRICE ? redeemPrice : TOKENPRICE;
        
        eth = _amount * redeemPrice;
        
        
        require(eth > 0);
        
        totalSupply -= _amount;
        holder.tokenBalance -= _amount;
        holder.etherBalance += eth;
        committedEther += eth;
        
        TokensDestroyed(msg.sender, _amount);
        revote(holder);
        election();
        return true;
    }





    function dividendsOwing(Holder storage _holder)
        internal
        constant
        returns (uint _value)
    {
        
        return (dividendPoints - _holder.lastClaimed) * _holder.tokenBalance/
            10**18;
    }
    
    function updateDividendsFor(Holder storage _holder)
        internal
    {
        _holder.etherBalance += dividendsOwing(_holder);
        _holder.lastClaimed = dividendPoints;
    }





    
    function vote(address _candidate)
        public
        isHolder(msg.sender)
        isHolder(_candidate)
        returns (bool)
    {
        
        require(!__reMutex);
        
        Holder holder = holders[msg.sender];
        revoke(holder);
        holder.votingFor = _candidate;
        revote(holder);
        election();
        return true;
    }

    
    
    function election()
        internal
    {
        uint max;
        uint winner;
        uint votes;
        uint8 i;
        address addr;
        
        if (0 == totalSupply) return;
        
        while(++i != 0)
        {
            addr = holderIndex[i];
            if (addr != 0x0) {
                votes = holders[addr].votes;
                if (votes > max) {
                    max = votes;
                    winner = i;
                }
            }
        }
        trustee = holderIndex[winner];
        Trustee(trustee);
    }

    
    
    function revoke(Holder _holder)
        internal
    {
        holders[_holder.votingFor].votes -= _holder.tokenBalance;
    }

    
    
    function revote(Holder _holder)
        internal
    {
        holders[_holder.votingFor].votes += _holder.tokenBalance;
    }





    
    modifier preventReentry() {
        require(!(__reMutex || panicked || __initFuse));
        __reMutex = true;
        _;
        __reMutex = false;
        return;
    }

    
    modifier canEnter() {
        require(!(__reMutex || panicked || __initFuse));
        _;
    }

    
    modifier isHolder(address _addr) {
        require(0 != holders[_addr].id);
        _;
    }

    
    modifier onlyTrustee() {
        require(msg.sender == trustee);
        _;
    }
}


