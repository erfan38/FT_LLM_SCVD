contract E4Token is Token, E4RowRewards {
        event StatEvent(string msg);
        event StatEventI(string msg, uint val);

        enum SettingStateValue  {debug, release, lockedRelease}
        enum IcoStatusValue {anouncement, saleOpen, saleClosed, failed, succeeded}




        struct tokenAccount {
                bool alloced; // flag to ascert prior allocation
                uint tokens; // num tokens
                uint balance; // rewards balance
        }
// -----------------------------
//  data storage
// ----------------------------------------
        address developers; // developers token holding address
        address public owner; // deployer executor
        address founderOrg; // founder orginaization 