contract Overflow_add_unchecked {

 function add_overflow() returns (uint256 _overflow) {
 uint256 max = type(uint256).max;
 unchecked {
 return max + 1;
 }
 }
}