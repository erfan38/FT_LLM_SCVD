contract Whitelist {
    address public owner;
    address public sale;

    mapping (address => uint) public accepted;

    function Whitelist() {
        owner = msg.sender;
    }

    
    function accept(address a, uint amount) {
        assert (msg.sender == owner || msg.sender == sale);

        accepted[a] = amount;
    }

    function setSale(address sale_) {
        assert (msg.sender == owner);

        sale = sale_;
    } 
}


contract DSExec {
    function tryExec( address target, bytes calldata, uint value)
             internal
             returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint value)
             internal
    {
        if(!tryExec(target, calldata, value)) {
            throw;
        }
    }

    
    function exec( address t, bytes c )
        internal
    {
        exec(t, c, 0);
    }
    function exec( address t, uint256 v )
        internal
    {
        bytes memory c; exec(t, c, v);
    }
    function tryExec( address t, bytes c )
        internal
        returns (bool)
    {
        return tryExec(t, c, 0);
    }
    function tryExec( address t, uint256 v )
        internal
        returns (bool)
    {
        bytes memory c; return tryExec(t, c, v);
    }
}


