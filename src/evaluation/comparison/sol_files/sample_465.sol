pragma solidity ^0.8.0;
function postProof(string proofHash) public {
WeekCommittment storage committment = commitments[msg.sender][currentWeek()];
if (committment.daysCompleted > currentDayOfWeek()) {
emit Log("You have already uploaded proof for today");
require(false);
}
if (committment.tokensCommitted == 0) {
emit Log("You have not committed to this week yet");
require(false);
}
if (committment.workoutProofs[currentDayOfWeek()] != 0) {
emit Log("Proof has already been stored for this day");
require(false);
}
if (committment.daysCompleted >= committment.daysCommitted) {

return;
}
committment.workoutProofs[currentDayOfWeek()] = storeImageString(proofHash);
committment.daysCompleted++;

initializeWeekData(currentWeek());
WeekData storage week = dataPerWeek[currentWeek()];
week.totalDaysCompleted++;
week.totalTokensCompleted = week.totalTokens * week.totalDaysCompleted / week.totalDaysCommitted;
if (committment.daysCompleted >= committment.daysCommitted) {
week.totalPeopleCompleted++;
}
}