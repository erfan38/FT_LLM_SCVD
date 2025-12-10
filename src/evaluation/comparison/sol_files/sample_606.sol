pragma solidity ^0.8.0;
function payFund() public {
if(!FundEIF.call.value(fundEIF)()) {
revert();
}
totalEIF = totalEIF.add(fundEIF); fundEIF = 0;
}