1: 1: 1: 1: 1: pragma solidity 0.4.25;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract AlarmClock {
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5:     event _newAlarmClock(address _contract, uint startBlock, uint blockWindow, uint reward, uint gas, bytes _callData);
6: 6: 6: 6: 6:     
7: 7: 7: 7: 7:     address public owner;
8: 8: 8: 8: 8:     
9: 9: 9: 9: 9:     uint public totalTimers;
10: 10: 10: 10: 10:     uint public waitingTimers;
11: 11: 11: 11: 11:     
12: 12: 12: 12: 12:     struct ClockStruct {
13: 13: 13: 13: 13:         address _contract;
14: 14: 14: 14: 14:         uint startBlock;
15: 15: 15: 15: 15:         uint blockWindow;
16: 16: 16: 16: 16:         uint reward;
17: 17: 17: 17: 17:         uint gas;
18: 18: 18: 18: 18:         bytes callData;
19: 19: 19: 19: 19:     }
20: 20: 20: 20: 20:     
21: 21: 21: 21: 21:     
22: 22: 22: 22: 22:     
23: 23: 23: 23: 23:     
24: 24: 24: 24: 24:     
25: 25: 25: 25: 25:     
26: 26: 26: 26: 26:     
27: 27: 27: 27: 27:     ClockStruct[] public clockList;
28: 28: 28: 28: 28:   
29: 29: 29: 29: 29:     constructor () public payable {
30: 30: 30: 30: 30:         owner = msg.sender;
31: 31: 31: 31: 31:         
32: 32: 32: 32: 32:         totalTimers = 0;
33: 33: 33: 33: 33:         waitingTimers = 0;
34: 34: 34: 34: 34:     }  
35: 35: 35: 35: 35:   
36: 36: 36: 36: 36:     modifier ownerOnly() {
37: 37: 37: 37: 37:         require(msg.sender == owner);
38: 38: 38: 38: 38:         _;
39: 39: 39: 39: 39:     }  
40: 40: 40: 40: 40:   
41: 41: 41: 41: 41:     
42: 42: 42: 42: 42:     function setNewOwner(address _newOwner) public ownerOnly {
43: 43: 43: 43: 43:         owner = _newOwner;
44: 44: 44: 44: 44:     }   
45: 45: 45: 45: 45:   
46: 46: 46: 46: 46:     
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48:  
49: 49: 49: 49: 49:   
50: 50: 50: 50: 50:     
51: 51: 51: 51: 51:     function registerAlarmClock(address _contract, uint startBlock, uint blockWindow, uint gas, bytes  _callData) external payable {
52: 52: 52: 52: 52:         
53: 53: 53: 53: 53:         require(gas >= 200000);
54: 54: 54: 54: 54:         require(msg.value > gas);
55: 55: 55: 55: 55:         require(block.number < startBlock);
56: 56: 56: 56: 56:         
57: 57: 57: 57: 57:         clockList.push(ClockStruct(_contract, startBlock, blockWindow, msg.value - gas, gas, _callData));
58: 58: 58: 58: 58:         
59: 59: 59: 59: 59:         
60: 60: 60: 60: 60:         
61: 61: 61: 61: 61:         
62: 62: 62: 62: 62:         
63: 63: 63: 63: 63:         totalTimers++;
64: 64: 64: 64: 64:         waitingTimers++;
65: 65: 65: 65: 65:         
66: 66: 66: 66: 66:         emit _newAlarmClock(_contract, startBlock, blockWindow, msg.value - gas, gas, _callData);
67: 67: 67: 67: 67:     }  
68: 68: 68: 68: 68:   
69: 69: 69: 69: 69: 	
70: 70: 70: 70: 70:     function trigerAlarmClock(uint id) external payable {
71: 71: 71: 71: 71:         
72: 72: 72: 72: 72:         require(clockList[id].reward > 0);
73: 73: 73: 73: 73:         require(block.number >= clockList[id].startBlock);
74: 74: 74: 74: 74:         require(block.number < (clockList[id].startBlock + clockList[id].blockWindow));
75: 75: 75: 75: 75:         
76: 76: 76: 76: 76:         msg.sender.transfer(clockList[id].reward);
77: 77: 77: 77: 77:         clockList[id].reward = 0;
78: 78: 78: 78: 78:         
79: 79: 79: 79: 79:         waitingTimers--;
80: 80: 80: 80: 80: 		
81: 81: 81: 81: 81:         require(clockList[id]._contract.call.value(0).gas(clockList[id].gas)(clockList[id].callData));
82: 82: 82: 82: 82:     }  
83: 83: 83: 83: 83:   
84: 84: 84: 84: 84:     
85: 85: 85: 85: 85:     function() external payable {
86: 86: 86: 86: 86:         
87: 87: 87: 87: 87:     }   
88: 88: 88: 88: 88:     
89: 89: 89: 89: 89:     function _destroyContract() external ownerOnly {
90: 90: 90: 90: 90:         selfdestruct(msg.sender);
91: 91: 91: 91: 91:     }    
92: 92: 92: 92: 92:   
93: 93: 93: 93: 93: }