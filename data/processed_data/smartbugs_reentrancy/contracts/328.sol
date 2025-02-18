

pragma solidity ^0.5.0;





library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}



pragma solidity ^0.5.0;






contract CustodialContract is WhitelistAdminRole {
    HashRegistrar registrar;

    mapping (bytes32 => Ownership) domains;

    struct Ownership {
        address primary;
        address secondary;
    }

    event NewPrimaryOwner(bytes32 indexed labelHash, address indexed owner);
    event NewSecondaryOwner(bytes32 indexed labelHash, address indexed owner);
    event DomainWithdrawal(bytes32 indexed labelHash, address indexed recipient);

    function() external payable {}
    
    constructor(address _registrar) public {
        registrar = HashRegistrar(_registrar);
    }

    modifier onlyOwner(bytes32 _labelHash) {
        require(isOwner(_labelHash, msg.sender));
        _;
    }

    modifier onlyTransferred(bytes32 _labelHash) {
        require(isTransferred(_labelHash));
        _;
    }

    function isTransferred(bytes32 _labelHash) public view returns (bool) {
        (, address deedAddress, , , ) = registrar.entries(_labelHash);
        Deed deed = Deed(deedAddress);

        return (deed.owner() == address(this));
    }

    function isOwner(bytes32 _labelHash, address _address) public view returns (bool) {
        return (isPrimaryOwner(_labelHash, _address) || isSecondaryOwner(_labelHash, _address));
    }

    function isPrimaryOwner(bytes32 _labelHash, address _address) public view returns (bool) {
        (, address deedAddress, , , ) = registrar.entries(_labelHash);
        Deed deed = Deed(deedAddress);

        if (
            domains[_labelHash].primary == address(0) &&
            deed.previousOwner() == _address
        ) {
            return true;
        }
        return (domains[_labelHash].primary == _address);
    }

    function isSecondaryOwner(bytes32 _labelHash, address _address) public view returns (bool) {
        return (domains[_labelHash].secondary == _address);
    }

    function setPrimaryOwners(bytes32[] memory _labelHashes, address _address) public {
        for (uint i=0; i<_labelHashes.length; i++) {
            setPrimaryOwner(_labelHashes[i], _address);
        }
    }

    function setSecondaryOwners(bytes32[] memory _labelHashes, address _address) public {
        for (uint i=0; i<_labelHashes.length; i++) {
            setSecondaryOwner(_labelHashes[i], _address);
        }
    }

    function setPrimaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].primary = _address;
        emit NewPrimaryOwner(_labelHash, _address);
    }

    function setSecondaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].secondary = _address;
        emit NewSecondaryOwner(_labelHash, _address);
    }

    function setPrimaryAndSecondaryOwner(bytes32 _labelHash, address _primary, address _secondary) public {
        setPrimaryOwner(_labelHash, _primary);
        setSecondaryOwner(_labelHash, _secondary);
    }

    function withdrawDomain(bytes32 _labelHash, address payable _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].primary = address(0);
        domains[_labelHash].secondary = address(0);
        registrar.transfer(_labelHash, _address);
        emit DomainWithdrawal(_labelHash, _address);
    }

    function call(address _to, bytes memory _data) public payable onlyWhitelistAdmin {
        require(_to != address(registrar));
        (bool success,) = _to.call.value(msg.value)(_data);
        require(success);
    }
}