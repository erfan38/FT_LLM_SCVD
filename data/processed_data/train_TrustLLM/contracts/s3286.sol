function quorum() public view returns (uint256) { unchecked { return (settings.token.totalSupply() * settings.quorumThresholdBps) / 10_000; } }
