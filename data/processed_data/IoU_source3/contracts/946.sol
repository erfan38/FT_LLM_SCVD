contract AgeVerifier {
 uint256 public minimumAge = 18;

 function verifyAge(uint256 birthYear) public view returns (bool) {
 uint256 currentYear = 2023;
 uint256 age = currentYear - birthYear;
 return age >= minimumAge;
 }
}