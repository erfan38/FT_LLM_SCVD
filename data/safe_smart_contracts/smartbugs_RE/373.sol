




pragma solidity 0.4.24;





contract BulksenderProxy is UpgradeabilityProxy {
  




  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  
  bytes32 private constant proxyOwnerPosition = keccak256("bulksender.app.proxy.owner");

  


  constructor(address _implementation, string _version) public {
    _setUpgradeabilityOwner(msg.sender);
    _upgradeTo(_implementation, _version);
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

  



  function transferProxyOwnership(address _newOwner) public onlyProxyOwner {
    require(_newOwner != address(0));
    _setUpgradeabilityOwner(_newOwner);
    emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
  }

  



  function upgradeTo(address _implementation, string _newVersion) public onlyProxyOwner {
    _upgradeTo(_implementation, _newVersion);
  }

  






  function upgradeToAndCall(address _implementation, string _newVersion, bytes _data) payable public onlyProxyOwner {
    _upgradeTo(_implementation, _newVersion);
    require(address(this).call.value(msg.value)(_data));
  }

  


  function _setUpgradeabilityOwner(address _newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, _newProxyOwner)
    }
  }
}