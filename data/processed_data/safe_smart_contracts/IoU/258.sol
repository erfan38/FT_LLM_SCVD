contract SyncoToken is ERC20, Ownable, Pausable {

    using SafeMath for uint256;

    struct LockupInfo {
        uint256 releaseTime;
        uint256 termOfRound;
        uint256 unlockAmountPerRound;        
        uint256 lockupBalance;
    }

    string public name;
    string public symbol;
    uint8 constant public decimals =18;
    uint256 internal initialSupply;
    uint256 internal totalSupply_;

    mapping(address => uint256) internal balances;
    mapping(address => bool) internal locks;
    mapping(address => bool) public frozen;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => LockupInfo[]) internal lockupInfo;

    event Lock(address indexed holder, uint256 value);
    event Unlock(address indexed holder, uint256 value);
    event Burn(address indexed owner, uint256 value);
    event Mint(uint256 value);
    event Freeze(address indexed holder);
    event Unfreeze(address indexed holder);

    modifier notFrozen(address _holder) {
        require(!frozen[_holder]);
        _;
    }

    constructor() public {
        name = "SYNCO Token";
        symbol = "SYNCO";
        initialSupply = 13000000000;
        totalSupply_ = initialSupply * 10 ** uint(decimals);
        balances[owner] = totalSupply_;
        emit Transfer(address(0), owner, totalSupply_);
    }

    function () public payable {
        revert();
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused notFrozen(msg.sender) returns (bool) {
        if (locks[msg.sender]) {
            autoUnlock(msg.sender);            
        }
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        

        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _holder) public view returns (uint256 balance) {
        uint256 lockedBalance = 0;
        if(locks[_holder]) {
            for(uint256 idx = 0; idx < lockupInfo[_holder].length ; idx++ ) {
                lockedBalance = lockedBalance.add(lockupInfo[_holder][idx].lockupBalance);
            }
        }
        return balances[_holder] + lockedBalance;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notFrozen(_from)returns (bool) {
        if (locks[_from]) {
            autoUnlock(_from);            
        }
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        require(isContract(_spender));
        TokenRecipient spender = TokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function allowance(address _holder, address _spender) public view returns (uint256) {
        return allowed[_holder][_spender];
    }

    function lock(address _holder, uint256 _amount, uint256 _releaseStart, uint256 _termOfRound, uint256 _releaseRate) public onlyOwner returns (bool) {
        require(balances[_holder] >= _amount);
        if(_termOfRound==0 ) {
            _termOfRound = 1;
        }
        balances[_holder] = balances[_holder].sub(_amount);
        lockupInfo[_holder].push(
            LockupInfo(_releaseStart, _termOfRound, _amount.div(100).mul(_releaseRate), _amount)
        );

        locks[_holder] = true;

        emit Lock(_holder, _amount);

        return true;
    }

    function unlock(address _holder, uint256 _idx) public onlyOwner returns (bool) {
        require(locks[_holder]);
        require(_idx < lockupInfo[_holder].length);
        LockupInfo storage lockupinfo = lockupInfo[_holder][_idx];
        uint256 releaseAmount = lockupinfo.lockupBalance;

        delete lockupInfo[_holder][_idx];
        lockupInfo[_holder][_idx] = lockupInfo[_holder][lockupInfo[_holder].length.sub(1)];
        lockupInfo[_holder].length -=1;
        if(lockupInfo[_holder].length == 0) {
            locks[_holder] = false;
        }

        emit Unlock(_holder, releaseAmount);
        balances[_holder] = balances[_holder].add(releaseAmount);

        return true;
    }

    function freezeAccount(address _holder) public onlyOwner returns (bool) {
        require(!frozen[_holder]);
        frozen[_holder] = true;
        emit Freeze(_holder);
        return true;
    }

    function unfreezeAccount(address _holder) public onlyOwner returns (bool) {
        require(frozen[_holder]);
        frozen[_holder] = false;
        emit Unfreeze(_holder);
        return true;
    }

    function getNowTime() public view returns(uint256) {
        return now;
    }

    function showLockState(address _holder, uint256 _idx) public view returns (bool, uint256, uint256, uint256, uint256, uint256) {
        if(locks[_holder]) {
            return (
                locks[_holder], 
                lockupInfo[_holder].length, 
                lockupInfo[_holder][_idx].lockupBalance, 
                lockupInfo[_holder][_idx].releaseTime, 
                lockupInfo[_holder][_idx].termOfRound, 
                lockupInfo[_holder][_idx].unlockAmountPerRound
            );
        } else {
            return (
                locks[_holder], 
                lockupInfo[_holder].length, 
                0,0,0,0
            );

        }        
    }
    
    function distribute(address _to, uint256 _value) public onlyOwner returns (bool) {
        require(_to != address(0));
        require(_value <= balances[owner]);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(owner, _to, _value);
        return true;
    }

    function distributeWithLockup(address _to, uint256 _value, uint256 _releaseStart, uint256 _termOfRound, uint256 _releaseRate) public onlyOwner returns (bool) {
        distribute(_to, _value);
        lock(_to, _value, _releaseStart, _termOfRound, _releaseRate);
        return true;
    }

    function claimToken(ERC20 token, address _to, uint256 _value) public onlyOwner returns (bool) {
        token.transfer(_to, _value);
        return true;
    }

    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        return true;
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly{size := extcodesize(addr)}
        return size > 0;
    }

    function autoUnlock(address _holder) internal returns (bool) {

        for(uint256 idx =0; idx < lockupInfo[_holder].length ; idx++ ) {
            if(locks[_holder]==false) {
                return true;
            }
            if (lockupInfo[_holder][idx].releaseTime <= now) {
                
                if( releaseTimeLock(_holder, idx) ) {
                    idx -=1;
                }
            }
        }
        return true;
    }

    function releaseTimeLock(address _holder, uint256 _idx) internal returns(bool) {
        require(locks[_holder]);
        require(_idx < lockupInfo[_holder].length);

        
        LockupInfo storage info = lockupInfo[_holder][_idx];
        uint256 releaseAmount = info.unlockAmountPerRound;
        uint256 sinceFrom = now.sub(info.releaseTime);
        uint256 sinceRound = sinceFrom.div(info.termOfRound);
        releaseAmount = releaseAmount.add( sinceRound.mul(info.unlockAmountPerRound) );

        if(releaseAmount >= info.lockupBalance) {            
            releaseAmount = info.lockupBalance;

            delete lockupInfo[_holder][_idx];
            lockupInfo[_holder][_idx] = lockupInfo[_holder][lockupInfo[_holder].length.sub(1)];
            lockupInfo[_holder].length -=1;

            if(lockupInfo[_holder].length == 0) {
                locks[_holder] = false;
            }
            emit Unlock(_holder, releaseAmount);
            balances[_holder] = balances[_holder].add(releaseAmount);
            return true;
        } else {
            lockupInfo[_holder][_idx].releaseTime = lockupInfo[_holder][_idx].releaseTime.add( sinceRound.add(1).mul(info.termOfRound) );
            lockupInfo[_holder][_idx].lockupBalance = lockupInfo[_holder][_idx].lockupBalance.sub(releaseAmount);
            emit Unlock(_holder, releaseAmount);
            balances[_holder] = balances[_holder].add(releaseAmount);
            return false;
        }
    }


}