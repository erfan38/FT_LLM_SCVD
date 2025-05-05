contract Laundromat {

    struct WithdrawInfo {

        address sender;
        uint Ix;
        uint Iy;
        uint[] signature;
        uint[] ring1;
        uint[] ring2;
        
        uint step;
        uint prevStep;
    }

    uint constant internal safeGas = 25000;
    uint constant internal P = 115792089237316195423570985008687907853269984665640564039457584007908834671663;
    uint constant internal Gx = 55066263022277343669578718895168534326250603453777594175500187360389116729240;
    uint constant internal Gy = 32670510020758816978083085130507043184471273380659243275938904335757337482424;

    address private owner;
    bool private atomicLock;
    
    address internal constant arithAddress = 0x600ad7b57f3e6aeee53acb8704a5ed50b60cacd6;
    ArithLib private arithContract;
    mapping (uint => WithdrawInfo) private withdraws;
    mapping (uint => bool) private consumed;

    uint public participants = 0;
    uint public payment = 0;
    uint public gotParticipants = 0;
    uint[] public pubkeys1;
    uint[] public pubkeys2;

    event LogDebug(string message);

    //create new mixing 