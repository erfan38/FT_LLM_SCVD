1: pragma solidity ^0.8.0;
2: 
3: import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
4: import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
5: 
6: contract VulnerablePool {
7:     using EnumerableSet for EnumerableSet.AddressSet;
8: 
9:     struct PoolInfo {
10:         address nftContract;
11:         uint256 totalSupply;
12:         uint48 terminationPeriod;
13:         bool success;
14:         bytes32 merkleRoot;
15:     }
16: 
17:     mapping(uint256 => PoolInfo) public poolInfo;
18:     EnumerableSet.AddressSet private participants;
19: 
20:     error InvalidState();
21: 
22:     function createPool(
23:         uint256 _poolId,
24:         address _nftContract,
25:         uint256 _totalSupply,
26:         uint48 _terminationPeriod,
27:         bytes32 _merkleRoot
28:     ) external {
29:         poolInfo[_poolId] = PoolInfo({
30:             nftContract: _nftContract,
31:             totalSupply: _totalSupply,
32:             terminationPeriod: _terminationPeriod,
33:             success: false,
34:             merkleRoot: _merkleRoot
35:         });
36:     }
37: 
38:     function _verifyUnsuccessfulState(uint256 _poolId) internal view returns (address, uint48, uint40, bool, bytes32) {
39:         PoolInfo memory pool = poolInfo[_poolId];
40:         if (pool.success || block.timestamp > pool.terminationPeriod) revert InvalidState();
41:         return (pool.nftContract, pool.totalSupply, pool.terminationPeriod, pool.success, pool.merkleRoot);
42:     }
43: 
44:     function participateInPool(uint256 _poolId) external {
45:         (address nftContract, uint48 totalSupply, uint48 terminationPeriod, bool success, bytes32 merkleRoot) = _verifyUnsuccessfulState(_poolId);
46:         require(totalSupply > 0, "No tokens available for participation");
47:         participants.add(msg.sender);
48:         // Additional logic for participation can be added here
49:     }
50: 
51:     function getPoolInfo(uint256 _poolId) external view returns (PoolInfo memory) {
52:         return poolInfo[_poolId];
53:     }
54: 
55:     function isParticipant(address _participant) external view returns (bool) {
56:         return participants.contains(_participant);
57:     }
58: }