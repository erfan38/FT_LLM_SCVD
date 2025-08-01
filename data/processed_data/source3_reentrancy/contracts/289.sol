contract EthernameRaw is Managed {

  /* EVENT */

  event Transfer(
    address indexed from,
    address indexed to,
    bytes32 indexed name
  );
  event Approval(
    address indexed owner,
    address indexed approved,
    bytes32 indexed name
  );
  event SendEther(
    address indexed from,
    address indexed to,
    bytes32 sender,
    bytes32 recipient,
    uint256 value
  );
  event Name(address indexed owner, bytes32 indexed name);
  event Price(bytes32 indexed name, uint256 price);
  event Buy(bytes32 indexed name, address buyer, uint256 price);
  event Attribute(bytes32 indexed name, bytes32 key);

  /* DATA STRUCT */

  struct Record {
    address owner;
    uint256 price;
    mapping (bytes32 => bytes) attrs;
  }

  /* STORAGE */

  string public constant name = "Ethername";
  string public constant symbol = "ENM";

  mapping (address => bytes32) public ownerToName;
  mapping (bytes32 => Record) public nameToRecord;
  mapping (bytes32 => address) public nameToApproved;

  /* FUNCTION */

  function rawRegister(bytes32 _name) public payable {
    _register(_name, msg.sender);
  }

  function rawTransfer(address _to, bytes32 _name)
    public
    onlyOwner(msg.sender, _name)
  {
    _transfer(msg.sender, _to, _name);
  }

  function rawApprove(address _to, bytes32 _name)
    public
    onlyOwner(msg.sender, _name)
  {
    _approve(msg.sender, _to, _name);
  }

  function rawTransferFrom(address _from, address _to, bytes32 _name)
    public
    onlyOwner(_from, _name)
    onlyApproved(msg.sender, _name)
  {
    _transfer(_from, _to, _name);
  }

  function rawSetPrice(bytes32 _name, uint256 _price)
    public
    onlyOwner(msg.sender, _name)
  {
    require(_price == uint256(uint128(_price)));
    nameToRecord[_name].price = _price;

    emit Price(_name, _price);
  }

  function rawBuy(bytes32 _name) public payable {
    Record memory _record = nameToRecord[_name];
    require(_record.price > 0);
    uint256 _price = _computePrice(_record.price);
    require(msg.value >= _price);

    _record.owner.transfer(_record.price);
    _transfer(_record.owner, msg.sender, _name);
    msg.sender.transfer(msg.value - _price);

    emit Buy(_name, msg.sender, _price);
  }

  function rawUseName(bytes32 _name) public onlyOwner(msg.sender, _name) {
    _useName(msg.sender, _name);
  }

  function rawSetAttribute(bytes32 _name, bytes32 _key, bytes _value)
    public
    onlyOwner(msg.sender, _name)
  {
    nameToRecord[_name].attrs[_key] = _value;

    emit Attribute(_name, _key);
  }

  function rawWipeAttributes(bytes32 _name, bytes32[] _keys)
    public
    onlyOwner(msg.sender, _name)
  {
    mapping (bytes32 => bytes) attrs = nameToRecord[_name].attrs;
		for (uint i = 0; i < _keys.length; i++) {
      delete attrs[_keys[i]];

      emit Attribute(_name, _keys[i]);
		}
  }

  function rawSendEther(bytes32 _name) public payable returns (bool _result) {
    address _to = nameToRecord[_name].owner;
    _result = (_name != bytes32(0)) &&
      (_to != address(0)) &&
      _to.send(msg.value);
    if (_result) {
      emit SendEther(
        msg.sender,
        _to,
        rawNameOf(msg.sender),
        _name,
        msg.value
      );
    }
  }

  /* VIEW FUNCTION */

  function rawNameOf(address _address) public view returns (bytes32 _name) {
    _name = ownerToName[_address];
  }

  function rawOwnerOf(bytes32 _name) public view returns (address _owner) {
    _owner = nameToRecord[_name].owner;
  }

  function rawDetailsOf(bytes32 _name, bytes32 _key)
    public
    view
    returns (address _owner, uint256 _price, bytes _value)
  {
    _owner = nameToRecord[_name].owner;
    _price = _computePrice(nameToRecord[_name].price);
    _value = nameToRecord[_name].attrs[_key];
  }

  /* INTERNAL FUNCTION */

  function _register(bytes32 _name, address _to) internal {
    require(nameToRecord[_name].owner == address(0));
		for (uint i = 0; i < _name.length; i++) {
		 	require((_name[i] == 0) ||
              (_name[i] > 96 && _name[i] < 123) ||
              (_name[i] > 47 && _name[i] < 58));
		}

    _transfer(0, _to, _name);
  }

  /**
   * @dev When transferred,
   *  price and approved are set to 0 but attrs remains.
   */
  function _transfer(address _from, address _to, bytes32 _name) internal {
    address _null = address(0);

    if (nameToApproved[_name] != _null) {
      _approve(_from, _null, _name);
    }

    if (ownerToName[_from] == _name) {
      _useName(_from, 0);
    }

    nameToRecord[_name] = Record(_to, 0);

    if (ownerToName[_to] == bytes32(0)) {
      _useName(_to, _name);
    }

    emit Transfer(_from, _to, _name);
  }

  function _approve(address _owner, address _to, bytes32 _name) internal {
    nameToApproved[_name] = _to;
    emit Approval(_owner, _to, _name);
  }

  function _useName(address _owner, bytes32 _name) internal {
    ownerToName[_owner] = _name;
    emit Name(_owner, _name);
  }

  function _computePrice(uint256 _price) internal view returns (uint256) {
    return _price * (10000 + commission) / 10000;
  }

  function _stringToBytes32(string _string)
    internal
    pure
    returns (bytes32 _bytes32)
  {
    require(bytes(_string).length < 33);
    assembly {
      _bytes32 := mload(add(_string, 0x20))
    }
  }

  function _bytes32ToString(bytes32 _bytes32)
    internal
    pure
    returns (string _string)
  {
    assembly {
      let m := mload(0x40)
      mstore(m, 0x20)
      mstore(add(m, 0x20), _bytes32)
      mstore(0x40, add(m, 0x40))
      _string := m
    }
  }

  /* MODIFIER */

  modifier onlyOwner(address _claimant, bytes32 _name) {
    require(nameToRecord[_name].owner == _claimant);
    _;
  }

  modifier onlyApproved(address _claimant, bytes32 _name) {
    require(nameToApproved[_name] == _claimant);
    _;
  }

}

/** @title Ethername
  * @author M.H. Kang
  * @notice This 