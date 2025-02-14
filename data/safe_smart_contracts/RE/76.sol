contract testreg is ERC721BasicToken  {

	// @param

    struct TokenStruct {
        string token_uri;
    }

    mapping (uint256 => TokenStruct) TokenId;

}

// File: contracts/update.sol

