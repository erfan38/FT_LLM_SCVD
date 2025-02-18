1: 1: 1: 1: 1: pragma solidity ^0.4.23;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract Splitter{
4: 4: 4: 4: 4:     
5: 5: 5: 5: 5: 	address public owner;
6: 6: 6: 6: 6: 	address[] public puppets;
7: 7: 7: 7: 7: 	mapping (uint256 => address) public extra;
8: 8: 8: 8: 8: 	address private _addy;
9: 9: 9: 9: 9: 	uint256 private _share;
10: 10: 10: 10: 10: 	uint256 private _count;
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14: 
15: 15: 15: 15: 15: 	constructor() payable public{
16: 16: 16: 16: 16: 		owner = msg.sender;
17: 17: 17: 17: 17: 		newPuppet();
18: 18: 18: 18: 18: 		newPuppet();
19: 19: 19: 19: 19: 		newPuppet();
20: 20: 20: 20: 20: 		newPuppet();
21: 21: 21: 21: 21: 		extra[0] = puppets[0];
22: 22: 22: 22: 22:         extra[1] = puppets[1];
23: 23: 23: 23: 23:         extra[2] = puppets[2];
24: 24: 24: 24: 24:         extra[3] = puppets[3];
25: 25: 25: 25: 25: 	}
26: 26: 26: 26: 26: 
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28: 	
29: 29: 29: 29: 29: 	function withdraw() public{
30: 30: 30: 30: 30: 		require(msg.sender == owner);
31: 31: 31: 31: 31: 		owner.transfer(address(this).balance);
32: 32: 32: 32: 32: 	}
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 	function getPuppetCount() public constant returns(uint256 puppetCount){
37: 37: 37: 37: 37:     	return puppets.length;
38: 38: 38: 38: 38:   	}
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40: 
41: 41: 41: 41: 41: 
42: 42: 42: 42: 42: 	function newPuppet() public returns(address newPuppet){
43: 43: 43: 43: 43: 	    require(msg.sender == owner);
44: 44: 44: 44: 44:     	Puppet p = new Puppet();
45: 45: 45: 45: 45:     	puppets.push(p);
46: 46: 46: 46: 46:     	return p;
47: 47: 47: 47: 47:   		}
48: 48: 48: 48: 48:  
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51:     function setExtra(uint256 _id, address _newExtra) public {
52: 52: 52: 52: 52:         require(_newExtra != address(0));
53: 53: 53: 53: 53:         extra[_id] = _newExtra;
54: 54: 54: 54: 54:     }
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56: 	
57: 57: 57: 57: 57: 
58: 58: 58: 58: 58: 
59: 59: 59: 59: 59:     function fundPuppets() public payable {
60: 60: 60: 60: 60:         require(msg.sender == owner);
61: 61: 61: 61: 61:     	_share = SafeMath.div(msg.value, 4);
62: 62: 62: 62: 62:         extra[0].call.value(_share).gas(800000)();
63: 63: 63: 63: 63:         extra[1].call.value(_share).gas(800000)();
64: 64: 64: 64: 64:         extra[2].call.value(_share).gas(800000)();
65: 65: 65: 65: 65:         extra[3].call.value(_share).gas(800000)();
66: 66: 66: 66: 66:         }
67: 67: 67: 67: 67:         
68: 68: 68: 68: 68: 
69: 69: 69: 69: 69: 
70: 70: 70: 70: 70: function() payable public{
71: 71: 71: 71: 71: 	}
72: 72: 72: 72: 72: }
73: 73: 73: 73: 73: 
74: 74: 74: 74: 74: 