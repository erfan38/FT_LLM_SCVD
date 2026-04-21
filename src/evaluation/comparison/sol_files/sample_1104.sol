pragma solidity ^0.8.0;
bool public activated_ = false;
function activate()
public
{

require(msg.sender == admin, "only admin can activate");



require(activated_ == false, "FOMO Short already activated");


activated_ = true;


rID_ = 1;
round_[1].strt = now + rndExtra_ - rndGap_;
round_[1].end = now + rndInit_ + rndExtra_;
}