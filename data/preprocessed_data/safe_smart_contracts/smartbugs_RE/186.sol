pragma solidity ^0.4.24;







interface ImplementationProvider {
  




  function getImplementation(string contractName) public view returns (address);
}










contract UpgradeabilityProxyFactory {
  



  event ProxyCreated(address proxy);

  





  function createProxy(address admin, address implementation) public returns (AdminUpgradeabilityProxy) {
    AdminUpgradeabilityProxy proxy = _createProxy(implementation);
    proxy.changeAdmin(admin);
    return proxy;
  }

  










  function createProxyAndCall(address admin, address implementation, bytes data) public payable returns (AdminUpgradeabilityProxy) {
    AdminUpgradeabilityProxy proxy = _createProxy(implementation);
    proxy.changeAdmin(admin);
    require(address(proxy).call.value(msg.value)(data));
    return proxy;
  }

  




  function _createProxy(address implementation) internal returns (AdminUpgradeabilityProxy) {
    AdminUpgradeabilityProxy proxy = new AdminUpgradeabilityProxy(implementation);
    emit ProxyCreated(proxy);
    return proxy;
  }
}







