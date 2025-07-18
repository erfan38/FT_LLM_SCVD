contract GoodfieldNewRetail is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    function GoodfieldNewRetail(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value >= balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }

    
    
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    
    
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable public returns (uint amount){
        amount = msg.value / buyPrice;                    
        require(balanceOf[this] >= amount);               
        balanceOf[msg.sender] += amount;                  
        balanceOf[this] -= amount;                        
        emit Transfer(this, msg.sender, amount);               
        return amount;                                    
    }

    function sell(uint amount) public returns (uint revenue){
        require(balanceOf[msg.sender] >= amount);         
        balanceOf[this] += amount;                        
        balanceOf[msg.sender] -= amount;                  
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);                     
        emit Transfer(msg.sender, this, amount);               
        return revenue;                                   
    }
}