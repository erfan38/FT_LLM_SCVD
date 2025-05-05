contract RegBase
{
//
// Constants
//

    bytes32 constant public VERSION = "RegBase v0.2.1";

//
// State Variables
//
    
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

//
// Events
//

    // Triggered on change of owner address
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

    // Triggered on change of resource
    event ChangedResource(bytes32 indexed resource);

//
// Modifiers
//

    // Permits only the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

//
// Functions
//

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for owner, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function RegBase(address _creator, bytes32 _regName, address _owner)
    {
        regName = _regName;
        owner = _owner != 0x0 ? _owner : 
                _creator != 0x0 ? _creator : msg.sender;
    }
    
    /// @notice Will selfdestruct the 