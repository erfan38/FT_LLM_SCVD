contract Averager {
 function average(uint256[] memory numbers) public pure returns (uint256) {
 uint256 sum = 0;
 for(uint i = 0; i < numbers.length; i++) {
 sum += numbers[i];
 }
 return sum / numbers.length;
 }
}