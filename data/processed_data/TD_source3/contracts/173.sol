contract LastUnicorn is modularLastUnicorn {
    using SafeMath for *;
    using NameFilter for string;
    using RSKeysCalc for uint256;
	
     
    UnicornInterfaceForForwarder constant private TeamUnicorn = UnicornInterfaceForForwarder(0xBB14004A6f3D15945B3786012E00D9358c63c92a);
	UnicornBookInterface constant private UnicornBook = UnicornBookInterface(0x98547788f328e1011065E4068A8D72bacA1DDB49);

    string constant public name = "LastUnicorn Round #1";
    string constant public symbol = "RS1";
    uint256 private rndGap_ = 0;

     
    uint256 constant private rndInit_ = 1 hours;                 
    uint256 constant private rndInc_ = 30 seconds;               
    uint256 constant private rndMax_ = 24 hours;                 
 
 
 
 
	uint256 public airDropPot_;              
    uint256 public airDropTracker_ = 0;      
 
 
 
    mapping (address => uint256) public pIDxAddr_;           
    mapping (bytes32 => uint256) public pIDxName_;           
    mapping (uint256 => RSdatasets.Player) public plyr_;    
    mapping (uint256 => RSdatasets.PlayerRounds) public plyrRnds_;     
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;  
 
 
 
    RSdatasets.Round public round_;    
 
 
 
    uint256 public fees_ = 60;           
    uint256 public potSplit_ = 45;      
 
 
 
 
    constructor()
        public
    {
	}
 
 
 
 
     
    modifier isActivated() {
        require(activated_ == true, "its not ready yet"); 
        _;
    }
    
     
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "non smart 