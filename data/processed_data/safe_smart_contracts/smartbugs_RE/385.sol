pragma solidity ^0.4.24;





contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
    




    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    
    bytes32 private constant proxyOwnerPosition = keccak256("you are the lucky man.proxy.owner");

    


    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    


    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "owner only");
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
        require(newOwner != address(0), "address is invalid");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    



    function upgradeTo(address implementation) public onlyProxyOwner {
        _upgradeTo(implementation);
    }

    






    function upgradeToAndCall(address implementation, bytes data) public payable onlyProxyOwner {
        upgradeTo(implementation);
        require(address(this).call.value(msg.value)(data), "data is invalid");
    }
}