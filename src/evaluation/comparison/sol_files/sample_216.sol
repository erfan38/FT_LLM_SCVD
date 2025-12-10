pragma solidity ^0.8.0;
function changeDistributor(address _newDistributor) public onlyOwner {
emit DistributorChanged(distributor, _newDistributor);
distributor = _newDistributor;

}