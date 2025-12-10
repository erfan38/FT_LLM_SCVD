contract Owned {
    function Owned() {
        owner = msg.sender;
    }

    address public owner;

    // This 