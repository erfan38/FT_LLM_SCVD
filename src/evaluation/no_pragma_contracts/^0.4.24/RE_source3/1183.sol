contract CentraSale { 

    using SafeMath for uint; 

    address public contract_address = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a; 

    address public owner;
    uint public cap;
    uint public constant cap_max = 170000*10**18;
    uint public constant min_value = 10**18*1/10; 
    uint public operation;
    mapping(uint => address) public operation_address;
    mapping(uint => uint) public operation_amount;

    uint256 public constant token_price = 10**18*1/200;  
    uint256 public tokens_total;  

    uint public constant contract_start = 1505844000;
    uint public constant contract_finish = 1507269600;

    uint public constant card_titanium_minamount = 500*10**18;
    uint public constant card_titanium_first = 200000;
    mapping(address => uint) cards_titanium_check; 
    address[] public cards_titanium;

    uint public constant card_black_minamount = 100*10**18;
    uint public constant card_black_first = 500000;
    mapping(address => uint) public cards_black_check; 
    address[] public cards_black;

    uint public constant card_metal_minamount = 40*10**18;
    uint public constant card_metal_first = 750000;
    mapping(address => uint) cards_metal_check; 
    address[] public cards_metal;      

    uint public constant card_gold_minamount = 30*10**18;
    uint public constant card_gold_first = 1000000;
    mapping(address => uint) cards_gold_check; 
    address[] public cards_gold;      

    uint public constant card_blue_minamount = 5/10*10**18;
    uint public constant card_blue_first = 100000000;
    mapping(address => uint) cards_blue_check; 
    address[] public cards_blue;

    uint public constant card_start_minamount = 1/10*10**18;
    uint public constant card_start_first = 100000000;
    mapping(address => uint) cards_start_check; 
    address[] public cards_start;
      
   
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }      
 
    // Constructor
    function CentraSale() {
        owner = msg.sender; 
        operation = 0; 
        cap = 0;        
    }
      
    //default function for crowdfunding
    function() payable {    

      if(!(msg.value >= min_value)) throw;
      if(now < contract_start) throw;
      if(now > contract_finish) throw;                     

      //if(cap + msg.value > cap_max) throw;         

      tokens_total = msg.value*10**18/token_price;
      if(!(tokens_total > 0)) throw;           

      if(!contract_transfer(tokens_total)) throw;

      cap = cap.add(msg.value); 
      operations();
      get_card();
      owner.send(this.balance);
    }

    //Contract execute
    function contract_transfer(uint _amount) private returns (bool) {      

      if(!contract_address.call(bytes4(sha3("transfer(address,uint256)")),msg.sender,_amount)) {    
        return false;
      }
      return true;
    } 

    //Update operations
    function operations() private returns (bool) {
        operation_address[operation] = msg.sender;
        operation_amount[operation] = msg.value;        
        operation = operation.add(1);        
        return true;
    }    

    //Withdraw money from 