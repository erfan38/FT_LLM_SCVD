contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param version representing the version name of the upgraded implementation
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(uint256 version, address indexed implementation);

    /**
    * @dev Upgrades the implementation address
    * @param version representing the version name of the new implementation to be set
    * @param implementation representing the address of the new implementation to be set
    */
    function _upgradeTo(uint256 version, address implementation) internal {
        require(_implementation != implementation);
        require(version > _version);
        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}

// File: contracts/upgradeability/OwnedUpgradeabilityProxy.sol

/**
 * @title OwnedUpgradeabilityProxy
 * @dev This 