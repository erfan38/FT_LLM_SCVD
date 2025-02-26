function unpause() external onlyOwner { _unpause(); if (auction.tokenId == 0) { transferOwnership(settings.treasury); _createAuction(); } else if (auction.settled) { _createAuction(); } }
