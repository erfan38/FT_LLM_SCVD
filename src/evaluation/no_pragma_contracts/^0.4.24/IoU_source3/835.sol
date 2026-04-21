contract Accumulator {
 uint256 public sum;

 function accumulate(uint256[] memory _values) external {
 for (uint i = 0; i < _values.length; i++) {
 sum += _values[i];
 }
 }
}