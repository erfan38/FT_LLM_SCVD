pragma solidity ^0.8.0;
contract BSPMintable is Ownable {
using SafeMath for uint256;
using SafeERC20 for ERC20Basic;

event Mint(uint256 amount);
event DistributorChanged(address indexed previousDistributor, address indexed newDistributor);

address public distributor = 0x4F91C1f068E0dED2B7fF823289Add800E1c26Fc3;


ERC20Basic public BSPToken = ERC20Basic(0x5d551fA77ec2C7dd1387B626c4f33235c3885199);

uint256 constant public rewardAmount = 630000000 * (10 ** 18);

uint256 constant public duration = 4 years;

uint256[4] public miningRate = [40,20,20,20];

bool public started = false;

uint256 public startTime;

uint256 public minted;

modifier whenStarted() {
require(started == true && startTime <= block.timestamp);
_;
}

function startMining(uint256 _startTime) public onlyOwner {

require(started == false && BSPToken.balanceOf(this) >= rewardAmount);


require(_startTime >= block.timestamp);

require(_startTime <= block.timestamp + 60 days);

startTime = _startTime;
started = true;
}