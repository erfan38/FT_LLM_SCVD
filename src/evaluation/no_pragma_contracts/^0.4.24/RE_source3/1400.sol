contract Bakt is BaktInterface
{
    bytes32 constant public VERSION = "Bakt 0.3.4-beta";

//
// Bakt Functions
//

    // SandalStraps compliant constructor
    function Bakt(address _creator, bytes32 _regName, address _trustee)
    {
        regName = _regName;
        trustee = _trustee != 0x0 ? _trustee : 
                _creator != 0x0 ? _creator : msg.sender;
        join(trustee);
    }

    // Accept payment to the default function on the condition that
    // `acceptingPayments` is true
    function()
        payable
    {
        require(msg.value > 0 &&
            msg.value + this.balance < MAXETHER &&
            acceptingPayments);
        Deposit(msg.value);
    }

    // Destructor
    // Selfdestructs on the condition that `totalSupply` and `committedEther`
    // are 0
    function destroy()
        public
        canEnter
        onlyTrustee
    {
        require(totalSupply == 0 && committedEther == 0);
        
        delete holders[trustee];
        selfdestruct(msg.sender);
    }

    // One Time Programable shot to set the panic and pending periods.
    // 86400 == 1 day
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

    // Returns calculated fund balance
    function fundBalance()
        public
        constant
        returns (uint)
    {
        return this.balance - committedEther;
    }

    // Returns token price constant
    function tokenPrice()
        public
        constant
        returns (uint)
    {
        return TOKENPRICE;
    }

    // `RegBase` compliant `changeResource()` to restrict caller to
    // `trustee` rather than `owner`
    function changeResource(bytes32 _resource)
        public
        canEnter
        onlyTrustee
        returns (bool)
    {
        resource = _resource;
        return true;
    }

//
// ERC20 API functions
//

    // Returns holder token balance
    function balanceOf(address _addr) 
        public
        constant
        returns (uint)
    {
        return holders[_addr].tokenBalance;
    }

    // To transfer tokens
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

    // To transfer tokens by proxy
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

    // To approve a proxy for token transfers
    function approve(address _spender, uint256 _amount)
        public
        canEnter
        returns (bool)
    {
        holders[msg.sender].allowances[_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Return the alloance of a proxy
    function allowance(address _owner, address _spender)
        constant
        returns (uint256)
    {
        return holders[_owner].allowances[_spender];
    }

    // Processes token transfers and subsequent change in voting power
    function xfer(Holder storage _from, Holder storage _to, uint _amount)
        internal
        returns (bool)
    {
        // Ensure dividends are up to date at current balances
        updateDividendsFor(_from);
        updateDividendsFor(_to);

        // Remove existing votes
        revoke(_from);
        revoke(_to);

        // Transfer tokens
        _from.tokenBalance -= _amount;
        _to.tokenBalance += _amount;

        // Revote accoring to changed token balances
        revote(_from);
        revote(_to);

        // Force election
        election();
        return true;
    }

//
// Security Functions
//

    // Cause the 