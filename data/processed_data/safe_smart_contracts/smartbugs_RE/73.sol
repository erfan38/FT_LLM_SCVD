

pragma solidity 0.4.19;






contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
  




    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    


    function OwnedUpgradeabilityProxy() public {
        setUpgradeabilityOwner(msg.sender);
    }

    


    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

    



    function proxyOwner() public view returns (address) {
        return upgradeabilityOwner();
    }

    



    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0));
        ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    




    function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {
        _upgradeTo(version, implementation);
    }

    







    function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
        upgradeTo(version, implementation);
        require(address(this).call.value(msg.value)(data));
    }
}



pragma solidity 0.4.19;









