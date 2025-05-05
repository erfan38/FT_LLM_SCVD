contract E4RowEscrow {

event StatEvent(string msg);
event StatEventI(string msg, uint val);
event StatEventA(string msg, address addr);

        uint constant MAX_PLAYERS = 5;

        enum EndReason  {erWinner, erTimeOut, erCancel}
        enum SettingStateValue  {debug, release, lockedRelease}

        struct gameInstance {
                bool active;           // active
                bool allocd;           // allocated already. 
                EndReason reasonEnded; // enum reason of ended
                uint8 numPlayers;
                uint128 totalPot;      // total of all bets
                uint128[5] playerPots; // individual deposits
                address[5] players;    // player addrs
                uint lastMoved;        // time game last moved
        }

        struct arbiter {
                mapping (uint => uint)  gameIndexes; // game handles
                bool registered; 
                bool locked;
                uint8 numPlayers;
                uint16 arbToken;         // 2 bytes
                uint16 escFeePctX10;     // escrow fee -- frac of 1000
                uint16 arbFeePctX10;     // arbiter fee -- frac of 1000
                uint32 gameSlots;        // a counter of alloc'd game structs (they can be reused)
                uint128 feeCap;          // max fee (escrow + arb) in wei
                uint128 arbHoldover;     // hold accumulated gas credits and arbiter fees
        }


        address public  owner;  // owner is address that deployed 