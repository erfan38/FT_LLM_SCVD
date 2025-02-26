modifier onlyL1Counterpart() { require( msg.sender == AddressAliasHelper.applyL1ToL2Alias(l1Counterpart), "ONLY_COUNTERPART_GATEWAY" ); _; }
