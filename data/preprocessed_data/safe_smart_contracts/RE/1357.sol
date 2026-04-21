contract E4Lava is Token, E4LavaRewards {
        event StatEvent(string msg);
        event StatEventI(string msg, uint val);

        enum SettingStateValue  {debug, lockedRelease}

        struct tokenAccount {
                bool alloced;       // flag to ascert prior allocation
                uint tokens;        // num tokens currently held in this acct
                uint currentPoints; // updated before token balance changes, or before a withdrawal. credit for owning tokens
                uint lastSnapshot;  // snapshot of global TotalPoints, last time we updated this acct's currentPoints
        }

// -----------------------------
//  data storage
// ----------------------------------------
        uint constant NumOrigTokens         = 5762;   // number of old tokens, from original token 