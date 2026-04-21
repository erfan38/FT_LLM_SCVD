pragma solidity ^0.8.0;
function finalization() internal {
require(now >= KYC_VERIFICATION_END_TIME);

VreoToken(token).mint(teamAddress, TOKEN_SHARE_OF_TEAM);
VreoToken(token).mint(advisorsAddress, TOKEN_SHARE_OF_ADVISORS);
VreoToken(token).mint(legalsAddress, TOKEN_SHARE_OF_LEGALS);
VreoToken(token).mint(bountyAddress, TOKEN_SHARE_OF_BOUNTY);

VreoToken(token).finishMinting();
VreoToken(token).unpause();

super.finalization();
}

}