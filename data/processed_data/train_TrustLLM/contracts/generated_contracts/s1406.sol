1: pragma solidity ^0.8.0;
2: 
3: import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
4: import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
5: import "@openzeppelin/contracts/access/Ownable.sol";
6: 
7: contract Shelter is Ownable {
8:     using SafeERC20 for IERC20;
9: 
10:     uint256 public constant GRACE_PERIOD = 30 days;
11:     mapping(IERC20 => uint256) public activated;
12:     mapping(IERC20 => uint256) public savedTokens;
13:     mapping(IERC20 => mapping(address => bool)) public claimed;
14: 
15:     IClient public client;
16: 
17:     event ExitShelter(IERC20 indexed token, address indexed from, address indexed to, uint256 amount);
18: 
19:     constructor(IClient _client) {
20:         client = _client;
21:     }
22: 
23:     function activateShelter(IERC20 _token) external onlyOwner {
24:         activated[_token] = block.timestamp;
25:     }
26: 
27:     function depositTokens(IERC20 _token, uint256 _amount) external {
28:         _token.safeTransferFrom(msg.sender, address(this), _amount);
29:         savedTokens[_token] += _amount;
30:     }
31: 
32:     function withdraw(IERC20 _token, address _to) external {
33:         require(activated[_token] != 0 && activated[_token] + GRACE_PERIOD < block.timestamp, "shelter not activated");
34:         uint256 amount = savedTokens[_token] * client.shareOf(_token, msg.sender) / client.totalShare(_token);
35:         require(!claimed[_token][_to], "already claimed");
36:         claimed[_token][_to] = true;
37:         emit ExitShelter(_token, msg.sender, _to, amount);
38:         _token.safeTransfer(_to, amount);
39:     }
40: }
41: 
42: interface IClient {
43:     function shareOf(IERC20 _token, address _account) external view returns (uint256);
44:     function totalShare(IERC20 _token) external view returns (uint256);
45: }