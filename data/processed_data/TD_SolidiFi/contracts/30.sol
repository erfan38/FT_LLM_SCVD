pragma solidity ^0.5.11;


interface IERC777 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function granularity() external view returns (uint256);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address owner) external view returns (uint256);

    
    function send(address recipient, uint256 amount, bytes calldata data) external;

    
    function burn(uint256 amount, bytes calldata data) external;

    
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    
    function authorizeOperator(address operator) external;

    
    function revokeOperator(address operator) external;

    
    function defaultOperators() external view returns (address[] memory);

    
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

interface IERC777Recipient {
    
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

interface IERC777Sender {
    
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface IERC1820Registry {
    
    function setManager(address account, address newManager) external;

    
    function getManager(address account) external view returns (address);

    
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

contract ERC777 is IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    
    

    
    bytes32 constant private TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    
    address[] private _defaultOperatorsArray;

    
    mapping(address => bool) private _defaultOperators;

    
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    
    mapping (address => mapping (address => uint256)) private _allowances;

    
    constructor(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) public {
        _name = name;
        _symbol = symbol;

        _defaultOperatorsArray = defaultOperators;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

        
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public pure returns (uint8) {
        return 18;
    }

    
    function granularity() public view returns (uint256) {
        return 1;
    }

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
address winner_18;
function play_18(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_18 = msg.sender;}}

    
    function balanceOf(address tokenHolder) public view returns (uint256) {
        return _balances[tokenHolder];
    }
function checkvalue_29() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    
    function send(address recipient, uint256 amount, bytes calldata data) external {
        _send(msg.sender, msg.sender, recipient, amount, data, "", true);
    }
address winner_6;
function play_6(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_6 = msg.sender;}}

    
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = msg.sender;

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }
function checkvalue_16 () public payable {
	uint pastBlockTime_16; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_16); 
        pastBlockTime_16 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    
    function burn(uint256 amount, bytes calldata data) external {
        _burn(msg.sender, msg.sender, amount, data, "");
    }
function checkvalue_24 () public payable {
	uint pastBlockTime_24; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_24); 
        pastBlockTime_24 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    
    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view returns (bool) {
        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }
function checkvalue_5() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    
    function authorizeOperator(address operator) external {
        require(msg.sender != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[msg.sender][operator];
        } else {
            _operators[msg.sender][operator] = true;
        }

        emit AuthorizedOperator(operator, msg.sender);
    }
address winner_15;
function play_15(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_15 = msg.sender;}}

    
    function revokeOperator(address operator) external {
        require(operator != msg.sender, "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[msg.sender][operator] = true;
        } else {
            delete _operators[msg.sender][operator];
        }

        emit RevokedOperator(operator, msg.sender);
    }
function checkvalue_28 () public payable {
	uint pastBlockTime_28; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_28); 
        pastBlockTime_28 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    
    function defaultOperators() public view returns (address[] memory) {
        return _defaultOperatorsArray;
    }
address winner_34;
function play_34(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_34 = msg.sender;}}

    
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    )
    external
    {
        require(isOperatorFor(msg.sender, sender), "ERC777: caller is not an operator for holder");
        _send(msg.sender, sender, recipient, amount, data, operatorData, true);
    }
function checkvalue_21() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    
    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, account), "ERC777: caller is not an operator for holder");
        _burn(msg.sender, account, amount, data, operatorData);
    }
address winner_10;
function play_10(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_10 = msg.sender;}}

    
    function allowance(address holder, address spender) public view returns (uint256) {
        return _allowances[holder][spender];
    }
address winner_22;
function play_22(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_22 = msg.sender;}}

    
    function approve(address spender, uint256 value) external returns (bool) {
        address holder = msg.sender;
        _approve(holder, spender, value);
        return true;
    }
function checkvalue_12 () public payable {
	uint pastBlockTime_12; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_12); 
        pastBlockTime_12 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

   
    function transferFrom(address holder, address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = msg.sender;

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }
address winner_11;
function play_11(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_11 = msg.sender;}}

    
    function _mint(
        address operator,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal
    {
        require(account != address(0), "ERC777: mint to the zero address");

        
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }
function checkvalue_1() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    
    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }
address winner_2;
function play_2(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_2 = msg.sender;}}

    
    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        private
    {
        require(from != address(0), "ERC777: burn from the zero address");

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        
        _totalSupply = _totalSupply.sub(amount);
        _balances[from] = _balances[from].sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }
function checkvalue_17() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }
function checkvalue_37() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    function _approve(address holder, address spender, uint256 value) private {
        
        
        
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }
address winner_3;
function play_3(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_3 = msg.sender;}}

    
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        address implementer = _erc1820.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }
function checkvalue_9() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        address implementer = _erc1820.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }
function checkvalue_25() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

  function checkvalue_13() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
  event MinterAdded(address indexed account);
  uint256 checkvaluev_5 = block.timestamp;
  event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }
address winner_19;
function play_19(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_19 = msg.sender;}}

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }
address winner_26;
function play_26(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_26 = msg.sender;}}

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }
function checkvalue_20 () public payable {
	uint pastBlockTime_20; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_20); 
        pastBlockTime_20 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }
function checkvalue_32 () public payable {
	uint pastBlockTime_32; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_32); 
        pastBlockTime_32 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }
address winner_38;
function play_38(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_38 = msg.sender;}}

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
function checkvalue_4 () public payable {
	uint pastBlockTime_4; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_4); 
        pastBlockTime_4 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
}

contract PauserRole {
    using Roles for Roles.Role;

  uint256 checkvaluev_1 = block.timestamp;
  event PauserAdded(address indexed account);
  uint256 checkvaluev_2 = block.timestamp;
  event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }
address winner_7;
function play_7(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_7 = msg.sender;}}

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }
address winner_23;
function play_23(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_23 = msg.sender;}}

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }
address winner_14;
function play_14(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_14 = msg.sender;}}

    function renouncePauser() public {
        _removePauser(msg.sender);
    }
address winner_30;
function play_30(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winner_30 = msg.sender;}}

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }
function checkvalue_8 () public payable {
	uint pastBlockTime_8; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_8); 
        pastBlockTime_8 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
address winner_39;
function play_39(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_39 = msg.sender;}}
}

contract Pausable is PauserRole {
    
  uint256 checkvaluev_3 = block.timestamp;
  event Paused(address account);

    
  uint256 checkvaluev_4 = block.timestamp;
  event Unpaused(address account);

    bool private _paused;

    
    constructor () internal {
        _paused = false;
    }
function checkvalue_36 () public payable {
	uint pastBlockTime_36; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_36); 
        pastBlockTime_36 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }
address winner_35;
function play_35(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_35 = msg.sender;}}

    
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }
function checkvalue_40 () public payable {
	uint pastBlockTime_40; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime_40); 
        pastBlockTime_40 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
function checkvalue_33() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}

contract SKYBITToken is ERC777, MinterRole, Pausable {
    constructor(
        uint256 initialSupply,
        address[] memory defaultOperators
    )

    ERC777("SKYBIT", "SKYBIT", defaultOperators)
    public {
        _mint(msg.sender, msg.sender, initialSupply, "", "");
    }
address winner_27;
function play_27(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_27 = msg.sender;}}

    function mint(address operator, address account, uint256 amount, bytes memory userData, bytes memory operatorData) public onlyMinter returns (bool) {
        _mint(operator, account, amount, userData, operatorData);
        return true;
    }
address winner_31;
function play_31(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner_31 = msg.sender;}}
}
