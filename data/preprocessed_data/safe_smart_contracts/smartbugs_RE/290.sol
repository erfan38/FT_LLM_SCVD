pragma solidity ^0.4.24;

contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    
    address private __upgradeabilityOwner;

    




    event ProxyOwnershipTransferred(address _previousOwner, address _newOwner);

    


    modifier ifOwner() {
        if (msg.sender == _upgradeabilityOwner()) {
            _;
        } else {
            _fallback();
        }
    }

    


    constructor() public {
        _setUpgradeabilityOwner(msg.sender);
    }

    



    function _upgradeabilityOwner() internal view returns (address) {
        return __upgradeabilityOwner;
    }

    


    function _setUpgradeabilityOwner(address _newUpgradeabilityOwner) internal {
        require(_newUpgradeabilityOwner != address(0), "Address should not be 0x");
        __upgradeabilityOwner = _newUpgradeabilityOwner;
    }

    


    function _implementation() internal view returns (address) {
        return __implementation;
    }

    



    function proxyOwner() external ifOwner returns (address) {
        return _upgradeabilityOwner();
    }

    



    function version() external ifOwner returns (string) {
        return __version;
    }

    



    function implementation() external ifOwner returns (address) {
        return _implementation();
    }

    



    function transferProxyOwnership(address _newOwner) external ifOwner {
        require(_newOwner != address(0), "Address should not be 0x");
        emit ProxyOwnershipTransferred(_upgradeabilityOwner(), _newOwner);
        _setUpgradeabilityOwner(_newOwner);
    }

    




    function upgradeTo(string _newVersion, address _newImplementation) external ifOwner {
        _upgradeTo(_newVersion, _newImplementation);
    }

    







    function upgradeToAndCall(string _newVersion, address _newImplementation, bytes _data) external payable ifOwner {
        _upgradeTo(_newVersion, _newImplementation);
        
        require(address(this).call.value(msg.value)(_data), "Fail in executing the function of implementation contract");
    }

}







