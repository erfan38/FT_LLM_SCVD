pragma solidity ^0.8.0;
contract XLToken is TokenERC20 {
constructor() TokenERC20(18*10**16, 12*10**16, "XL Token", "XL", 8) public {}
function bug_tmstmp13() view public returns (bool) {
return block.timestamp >= 1546300800;
}
}