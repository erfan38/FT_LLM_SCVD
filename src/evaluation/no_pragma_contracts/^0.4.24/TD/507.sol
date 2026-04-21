contract Escrow {
    using SafeMath for uint256;
    using ContentUtils for ContentUtils.ContentMapping;

    ContentUtils.ContentMapping public content;
    address escrowAddr = address(this);

    uint256 public claimable = 0; 
    uint256 public currentBalance = 0; 
    mapping(bytes32 => uint256) public claimableRewards;

     
    modifier validReward(uint256 _reward) {
        require(_reward > 0 && _depositEscrow(_reward));
        _;
    }

     
    function completeDeliverable(bytes32 _id, address _creator, address _brand) internal returns(bool) {
        require(content.isFulfilled(_id, _creator, _brand));
        content.completeDeliverable(_id);
        return _approveEscrow(_id, content.rewardOf(_id));       
    }

     
    function _depositEscrow(uint256 _amount) internal returns(bool) {
        currentBalance = currentBalance.add(_amount);
        return true;
    }

     
    function _approveEscrow(bytes32 _id, uint256 _amount) internal returns(bool) {
        claimable = claimable.add(_amount);
        claimableRewards[_id] = _amount;
        return true;
    }

    function getClaimableRewards(bytes32 _id) public returns(uint256) {
        return claimableRewards[_id];
    }

    function getContentByName(string _name) public view returns(
        string name,
        string description,
        uint reward,
        uint addedOn) 
    {
        var (_content, exist) = content.getContentByName(_name);
        if (exist) {
            return (_content.name, _content.description, _content.deliverable.reward, _content.addedOn);
        } else {
            return ("", "", 0, 0);
        }
    }

    function currentFulfillment(string _name) public view returns(bool fulfillment) {
        var (_content, exist) = content.getContentByName(_name);
        if (exist) {
            return _content.deliverable.fulfillment[msg.sender];
        } else {
            false;
        }
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








library DeliverableUtils {

    struct Deliverable {
        uint256 reward;
        mapping(address=>bool) fulfillment;
        bool fulfilled;
    }

     
    function fulfill(Deliverable storage self, address _creator, address _brand) internal returns(bool) {
        require(msg.sender == _creator || msg.sender == _brand);
        self.fulfillment[msg.sender] = true;
        return self.fulfillment[_creator] && self.fulfillment[_brand];
    }

     
    function isFulfilled(Deliverable storage self, address _creator, address _brand) internal view returns(bool) {
        return self.fulfillment[_creator] && self.fulfillment[_brand];
    }

     
    function newDeliverable(uint256 _reward) internal pure returns(Deliverable _deliverable) {
        require(_reward > 0);
        return Deliverable(_reward, false);
    }
}

library ContentUtils {
    using SafeMath for uint256;
    using DeliverableUtils for DeliverableUtils.Deliverable;

    struct Content {
        bytes32 id;
        string name;
        string description;
        uint addedOn;
        DeliverableUtils.Deliverable deliverable;
    }

     
    struct ContentMapping {
        mapping(bytes32=>Content) data;
        bytes32[] keys;
        bool locked;
    }

    string constant UNIQUE_KEY_ERR = "Content with ID already exists ";
    string constant KEY_NOT_FOUND_ERR = "Key not found";

     
    function put(ContentMapping storage self, 
        string _name, 
        string _description, 
        uint _reward) public returns (bool) 
    {
            require(!self.locked);

            bytes32 _id = generateContentID(_name);
            require(self.data[_id].id == bytes32(0));

            self.data[_id] = Content(_id, _name, _description, block.timestamp, DeliverableUtils.newDeliverable(_reward));
            self.keys.push(_id);
            return true;
    }
    
     
    function size(ContentMapping storage self) public view returns (uint) {
        return self.keys.length;
    }

     
    function rewardOf(ContentMapping storage self, bytes32 _id) public view returns (uint256) {
        return self.data[_id].deliverable.reward;
    }

    function getKey(ContentMapping storage self, uint _index) public view returns (bytes32) {
        isValidIndex(_index, self.keys.length);
        return self.keys[_index];
    }

     
    function getContentByName(ContentMapping storage self, string _name) public view returns (Content storage _content, bool exists) {
        bytes32 _hash = generateContentID(_name);
        return (self.data[_hash], self.data[_hash].addedOn != 0);
    }

     
    function getContentByID(ContentMapping storage self, bytes32 _id) public view returns (Content storage _content, bool exists) {
        return (self.data[_id], self.data[_id].id == bytes32(0));
    }

     
    function getContentByKeyIndex(ContentMapping storage self, uint _index) public view returns (Content storage _content) {
        isValidIndex(_index, self.keys.length);
        return (self.data[self.keys[_index]]);
    }

     
    function fulfill(ContentMapping storage self, bytes32 _id, address _creator, address _brand) public returns(bool) {
        return self.data[_id].deliverable.fulfill(_creator, _brand);
    }

     
    function isFulfilled(ContentMapping storage self, bytes32 _id, address _creator, address _brand) public view returns(bool) {
        return self.data[_id].deliverable.isFulfilled(_creator, _brand);
    }

     
    function completeDeliverable(ContentMapping storage self, bytes32 _id) internal returns(bool) {
        self.data[_id].deliverable.fulfilled = true;
        return true;
    }

     
    function generateContentID(string _name) public pure returns (bytes32) {
        return keccak256(_name);
    }

     
    function isValidIndex(uint _index, uint _size) public pure {
        require(_index < _size, KEY_NOT_FOUND_ERR);
    }
}



