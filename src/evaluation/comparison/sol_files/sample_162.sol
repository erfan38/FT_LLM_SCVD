pragma solidity ^0.8.0;
function getQueueLength() public view returns (uint) {
return queue.length - currentReceiverIndex;
}

}