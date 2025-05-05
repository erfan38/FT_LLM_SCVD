contract XTVNetworkGuard {
  mapping(address => bool) xtvNetworkEndorser;

  modifier validateSignature(
    string memory message,
    bytes32 verificationHash,
    bytes memory xtvSignature
  ) {
    bytes32 xtvVerificationHash = keccak256(abi.encodePacked(verificationHash, message));

    require(verifyXTVSignature(xtvVerificationHash, xtvSignature));
    _;
  }

  function setXTVNetworkEndorser(address _addr, bool isEndorser) public;

  function verifyXTVSignature(bytes32 hash, bytes memory sig) public view returns (bool) {
    address signerAddress = XTVNetworkUtils.verifyXTVSignatureAddress(hash, sig);

    return xtvNetworkEndorser[signerAddress];
  }
}
 




 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
 




 


 
