pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract FETCOIN is ERC223, Pausable {
    using SafeMath for uint256;

    struct Offering {
        uint256 amount;
        uint256 locktime;
    }

    string public name = "fetish coin";
    string public symbol = "FET";
    uint8 public decimals = 6;
    uint256 public totalSupply = 10e10 * 1e6;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;

    mapping(address => mapping(address => Offering)) public offering;

    event Freeze(address indexed target, uint256 value);
    event Unfreeze(address indexed target, uint256 value);
    event Burn(address indexed from, uint256 amount);
    event Rain(address indexed from, uint256 amount);

    function FETCOIN() public {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return balanceOf[_owner];
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }

    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) whenNotPaused public returns (bool _success) {
        require(_value > 0 && frozenAccount[msg.sender] == false && frozenAccount[_to] == false);

        if (isContract(_to)) {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transfer(address _to, uint _value, bytes _data) whenNotPaused public returns (bool _success) {
        require(_value > 0 && frozenAccount[msg.sender] == false && frozenAccount[_to] == false);

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transfer(address _to, uint _value) whenNotPaused public returns (bool _success) {
        require(_value > 0 && frozenAccount[msg.sender] == false && frozenAccount[_to] == false);

        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    function name() public view returns (string _name) {
        return name;
    }

    function symbol() public view returns (string _symbol) {
        return symbol;
    }

    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool _success) {
        require(_to != address(0)
            && _value > 0
            && balanceOf[_from] >= _value
            && allowance[_from][msg.sender] >= _value
            && frozenAccount[_from] == false && frozenAccount[_to] == false);

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool _success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 _remaining) {
        return allowance[_owner][_spender];
    }

    function freezeAccounts(address[] _targets) onlyOwner whenNotPaused public returns (bool _success) {
        require(_targets.length > 0);

        for (uint j = 0; j < _targets.length; j++) {
            require(_targets[j] != 0x0);
            frozenAccount[_targets[j]] = true;
            Freeze(_targets[j], balanceOf[_targets[j]]);
        }
        return true;
    }

    function unfreezeAccounts(address[] _targets) onlyOwner whenNotPaused public returns (bool _success) {
        require(_targets.length > 0);

        for (uint j = 0; j < _targets.length; j++) {
            require(_targets[j] != 0x0);
            frozenAccount[_targets[j]] = false;
            Unfreeze(_targets[j], balanceOf[_targets[j]]);
        }
        return true;
    }

    function isFrozenAccount(address _target) public view returns (bool _is_frozen){
        return frozenAccount[_target] == true;
    }

    function isContract(address _target) private view returns (bool _is_contract) {
        uint length;
        assembly {
            length := extcodesize(_target)
        }
        return (length > 0);
    }

    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferToContract(address _to, uint _value, bytes _data) private returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _amount) onlyOwner whenNotPaused public returns (bool _success) {
        require(_amount > 0 && balanceOf[_from] >= _amount);
        _amount = _amount.mul(1e6);
        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        Burn(_from, _amount);
        return true;
    }

    function rain(address[] _addresses, uint256 _amount) onlyOwner whenNotPaused public returns (bool _success) {
        require(_amount > 0 && _addresses.length > 0 && frozenAccount[msg.sender] == false);

        _amount = _amount.mul(1e6);
        uint256 totalAmount = _amount.mul(_addresses.length);
        require(balanceOf[msg.sender] >= totalAmount);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);

        for (uint j = 0; j < _addresses.length; j++) {
            require(_addresses[j] != 0x0 && frozenAccount[_addresses[j]] == false);

            balanceOf[_addresses[j]] = balanceOf[_addresses[j]].add(_amount);
            Transfer(msg.sender, _addresses[j], _amount);
        }
        Rain(msg.sender, totalAmount);
        return true;
    }

    function collectTokens(address[] _addresses, uint[] _amounts) onlyOwner whenNotPaused public returns (bool _success) {
        require(_addresses.length > 0 && _addresses.length == _amounts.length);

        uint256 totalAmount = 0;

        for (uint j = 0; j < _addresses.length; j++) {
            require(_amounts[j] > 0 && _addresses[j] != 0x0 && frozenAccount[_addresses[j]] == false);
            _amounts[j] = _amounts[j].mul(1e6);
            require(balanceOf[_addresses[j]] >= _amounts[j]);
            balanceOf[_addresses[j]] = balanceOf[_addresses[j]].sub(_amounts[j]);
            totalAmount = totalAmount.add(_amounts[j]);
            Transfer(_addresses[j], msg.sender, _amounts[j]);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].add(totalAmount);
        return true;
    }

    function() payable public {}
}