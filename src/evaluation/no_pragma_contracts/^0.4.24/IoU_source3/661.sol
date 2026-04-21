contract mcs is owned, TokenERC20{

    bool public freeze=true;

    function mcs() TokenERC20(600000000, "Magicstonelink", "MCS") public {}

    function _transfer(address _from, address _to, uint _value) internal {
        require (freeze);
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value >= balanceOf[_to]); 
	    uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function setfreeze(bool state) onlyOwner public{
        freeze=state;
    }
 }