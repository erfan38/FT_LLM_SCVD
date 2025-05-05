pragma solidity ^0.4.13;







contract ICOBuyer {

  
  address public developer = 0xF23B127Ff5a6a8b60CC4cbF937e5683315894DDA;
  
  address public sale;
  
  ERC20 public token;
  
  
  function set_addresses(address _sale, address _token) {
    
    require(msg.sender == developer);
    
    
    sale = _sale;
    token = ERC20(_token);
  }
  
  
  
  function withdraw(){
      developer.transfer(this.balance);
      require(token.transfer(developer, token.balanceOf(address(this))));
  }
  
  
  
  function buy(){
    require(sale != 0x0);
    require(sale.call.value(this.balance)());
    
  }
  
  
  function () payable {
    
  }
}