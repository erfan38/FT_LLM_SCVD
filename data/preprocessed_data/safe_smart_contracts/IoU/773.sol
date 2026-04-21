contract SafeTokenMinter {
 uint256 public totalSupply;
 uint256 public constant MAX_SUPPLY = 1000000;
 function mint(uint256 amount) public {
 require(totalSupply + amount <= MAX_SUPPLY, 'Would exceed max supply');
 totalSupply += amount;
 }
}