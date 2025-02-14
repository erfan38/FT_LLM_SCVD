pragma solidity ^0.4.18;







contract BullTokenRefundVault is RefundVault {

  function BullTokenRefundVault(address _wallet) public RefundVault(_wallet) {}

  
  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    
    
    wallet.call.value(this.balance)();
  }

  function forwardFunds() onlyOwner public {
    require(this.balance > 0);
    wallet.call.value(this.balance)();
  }
}











