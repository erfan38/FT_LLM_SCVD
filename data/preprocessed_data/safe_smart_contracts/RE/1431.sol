contract E4RowEscrowU is iE4RowEscrow {

event StatEvent(string msg);
event StatEventI(string msg, uint val);
event StatEventA(string msg, address addr);

        uint constant MAX_PLAYERS = 5;

        enum EndReason  {erWinner, erTimeOut, erCheat}
        enum SettingStateValue  {debug, release, lockedRelease}

        struct gameInstance {
                address[5] players;
                uint[5] playerPots;
                uint numPlayers;

                bool active; // active
                bool allocd; //  allocated already. 
                uint started; // time game started
                uint lastMoved; // time game last moved
                uint payout; // payout amont
                address winner; // address of winner


                EndReason reasonEnded; // enum reason of ended

        }

        struct arbiter {
                mapping (uint => uint)  gameIndexes; // game handles

                uint arbToken; // 2 bytes
                uint gameSlots; // a counter of alloc'd game structs (they can be reused)
                uint gamesStarted; // total games started
                uint gamesCompleted;
                uint gamesCheated;
                uint gamesTimedout;
                uint numPlayers;
                bool registered; 
                bool locked;
        }


        address public  owner;  // owner is address that deployed 