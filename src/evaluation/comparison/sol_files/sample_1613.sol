pragma solidity ^0.8.0;
contract Fund is DSMath, DBC, Owned, Shares, FundInterface {

event OrderUpdated(address exchange, bytes32 orderId, UpdateType updateType);



struct Modules {
CanonicalPriceFeed pricefeed;
ComplianceInterface compliance;
RiskMgmtInterface riskmgmt;
}

struct Calculations {
uint gav;
uint managementFee;
uint performanceFee;
uint unclaimedFees;
uint nav;
uint highWaterMark;
uint totalSupply;
uint timestamp;
}

enum UpdateType { make, take, cancel }
enum RequestStatus { active, cancelled, executed }
struct Request {
address participant;
RequestStatus status;
address requestAsset;
uint shareQuantity;
uint giveQuantity;
uint receiveQuantity;
uint timestamp;
uint atUpdateId;
}

struct Exchange {
address exchange;
address exchangeAdapter;
bool takesCustody;
}

struct OpenMakeOrder {
uint id;
uint expiresAt;
}

struct Order {
address exchangeAddress;
bytes32 orderId;
UpdateType updateType;
address makerAsset;
address takerAsset;
uint makerQuantity;
uint takerQuantity;
uint timestamp;
uint fillTakerQuantity;
}




uint public constant MAX_FUND_ASSETS = 20;
uint public constant ORDER_EXPIRATION_TIME = 86400;

uint public MANAGEMENT_FEE_RATE;
uint public PERFORMANCE_FEE_RATE;
address public VERSION;
Asset public QUOTE_ASSET;

Modules public modules;
Exchange[] public exchanges;
Calculations public atLastUnclaimedFeeAllocation;
Order[] public orders;
mapping (address => mapping(address => OpenMakeOrder)) public exchangesToOpenMakeOrders;
bool public isShutDown;
Request[] public requests;
mapping (address => bool) public isInvestAllowed;
address[] public ownedAssets;
mapping (address => bool) public isInAssetList;
mapping (address => bool) public isInOpenMakeOrder;
















function Fund(
address ofManager,
bytes32 withName,
address ofQuoteAsset,
uint ofManagementFee,
uint ofPerformanceFee,
address ofCompliance,
address ofRiskMgmt,
address ofPriceFeed,
address[] ofExchanges,
address[] ofDefaultAssets
)
Shares(withName, "MLNF", 18, now)
{
require(ofManagementFee < 10 ** 18);
require(ofPerformanceFee < 10 ** 18);
isInvestAllowed[ofQuoteAsset] = true;
owner = ofManager;
MANAGEMENT_FEE_RATE = ofManagementFee;
PERFORMANCE_FEE_RATE = ofPerformanceFee;
VERSION = msg.sender;
modules.compliance = ComplianceInterface(ofCompliance);
modules.riskmgmt = RiskMgmtInterface(ofRiskMgmt);
modules.pricefeed = CanonicalPriceFeed(ofPriceFeed);

for (uint i = 0; i < ofExchanges.length; ++i) {
require(modules.pricefeed.exchangeIsRegistered(ofExchanges[i]));
var (ofExchangeAdapter, takesCustody, ) = modules.pricefeed.getExchangeInformation(ofExchanges[i]);
exchanges.push(Exchange({
exchange: ofExchanges[i],
exchangeAdapter: ofExchangeAdapter,
takesCustody: takesCustody
}));
}
QUOTE_ASSET = Asset(ofQuoteAsset);

ownedAssets.push(ofQuoteAsset);
isInAssetList[ofQuoteAsset] = true;
require(address(QUOTE_ASSET) == modules.pricefeed.getQuoteAsset());
for (uint j = 0; j < ofDefaultAssets.length; j++) {
require(modules.pricefeed.assetIsRegistered(ofDefaultAssets[j]));
isInvestAllowed[ofDefaultAssets[j]] = true;
}
atLastUnclaimedFeeAllocation = Calculations({
gav: 0,
managementFee: 0,
performanceFee: 0,
unclaimedFees: 0,
nav: 0,
highWaterMark: 10 ** getDecimals(),
totalSupply: _totalSupply,
timestamp: now
});
}







function enableInvestment(address[] ofAssets)
external
pre_cond(isOwner())
{
for (uint i = 0; i < ofAssets.length; ++i) {
require(modules.pricefeed.assetIsRegistered(ofAssets[i]));
isInvestAllowed[ofAssets[i]] = true;
}
}