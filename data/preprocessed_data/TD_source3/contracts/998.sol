contract RandomPrize {
 function claimPrize() public {
 uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
 if (randomNumber % 10 == 0) {
 // Award prize
 }
 }
}