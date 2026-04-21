contract RedpacketVaultV2 {
    using SafeMath for uint256;
    ERC20Interface private erc20;
    
    address public erc20Address;
    uint256 public totalAmount = 0; // Total amount of deposit
    uint256 public totalBalance = 0; // Total balance of deposit after Withdrawal

    struct Commitment {                     // Deposit Commitment
        uint256         status;             // If there is no this commitment or balance is zeor, false
        uint256         amount;             // Deposit balance
        address payable sender;             // Who make this deposit
        uint256         timestamp;          // Deposit timestamp
        string          memo;               // Memo while send redpacket
        address[]       takenAddresses;     // 
        uint256         withdrawTimes;
        uint256         cliff;
    }

    mapping(bytes32 => Commitment) private commitments; 
    mapping(address => bytes32[]) private hashKeys;
    
    address public operator;
    address public redpacketManagerAddress;

    modifier onlyOperator {
        require(msg.sender == operator, "Only operator can call this function.");
        _;
    }

    modifier onlyRedpacketManager {
        require(msg.sender == redpacketManagerAddress, "Only redpacket manager 