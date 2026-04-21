contract AgeCalculator {
 function calculateAge(uint _birthYear) public view returns (uint) {
 uint currentYear = 2023;
 uint age = currentYear - _birthYear;
 return age;
 }
}