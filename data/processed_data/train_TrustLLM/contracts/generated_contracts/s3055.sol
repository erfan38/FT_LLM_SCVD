1: pragma solidity ^0.8.0;
2: 
3: import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
4: import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
5: 
6: contract VulnerableToken is IERC20 {
7:     using ECDSA for bytes32;
8: 
9:     string public name = "VulnerableToken";
10:     string public symbol = "VTK";
11:     uint8 public decimals = 18;
12:     uint256 public totalSupply;
13:     mapping(address => uint256) public balanceOf;
14:     mapping(address => mapping(address => uint256)) public allowance;
15: 
16:     event Transfer(address indexed from, address indexed to, uint256 value);
17:     event Approval(address indexed owner, address indexed spender, uint256 value);
18: 
19:     constructor(uint256 initialSupply) {
20:         totalSupply = initialSupply * (10 ** uint256(decimals));
21:         balanceOf[msg.sender] = totalSupply;
22:     }
23: 
24:     function transfer(address to, uint256 value) public returns (bool) {
25:         require(to != address(0), "Transfer to the zero address");
26:         require(balanceOf[msg.sender] >= value, "Insufficient balance");
27: 
28:         balanceOf[msg.sender] -= value;
29:         balanceOf[to] += value;
30:         emit Transfer(msg.sender, to, value);
31:         return true;
32:     }
33: 
34:     function approve(address spender, uint256 value) public returns (bool) {
35:         allowance[msg.sender][spender] = value;
36:         emit Approval(msg.sender, spender, value);
37:         return true;
38:     }
39: 
40:     function transferFrom(address from, address to, uint256 value) public returns (bool) {
41:         require(from != address(0), "Transfer from the zero address");
42:         require(to != address(0), "Transfer to the zero address");
43:         require(balanceOf[from] >= value, "Insufficient balance");
44:         require(allowance[from][msg.sender] >= value, "Allowance exceeded");
45: 
46:         balanceOf[from] -= value;
47:         balanceOf[to] += value;
48:         allowance[from][msg.sender] -= value;
49:         emit Transfer(from, to, value);
50:         return true;
51:     }
52: 
53:     error Deadline(uint256 deadline, uint256 currentTime);
54: 
55:     function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual {
56:         if (deadline < block.timestamp) {
57:             revert Deadline(deadline, block.timestamp);
58:         }
59:         // Additional logic for permit function would go here
60:     }
61: }