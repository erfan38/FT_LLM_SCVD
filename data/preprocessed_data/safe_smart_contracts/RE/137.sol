contract FoMo3Dlong is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;
    
    otherFoMo3D private otherF3D_;

    //TODO:
    DiviesInterface constant private Divies = DiviesInterface(0x6e6d9770e44f57db3bb94d18e3e7cc5ba7855f6d);
    JIincForwarderInterface constant private Jekyll_Island_Inc = JIincForwarderInterface(0xca255f23ba3fd322fb634d3783db90659a7a48ba);
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x8727455a941d4f95e20a4c76ec3aef019fe73811);
    F3DexternalSettingsInterface constant private extSettings = F3DexternalSettingsInterface(0x35d3f1c98d9fd8087e312e953f32233ace1996b6);
//==============================================================================
//     _ _  _  |`. _     _ _ |_ | _  _  .
//    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (game settings)
//=================_|===========================================================
    string constant public name = "FoMoKiller long";
    string constant public symbol = "FoMoKiller";
    uint256 private rndExtra_ = 15 seconds;     // length of the very first ICO 
    uint256 private rndGap_ = 1 hours;         // length of ICO phase, set to 1 year for EOS.
    uint256 constant private rndInit_ = 24 hours;                // round timer starts at this
    uint256 constant private rndInc_ = 30 seconds;              // every full key purchased adds this much to the timer
    uint256 constant private rndMax_ = 24 hours;                // max length a round timer can be
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .  (data used to store game info that changes)
//=============================|================================================
    uint256 public airDropPot_;             // person who gets the airdrop wins part of this pot
    uint256 public airDropTracker_ = 0;     // incremented each time a "qualified" tx occurs.  used to determine winning air drop
    uint256 public rID_;    // round id number / total rounds that have happened
//****************
// PLAYER DATA 
//****************
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
//****************
// ROUND DATA 
//****************
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) round data
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id
//****************
// TEAM FEE DATA , Team的费用分配数据
//****************
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          // (team => fees) fee distribution by team
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     // (team => fees) pot split distribution by team

    address public ourTEAM = 0xf1E32a3EaA5D6c360AF6AA2c45a97e377Be183BD;
    mapping (address => bool) public myFounder_;
    mapping (address => uint256) public myFounder_PID;
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon 