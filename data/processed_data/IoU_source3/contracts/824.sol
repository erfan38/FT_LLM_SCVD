contract Overflow_add_array {

 uint8[] public numbers;

 function addNumber(uint8 num) public {
 numbers.push(num);
 }

 function sumArray() public view returns (uint8) {
 uint8 sum = 0;
 for(uint i = 0; i < numbers.length; i++) {
 sum += numbers[i];
 }
 return sum;
 }
}