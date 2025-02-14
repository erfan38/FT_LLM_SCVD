







pragma solidity 0.4.20;






contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
    




    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    


    function OwnedUpgradeabilityProxy(address _owner) public {
        setUpgradeabilityOwner(_owner);
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

    




    function upgradeTo(string version, address implementation) public onlyProxyOwner {
        _upgradeTo(version, implementation);
    }

    







    function upgradeToAndCall(string version, address implementation, bytes data) payable public onlyProxyOwner {
        upgradeTo(version, implementation);
        require(this.call.value(msg.value)(data));
    }
}





pragma solidity 0.4.20;









