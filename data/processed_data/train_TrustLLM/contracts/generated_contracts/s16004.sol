1: pragma solidity ^0.8.0;
2: 
3: import "@openzeppelin/contracts/access/Ownable.sol";
4: 
5: contract NFTOracle is Ownable {
6:     struct AssetPrice {
7:         uint256 twap; // Time-weighted average price
8:         uint256 updatedAt; // Block number when the price was last updated
9:     }
10: 
11:     mapping(address => AssetPrice) public assetPriceMap;
12:     uint256 public expirationPeriod; // Time period after which the price is considered expired
13: 
14:     event PriceUpdated(address indexed asset, uint256 price);
15: 
16:     constructor(uint256 _expirationPeriod) {
17:         expirationPeriod = _expirationPeriod;
18:     }
19: 
20:     function updatePrice(address _asset, uint256 _price) external onlyOwner {
21:         assetPriceMap[_asset] = AssetPrice({
22:             twap: _price,
23:             updatedAt: block.number
24:         });
25:         emit PriceUpdated(_asset, _price);
26:     }
27: 
28:     function getPrice(address _asset) external view returns (uint256 price) {
29:         uint256 updatedAt = assetPriceMap[_asset].updatedAt;
30:         require((block.number - updatedAt) <= expirationPeriod, "NFTOracle: asset price expired");
31:         return assetPriceMap[_asset].twap;
32:     }
33: 
34:     function setExpirationPeriod(uint256 _newExpirationPeriod) external onlyOwner {
35:         expirationPeriod = _newExpirationPeriod;
36:     }
37: }