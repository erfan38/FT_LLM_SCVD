contract POOHMOX is POOHMOXevents {
    using SafeMath for *;
    using NameFilter for string;
    using KeysCalc for uint256;

    PlayerBookInterface private PlayerBook;

//==============================================================================
//     _ _  _  |`. _     _ _ |_ | _  _  .
//    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (game settings)
//=================_|===========================================================
    address private admin = msg.sender;
    address private flushDivs;
    string constant public name = "POOHMOX";
    string constant public symbol = "POOHMOX";
    uint256 private rndExtra_ = 1 seconds;     // length of the very first ICO phase
    uint256 private rndGap_ = 1 seconds;       // length of ICO phases
    uint256 private rndInit_ = 5 minutes;      // round timer starts at this
    uint256 private rndMax_ = 5 minutes;       // max length a round timer can be  (for first round) 
    uint256 constant private rndInc_ = 5 minutes;// every full key purchased adds this much to the timer
                                 
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .  (data used to store game info that changes)
//=============================|================================================
    uint256 public rID_;    // round id number / total rounds that have happened
//****************
// PLAYER DATA
//****************
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => POOHMOXDatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => POOHMOXDatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
//****************
// ROUND DATA
//****************
    mapping (uint256 => POOHMOXDatasets.Round) public round_;   // (rID => data) round data
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id
//****************
// TEAM FEE DATA
//****************
    mapping (uint256 => POOHMOXDatasets.TeamFee) public fees_;          // (team => fees) fee distribution by team
    mapping (uint256 => POOHMOXDatasets.PotSplit) public potSplit_;     // (team => fees) pot split distribution by team
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon 