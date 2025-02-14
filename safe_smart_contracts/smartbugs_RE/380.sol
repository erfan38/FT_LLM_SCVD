pragma solidity 0.4.24;

interface CommAuctionIface {
    function getNextPrice(bytes32 democHash) external view returns (uint);
    function noteBallotDeployed(bytes32 democHash) external;

    

    function upgradeMe(address newSC) external;
}

contract safeSend {
    bool private txMutex3847834;

    
    
    function doSafeSend(address toAddr, uint amount) internal {
        doSafeSendWData(toAddr, "", amount);
    }

    function doSafeSendWData(address toAddr, bytes data, uint amount) internal {
        require(txMutex3847834 == false, "ss-guard");
        txMutex3847834 = true;
        
        
        
        require(toAddr.call.value(amount)(data), "ss-failed");
        txMutex3847834 = false;
    }
}
