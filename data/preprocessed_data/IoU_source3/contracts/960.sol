contract ReputationSystem {
 uint256 public totalReputation = 100000;
 mapping(uint256 => uint256) public reputationPerAction;

 function assignReputation(uint256 _actionWeight) public returns (bool) {
 uint256 currentAction = block.number % 1000;
 if(reputationPerAction[currentAction] == 0) {
 reputationPerAction[currentAction] = totalReputation * _actionWeight / 1000;
 }
 return true;
 }
}