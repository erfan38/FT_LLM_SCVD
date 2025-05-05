contract ForwarderFactory is Factory
{
//
// Constants
//

    /// @return registrar name
    bytes32 constant public regName = "forwarder";
    
    /// @return version string
    bytes32 constant public VERSION = "ForwarderFactory v0.3.0";

//
// Functions
//

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for _owner or _creator, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function ForwarderFactory(
            address _creator, bytes32 _regName, address _owner) public
        Factory(_creator, regName, _owner)
    {
        // _regName is ignored as `regName` is already a constant
        // nothing to construct
    }

    /// @notice Create a new product contract
    /// @param _regName A unique name if the the product is to be registered in
    /// a SandalStraps registrar
    /// @param _owner An address of a third party owner.  Will default to
    /// msg.sender if 0x0
    /// @return kAddr_ The address of the new product 