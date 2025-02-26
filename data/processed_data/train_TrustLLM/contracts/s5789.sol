modifier epochHasNotStarted(uint256 id) { if(block.timestamp > idEpochBegin[id] - timewindow) revert EpochAlreadyStarted(); _; }
