contract Forwarder is RegBase {
//
// Constants
//

    bytes32 constant public VERSION = "Forwarder v0.3.0";

//
// State
//

    address public forwardTo;
    
//
// Events
//
    
    event Forwarded(
        address indexed _from,
        address indexed _to,
        uint _value);

//
// Functions
//

    function Forwarder(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        // forwardTo will be set to msg.sender of if _owner == 0x0 or _owner
        // otherwise
        forwardTo = owner;
    }
    
    function ()
        public
        payable 
    {
        Forwarded(msg.sender, forwardTo, msg.value);
        require(forwardTo.call.value(msg.value)(msg.data));
    }
    
    function changeForwardTo(address _forwardTo)
        public
        returns (bool)
    {
        // Only owner or forwarding address can change forwarding address 
        require(msg.sender == owner || msg.sender == forwardTo);
        forwardTo = _forwardTo;
        return true;
    }
}


