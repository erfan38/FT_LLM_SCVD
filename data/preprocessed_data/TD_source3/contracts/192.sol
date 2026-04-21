contract RatScam is modularRatScam {
    using SafeMath for *;
    using NameFilter for string;
    using RSKeysCalc for uint256;

     
    address constant private adminAddress = 0xFAdb9139a33a4F2FE67D340B6AAef0d04E9D5681;
    RatBookInterface constant private RatBook = RatBookInterface(0x3257d637b8977781b4f8178365858a474b2a6195);

    string constant public name = "RatScam In One Hour";
    string constant public symbol = "RS";
    uint256 private rndGap_ = 0;

     
    uint256 constant private rndInit_ = 1 hours;                 
    uint256 constant private rndInc_ = 30 seconds;               
    uint256 constant private rndMax_ = 1 hours;                 
     
     
     
     
    uint256 public airDropPot_;              
    uint256 public airDropTracker_ = 0;      
    uint256 public rID_;     
     
     
     
    mapping (address => uint256) public pIDxAddr_;           
    mapping (bytes32 => uint256) public pIDxName_;           
    mapping (uint256 => RSdatasets.Player) public plyr_;    
    mapping (uint256 => mapping (uint256 => RSdatasets.PlayerRounds)) public plyrRnds_;     
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;  
     
     
     
     
    mapping (uint256 => RSdatasets.Round) public round_;    
     
     
     
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