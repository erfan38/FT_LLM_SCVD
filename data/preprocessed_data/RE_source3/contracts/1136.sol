contract RegBaseAbstract
{
    /// @dev A static identifier, set in the constructor and used for registrar
    /// lookup
    /// @return Registrar name SandalStraps registrars
    bytes32 public regName;

    /// @dev An general purpose resource such as short text or a key to a
    /// string in a StringsMap
    /// @return resource
    bytes32 public resource;
    
    /// @dev An address permissioned to enact owner restricted functions
    /// @return owner
    address public owner;
    
    /// @dev An address permissioned to take ownership of the contract
    /// @return newOwner
    address public newOwner;

//
// Events
//

    /// @dev Triggered on initiation of change owner address
    event ChangeOwnerTo(address indexed _newOwner);

    /// @dev Triggered on change of owner address
    event ChangedOwner(address indexed _oldOwner, address indexed _newOwner);

    /// @dev Triggered when the 