function rescueETH(address destination) external payable onlyOwner { (bool sent, ) = destination.call{value: msg.value}(''); require(sent, 'failed'); }
