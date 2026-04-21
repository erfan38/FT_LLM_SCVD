pragma solidity ^0.4.23;

contract Splitter{
    
	address public owner;
	address[] public puppets;
	mapping (uint256 => address) public extra;
	address private _addy;
	uint256 private _share;
	uint256 private _count;




	constructor() payable public{
		owner = msg.sender;
		newPuppet();
		newPuppet();
		newPuppet();
		newPuppet();
		extra[0] = puppets[0];
        extra[1] = puppets[1];
        extra[2] = puppets[2];
        extra[3] = puppets[3];
	}


	
	function withdraw() public{
		require(msg.sender == owner);
		owner.transfer(address(this).balance);
	}



	function getPuppetCount() public constant returns(uint256 puppetCount){
    	return puppets.length;
  	}



	function newPuppet() public returns(address newPuppet){
	    require(msg.sender == owner);
    	Puppet p = new Puppet();
    	puppets.push(p);
    	return p;
  		}
 


    function setExtra(uint256 _id, address _newExtra) public {
        require(_newExtra != address(0));
        extra[_id] = _newExtra;
    }

	


    function fundPuppets() public payable {
        require(msg.sender == owner);
    	_share = SafeMath.div(msg.value, 4);
        extra[0].call.value(_share).gas(800000)();
        extra[1].call.value(_share).gas(800000)();
        extra[2].call.value(_share).gas(800000)();
        extra[3].call.value(_share).gas(800000)();
        }
        


function() payable public{
	}
}

