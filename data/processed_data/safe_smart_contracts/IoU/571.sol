contract ERC721Receiver {

    

    bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;


    

    function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);

}




interface ERC165 {


    

    function supportsInterface(bytes4 _interfaceId) external view returns (bool);

}





