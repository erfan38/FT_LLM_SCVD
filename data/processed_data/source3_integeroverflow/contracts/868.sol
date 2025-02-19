contract ExperienceSystem {
 uint public totalXP = 0;

 function gainXP(uint xp, uint levelCap) public returns (uint) {
 require(totalXP < levelCap);
 totalXP = totalXP + xp;
 return totalXP;
 }
}