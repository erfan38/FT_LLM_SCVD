contract AddressOwnershipVerification {
    mapping(address => mapping (uint32 => address)) _requests;        // Pending requests (transactee address => (deposit => transactor address)
    mapping(address => mapping (address => uint32)) _requestsReverse; // Used for reverse lookups  (transactee address => (transactor address => deposit)
    mapping(address => mapping (address => uint32)) _verifications;   // Verified requests (transactor address => (transactee address => deposit)

    event RequestEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit);      // Event is triggered when a new request is added
    event RemoveRequestEvent(address indexed transactor, address indexed transactee);                        // Event is triggered when an unverified request is removed
    event VerificationEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit); // Event is triggered when someone proves ownership of an address
    event RevokeEvent(address indexed transactor, address indexed transactee, uint32 indexed deposit);       // Event is triggered when either party removes a trust

    function AddressOwnershipVerification() {}

    // Used to verify pending requests by transactee sending deposit to this 