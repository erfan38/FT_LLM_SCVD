1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 
24: 24: 
25: 25: 
26: 26: pragma solidity 0.4.18;
27: 27: contract SimpleMultiSig {
28: 28: 
29: 29:   uint public nonce;                
30: 30:   uint public threshold;            
31: 31:   mapping (address => bool) isOwner; 
32: 32:   address[] public ownersArr;        
33: 33: 
34: 34:   function SimpleMultiSig(uint threshold_, address[] owners_) public {
35: 35:     require(owners_.length <= 10 && threshold_ <= owners_.length && threshold_ != 0);
36: 36: 
37: 37:     address lastAdd = address(0);
38: 38:     for (uint i=0; i<owners_.length; i++) {
39: 39:       require(owners_[i] > lastAdd);
40: 40:       isOwner[owners_[i]] = true;
41: 41:       lastAdd = owners_[i];
42: 42:     }
43: 43:     ownersArr = owners_;
44: 44:     threshold = threshold_;
45: 45:   }
46: 46: 
47: 47:   
48: 48:   function execute(uint8[] sigV, bytes32[] sigR, bytes32[] sigS, address destination, uint value, bytes data) public {
49: 49:     require(sigR.length == threshold);
50: 50:     require(sigR.length == sigS.length && sigR.length == sigV.length);
51: 51: 
52: 52:     
53: 53:     bytes32 txHash = keccak256(byte(0x19), byte(0), address(this), destination, value, data, nonce);
54: 54: 
55: 55:     address lastAdd = address(0); 
56: 56:     for (uint i = 0; i < threshold; i++) {
57: 57:       address recovered = ecrecover(txHash, sigV[i], sigR[i], sigS[i]);
58: 58:       require(recovered > lastAdd && isOwner[recovered]);
59: 59:       lastAdd = recovered;
60: 60:     }
61: 61: 
62: 62:     
63: 63:     nonce = nonce + 1;
64: 64:     require(destination.call.value(value)(data));
65: 65:   }
66: 66: 
67: 67:   function () public payable {}
68: 68: }