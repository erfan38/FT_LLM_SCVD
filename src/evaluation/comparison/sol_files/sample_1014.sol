pragma solidity ^0.8.0;
function getContractVersion() external pure returns(uint8) {
return COINSPARROW_CONTRACT_VERSION;
}





function getJobStatus(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns (uint8)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint8 status = STATUS_JOB_NOT_EXIST;

if (jobEscrows[jobHash].exists) {
status = jobEscrows[jobHash].status;
}
return status;
}



function getJobCanCancelAfter(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns (uint32)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint32 hirerCanCancelAfter = 0;

if (jobEscrows[jobHash].exists) {
hirerCanCancelAfter = jobEscrows[jobHash].hirerCanCancelAfter;
}
return hirerCanCancelAfter;
}



function getSecondsToComplete(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns (uint32)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint32 secondsToComplete = 0;

if (jobEscrows[jobHash].exists) {
secondsToComplete = jobEscrows[jobHash].secondsToComplete;
}
return secondsToComplete;
}



function getAgreedCompletionDate(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns (uint32)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint32 agreedCompletionDate = 0;

if (jobEscrows[jobHash].exists) {
agreedCompletionDate = jobEscrows[jobHash].agreedCompletionDate;
}
return agreedCompletionDate;
}



function getActualCompletionDate(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns (uint32)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint32 jobCompleteDate = 0;

if (jobEscrows[jobHash].exists) {
jobCompleteDate = jobEscrows[jobHash].jobCompleteDate;
}
return jobCompleteDate;
}



function getJobValue(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee) external view returns(uint256)
{

bytes32 jobHash = getJobHash(
_jobId,
_hirer,
_contractor,
_value,
_fee);

uint256 amount = 0;
if (jobEscrows[jobHash].exists) {
amount = hirerEscrowMap[_hirer][jobHash];
}
return amount;
}


function validateRefundSignature(
uint8 _contractorPercent,
bytes _sigMsg,
address _signer) external pure returns(bool)
{

return checkRefundSignature(_contractorPercent,_sigMsg,_signer);

}


function checkRefundSignature(
uint8 _contractorPercent,
bytes _sigMsg,
address _signer) private pure returns(bool)
{
bytes32 percHash = keccak256(abi.encodePacked(_contractorPercent));
bytes32 msgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",percHash));

address addr = ECRecovery.recover(msgHash,_sigMsg);
return addr == _signer;
}


function getJobHash(
bytes16 _jobId,
address _hirer,
address _contractor,
uint256 _value,
uint256 _fee
)  private pure returns(bytes32)
{
return keccak256(abi.encodePacked(
_jobId,
_hirer,
_contractor,
_value,
_fee));
}

}