pragma solidity ^0.8.0;
}




interface ITokenPorter {
event ExportOnChainClaimedReceiptLog(address indexed destinationMetronomeAddr,
address indexed destinationRecipientAddr, uint amount);

event ExportReceiptLog(bytes8 destinationChain, address destinationMetronomeAddr,
address indexed destinationRecipientAddr, uint amountToBurn, uint fee, bytes extraData, uint currentTick,
uint indexed burnSequence, bytes32 indexed currentBurnHash, bytes32 prevBurnHash, uint dailyMintable,
uint[] supplyOnAllChains, uint genesisTime, uint blockTimestamp, uint dailyAuctionStartTime);

event ImportReceiptLog(address indexed destinationRecipientAddr, uint amountImported,
uint fee, bytes extraData, uint currentTick, uint indexed importSequence,
bytes32 indexed currentHash, bytes32 prevHash, uint dailyMintable, uint blockTimestamp, address caller);

function export(address tokenOwner, bytes8 _destChain, address _destMetronomeAddr,
address _destRecipAddr, uint _amount, uint _fee, bytes _extraData) public returns (bool);

function importMET(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData,
bytes32[] _burnHashes, uint[] _supplyOnAllChains, uint[] _importData, bytes _proof) public returns (bool);

}



contract TokenPorter is ITokenPorter, Owned {
using SafeMath for uint;
Auctions public auctions;
METToken public token;
Validator public validator;
ChainLedger public chainLedger;

uint public burnSequence = 1;
uint public importSequence = 1;
bytes32[] public exportedBurns;
uint[] public supplyOnAllChains = new uint[](6);


mapping(bytes8 => address) public destinationChains;




function initTokenPorter(address _tokenAddr, address _auctionsAddr) public onlyOwner {
require(_tokenAddr != 0x0);
require(_auctionsAddr != 0x0);
auctions = Auctions(_auctionsAddr);
token = METToken(_tokenAddr);
}