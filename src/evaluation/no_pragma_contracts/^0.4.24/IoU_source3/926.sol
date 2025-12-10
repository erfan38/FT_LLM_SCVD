contract ReputationSystem {
 mapping(address => uint256) public reputation;
 uint256 public constant REPUTATION_INCREASE = 10;

 function increaseReputation(address user) public {
 reputation[user] = reputation[user] + REPUTATION_INCREASE;
 }
}