pragma solidity ^0.8.0;
function newRefPayStation(address newAddress) onlyOwner public {
refPayStation = ReferralPayStation(newAddress);

emit OnNewRefPayStation(newAddress, now);
}
}