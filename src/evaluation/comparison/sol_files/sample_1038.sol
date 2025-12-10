pragma solidity ^0.8.0;
function getIconiqMaxInvestment(address _investor) public view returns (uint) {
uint iconiqBalance = iconiqToken.balanceOf(_investor);
uint prorataLimit = iconiqBalance.div(ICONIQ_TOKENS_NEEDED_PER_INVESTED_WEI);


require(prorataLimit >= investments[_investor].totalWeiInvested);
return prorataLimit.sub(investments[_investor].totalWeiInvested);
}