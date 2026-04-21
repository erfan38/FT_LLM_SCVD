pragma solidity 0.5.5; 







































 








library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}





    
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
  




  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  
  bytes32 private constant proxyOwnerPosition = keccak256("EtherAuthority.io.proxy.owner");

  


  constructor () public {
    setUpgradeabilityOwner(msg.sender);
  }

  


  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  



  function proxyOwner() public view returns (address owner) {
    bytes32 position = proxyOwnerPosition;
    assembly {
      owner := sload(position)
    }
  }

  


  function setUpgradeabilityOwner(address newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, newProxyOwner)
    }
  }

  



  function transferProxyOwnership(address newOwner) public onlyProxyOwner {
    require(newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  



  function upgradeTo(address implementation) public onlyProxyOwner {
    _upgradeTo(implementation);
  }

  






  function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {
    _upgradeTo(implementation);
    (bool success,) = address(this).call.value(msg.value).gas(200000)(data);
    require(success,'initialize function errored');
  }
  
  function generateData() public view returns(bytes memory){
        
    return abi.encodeWithSignature("initialize(address)",msg.sender);
      
  }
}









 