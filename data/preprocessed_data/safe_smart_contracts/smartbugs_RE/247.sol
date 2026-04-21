pragma solidity ^0.4.24;





contract Mortal is DSAuth {
    function kill() public auth {
        selfdestruct(owner);
    }
    
    function withdrawTo(address _to) public auth {
    
        require(_to.call.value(address(this).balance)());
    }
    
    function withdrawTokenTo(TokenInterface token, address _to) public auth {
    
        require(token.transfer(_to, token.balanceOf(this)));
    }
}
