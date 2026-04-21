pragma solidity ^0.8.0;
contract SpaceWar  {
using NumericSequence for uint;
using SafeMath for uint;

struct MinerData
{
uint256[9]   spaces;
uint8[3]     hasUpgrade;
uint256      money;
uint256      lastUpdateTime;
uint256      premamentMineBonusPct;
uint256      unclaimedPot;
uint256      lastPotClaimIndex;
}

struct SpaceData
{
uint256 basePrice;
uint256 baseOutput;
uint256 pricePerLevel;
uint256 priceInETH;
uint256 limit;
}

struct BoostData
{
uint256 percentBonus;
uint256 priceInWEI;
}

struct PVPData
{
uint256[6] troops;
uint256    immunityTime;
uint256    exhaustTime;
}

struct TroopData
{
uint256 attackPower;
uint256 defensePower;
uint256 priceGold;
uint256 priceETH;
}

uint8 private constant NUMBER_OF_RIG_TYPES = 9;
SpaceData[9]  private spaceData;

uint8 private constant NUMBER_OF_UPGRADES = 3;
BoostData[3] private boostData;

uint8 private constant NUMBER_OF_TROOPS = 6;
uint8 private constant ATTACKER_START_IDX = 0;
uint8 private constant ATTACKER_END_IDX = 3;
uint8 private constant DEFENDER_START_IDX = 3;
uint8 private constant DEFENDER_END_IDX = 6;
TroopData[6] private troopData;


uint256 private honeyPotAmount;
uint256 private honeyPotSharePct;
uint256 private jackPot;
uint256 private devFund;
uint256 private nextPotDistributionTime;
mapping(address => mapping(uint256 => uint256)) private minerICOPerCycle;
uint256[] private honeyPotPerCycle;
uint256[] private globalICOPerCycle;
uint256 private cycleCount;


uint256 private constant NUMBER_OF_BOOSTERS = 5;
uint256 private boosterIndex;
uint256 private nextBoosterPrice;
address[5] private boosterHolders;

mapping(address => MinerData) private miners;
mapping(address => PVPData)   private pvpMap;
mapping(uint256 => address)   private indexes;
uint256 private topindex;

address private owner;




function SpaceWar() public {
owner = msg.sender;


spaceData[0] = SpaceData(500,             1,        5,               0,          999);
spaceData[1] = SpaceData(50000,           10,       500,             0,          999);
spaceData[2] = SpaceData(5000000,         100,      50000,           0,          999);
spaceData[3] = SpaceData(80000000,        1000,     800000,          0,          999);
spaceData[4] = SpaceData(500000000,       20000,    5000000,         0.01 ether, 999);
spaceData[5] = SpaceData(10000000000,     100000,   100000000,       0,          999);
spaceData[6] = SpaceData(100000000000,    1000000,  1000000000,      0,          999);
spaceData[7] = SpaceData(1000000000000,   50000000, 10000000000,     0.1 ether,  999);
spaceData[8] = SpaceData(10000000000000,  100000000,100000000000,    0,          999);

boostData[0] = BoostData(30,  0.01 ether);
boostData[1] = BoostData(50,  0.1 ether);
boostData[2] = BoostData(100, 1 ether);

topindex = 0;
honeyPotAmount = 0;
devFund = 0;
jackPot = 0;
nextPotDistributionTime = block.timestamp;
honeyPotSharePct = 90;


boosterHolders[0] = owner;
boosterHolders[1] = owner;
boosterHolders[2] = owner;
boosterHolders[3] = owner;
boosterHolders[4] = owner;

boosterIndex = 0;
nextBoosterPrice = 0.1 ether;


troopData[0] = TroopData(10,     0,      100000,   0);
troopData[1] = TroopData(1000,   0,      80000000, 0);
troopData[2] = TroopData(100000, 0,      1000000000,   0.01 ether);
troopData[3] = TroopData(0,      15,     100000,   0);
troopData[4] = TroopData(0,      1500,   80000000, 0);
troopData[5] = TroopData(0,      150000, 1000000000,   0.01 ether);

honeyPotPerCycle.push(0);
globalICOPerCycle.push(1);
cycleCount = 0;
}