pragma solidity >=0.5.0 <0.6.0;









library SafeMathUint256 {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Multiplier exception");
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b; 
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction exception");
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Addition exception");
        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Modulo exception");
        return a % b;
    }

}





library SafeMathUint8 {
    


    function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Multiplier exception");
        return c;
    }

    


    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        return a / b; 
    }

    


    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a, "Subtraction exception");
        return a - b;
    }

    


    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {
        c = a + b;
        require(c >= a, "Addition exception");
        return c;
    }

    



    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b != 0, "Modulo exception");
        return a % b;
    }

}

contract MultiSigRoot is Label {
    using SafeMathUint8 for uint8;
    using SafeMathUint256 for uint256;

    uint8 constant private WALLET_TYPE_WALLET = 1;
    uint8 constant private WALLET_TYPE_NODE = 2;

    uint8 constant private TRANSACTION_STATUS_EMPTY = 0;
    uint8 constant private TRANSACTION_STATUS_PENDING = 1;
    uint8 constant private TRANSACTION_STATUS_EXECUTED = 2;
    uint8 constant private TRANSACTION_STATUS_FAILURE = 3;
    uint8 constant private TRANSACTION_STATUS_REVOKED = 4;

    event Confirmation(address indexed sender, uint256 indexed transactionCode);
    event Revocation(address indexed sender, uint256 indexed transactionCode);
    event Submission(uint256 indexed transactionCode);
    event Requirement(uint256 indexed transactionCode, bytes32 labelCode, uint256 flag, uint8 required);
    event Execution(uint256 indexed transactionCode);
    event ExecutionFailure(uint256 indexed transactionCode);
    event Deposit(address indexed sender, uint256 value);

    event StakersChanged(address indexed stakers);
    event SignersChanged(address indexed signers);
    event RegulatorChanged(address indexed regulator);
    event StakersControllerChanged(address indexed stakersController);
    event SignersControllerChanged(address indexed signersController);
    
    event WalletOrNodeAttached(address indexed wallet);
    event WalletOrNodeDetached(address indexed wallet);
    
    address public stakers;
    address public signers;

    address public stakersController;
    address public signersController;

    address public regulator;

    
    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCode;

    
    mapping(uint256 => mapping(bytes32 => TransactionRequirement)) public requirements;
    
    mapping(uint256 => mapping(address => bool)) public confirmations;

    
    mapping(address => uint8) public registered;

    
    mapping(address => address) public walletToNodes;

    
    mapping(address => uint8) private walletToIndexes;

    
    mapping(address => bytes32) private walletToLabelCodes;

    
    mapping(bytes32 => address) private labelCodeToNodes;

    struct Transaction {
        uint8 status;
        uint8 totalRequired;

        address to;
        uint256 value;
        bytes data;
        string reason;
    }

    struct TransactionRequirement {
        uint8 required;
        uint256 flag;
    }

    modifier onlyEligible(uint256 _transactionCode) {
        require(isEligible(_transactionCode, msg.sender), "Root.onlyEligible: Not eligible");
        _;
    }

    modifier onlySignable(uint256 _transactionCode) {
        require(isSignable(_transactionCode, msg.sender), "Root.onlySignable: Not signable");
        _;
    }

    modifier onlyNode() {
        require(WALLET_TYPE_NODE == registered[msg.sender], "Root.onlyNode: Access denied");
        _;
    }

    modifier onlyWallet() {
        require(WALLET_TYPE_WALLET == registered[msg.sender], "Root.onlyWallet: Access denied");
        require(!isContract(msg.sender), "Root.onlyWallet: Is not node");
        _;
    }

    modifier onlyRegulator() {
        require(msg.sender == regulator, "Root.onlyRegulator: Access denied");
        _;
    }

    constructor(string memory _label, string memory _description) public
        Label("ROOT", _label, _description)
    {
    }

    function () external payable
    {
        if (0 < msg.value)
            emit Deposit(msg.sender, msg.value);
    }

    function isEligible(uint256 _transactionCode, address _sender) public view
        returns (bool)
    {
        uint256 flag = requirements[_transactionCode][walletToLabelCodes[_sender]].flag;

        if (0 != flag) {
            uint8 index = walletToIndexes[_sender];

            if (0 != index) {
                index = index.sub(1);

                
                return (0 != ((flag >> index) & 1));
            }
        }
        return false;
    }

    function isSignable(uint256 _transactionCode, address _sender) public view
        returns (bool)
    {
        if (TRANSACTION_STATUS_PENDING == transactions[_transactionCode].status) {
            if (!confirmations[_transactionCode][_sender]) {
                if (0 != requirements[_transactionCode][walletToLabelCodes[_sender]].required)
                    return true;
            }
        }
        return false;
    }

    function createRequirement(bytes32 _labelCode, uint256 _flag, uint8 _required) external
        onlyRegulator
    {
        setRequirement(_labelCode, _flag, _required);
    }

    function setRequirement(bytes32 _labelCode, uint256 _flag, uint8 _required) private
    {
        require(0 < _flag, "Root.setRequirement: Confirmation flag is empty");

        uint8 totalRequired;

        
        if (uint8(-1) == _required) {
            address node = labelCodeToNodes[_labelCode];
            require(address(0) != node, "Root.setRequirement: Node is not found");

            totalRequired = MultiSigNode(node).walletCount();

            if (node != signers) {
                
                require(0 < totalRequired, "Root.setRequirement: No wallet");
            }
            else {
                
                if (0 == totalRequired)
                    return;
            }

            require(0 < totalRequired, "Root.setRequirement: Confirmation required is empty");
        }
        else {
            
            totalRequired = _required;
        }

        require(0 == requirements[transactionCode][_labelCode].flag, "Root.setRequirement: Duplicated requirement");

        requirements[transactionCode][_labelCode] = TransactionRequirement({
            required: totalRequired,
            flag: _flag
        });

        
        transactions[transactionCode].totalRequired = transactions[transactionCode].totalRequired.add(totalRequired);

        emit Requirement(transactionCode, _labelCode, _flag, totalRequired);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external
        onlyWallet
        returns (uint256 ) 
    {
        require(address(0) != _to, "Root.submit: Target address is empty");

        
        transactionCode = transactionCode.add(1);

        bytes4 functionId = convertBytesToBytes4(_data);

        
        if (address(this) != _to) {
            
            if (WALLET_TYPE_NODE == registered[_to]) {
                
                
                
                if (bytes4(0x80882800) == functionId || bytes4(0xceb6c343) == functionId) { 
                    address rootNode = MultiSigNode(_to).getRootNode();

                    if (rootNode == signers) {
                        
                        setRequirement(LABEL_CODE_SIGNER_CONTROLLER, WALLET_FLAG_ALL, uint8(-1)); 
                    }
                    else if (rootNode == signersController || rootNode == stakersController) {
                        
                        setRequirement(LABEL_CODE_STAKER, WALLET_FLAG_ALL, uint8(-1)); 
                    }
                    else if (rootNode == stakers) {
                        
                        setRequirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, uint8(-1)); 
                    }
                    else {
                        revert("Root.submit: Unknown node");
                    }
                }
                else
                    revert("Root.submit: Not supported");
            }
            else {
                
                MultiSigRegulator(regulator).createRequirement(transactionCode, msg.sender, _to, _value, _data);
            }
        }
        else {
            
            
            
            
            
            
            if (bytes4(0xcde0a4f8) == functionId || bytes4(0xc27dbe63) == functionId) 
                setRequirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, uint8(-1)); 
            else if (bytes4(0x26bc178c) == functionId || bytes4(0x51d996bf) == functionId) 
                setRequirement(LABEL_CODE_STAKER, WALLET_FLAG_ALL, uint8(-1)); 
            else if (bytes4(0xb47876ea) == functionId) 
                setRequirement(LABEL_CODE_SIGNER_CONTROLLER, WALLET_FLAG_ALL, uint8(-1)); 
            else
                revert("Root.submit: Not supported");
        }

        require(0 < transactions[transactionCode].totalRequired, "Root.submit: Requirement is empty");

        
        transactions[transactionCode] = Transaction({
            status: TRANSACTION_STATUS_PENDING,
            totalRequired: transactions[transactionCode].totalRequired,
            to: _to,
            value: _value,
            data: _data,
            reason: ""
        });

        emit Submission(transactionCode);

        
        if (isEligible(transactionCode, msg.sender) && isSignable(transactionCode, msg.sender))
            confirmTransaction(transactionCode, transactions[transactionCode]);

        return transactionCode;
    }

    function confirm(uint256 _transactionCode) external
        onlyWallet
        onlyEligible(_transactionCode)
        onlySignable(_transactionCode)
        returns (bool)
    {
        Transaction storage transaction = transactions[_transactionCode];

        return confirmTransaction(_transactionCode, transaction);
    }

    function revoke(uint256 _transactionCode) external
        onlyWallet
        onlyEligible(_transactionCode)
        returns (bool)
    {
        require(TRANSACTION_STATUS_PENDING == transactions[_transactionCode].status, "Root.revoke: Transaction has been completed");
        transactions[_transactionCode].status = TRANSACTION_STATUS_REVOKED;

        emit Revocation(msg.sender, _transactionCode);
        return true;
    }

    function confirmTransaction(uint256 _transactionCode, Transaction storage _transaction) private
        returns (bool)
    {
        TransactionRequirement storage requirement = requirements[_transactionCode][walletToLabelCodes[msg.sender]];
        require(0 != requirement.flag && 0 != requirement.required, "Root.confirmTransaction: Requirement is empty");

        
        require(!confirmations[_transactionCode][msg.sender], "root.confirmTransaction: Duplicated confirmation");
        confirmations[_transactionCode][msg.sender] = true;

        requirement.required = requirement.required.sub(1);
        _transaction.totalRequired = _transaction.totalRequired.sub(1);

        emit Confirmation(msg.sender, _transactionCode);

        return executeTransaction(_transactionCode, _transaction);
    }

    function executeTransaction(uint256 _transactionCode, Transaction storage _transaction) private
        returns (bool)
    {
        require(TRANSACTION_STATUS_PENDING == _transaction.status, "Root.executeTransaction: Status not active");

        if (0 == _transaction.totalRequired) {
            _transaction.status = TRANSACTION_STATUS_EXECUTED;

            
            (bool success, bytes memory returnData) = _transaction.to.call.value(_transaction.value)(_transaction.data);

            if (success)
                emit Execution(_transactionCode);
            else {
                
                if (0 == returnData.length || bytes4(0x08c379a0) != convertBytesToBytes4(returnData))
                    _transaction.reason = "Root.executeTransaction: Function call failed";
                else {
                    bytes memory bytesArray = new bytes(returnData.length);
                    for (uint256 i = 0; i < returnData.length.sub(4); i = i.add(1)) {
                        bytesArray[i] = returnData[i.add(4)];
                    }

                    (string memory reason) = abi.decode(bytesArray, (string));
                    _transaction.reason = reason;
                }

                _transaction.status = TRANSACTION_STATUS_FAILURE;
                emit ExecutionFailure(_transactionCode);
            }

            return success;
        }

        return true;
    }

    function setRegulator(address _addressOf) external
    {
        if (address(0) != regulator)
            require(msg.sender == address(this), "Root.setRegulator: Access denied");
        
        require(MultiSigRegulator(_addressOf).isSealed(), "Root.setRegulator: Regulator is not sealed");

        regulator = setNode(regulator, _addressOf, false);
        emit RegulatorChanged(regulator);
    }

    function setStakers(address _addressOf) external
    {
        if (address(0) != stakers)
            require(msg.sender == address(this), "Root.setStakers: Access denied");

        if (isContract(_addressOf))
            require(0 < MultiSigNode(_addressOf).walletCount(), "Root.setStakers: No wallet");

        stakers = setNode(stakers, _addressOf, true);
        emit StakersChanged(stakers);
    }

    function setSigners(address _addressOf) external
        returns (bool)
    {
        if (address(0) != signers)
            require(msg.sender == address(this), "Root.setSigners: Access denied");

        

        signers = setNode(signers, _addressOf, true);
        emit SignersChanged(signers);
        return true;
    }

    function setStakersController(address _addressOf) external
    {
        if (address(0) != stakersController)
            require(msg.sender == address(this), "Root.setStakersController: Access denied");

        if (isContract(_addressOf))
            require(0 < MultiSigNode(_addressOf).walletCount(), "Root.setStakersController: No wallet");

        stakersController = setNode(stakersController, _addressOf, true);
        emit StakersControllerChanged(stakersController);
    }

    function setSignersController(address _addressOf) external
    {
        if (address(0) != signersController)
            require(msg.sender == address(this), "Root.setSignersController: Access denied");

        if (isContract(_addressOf))
            require(0 < MultiSigNode(_addressOf).walletCount(), "Root.setSignersController: No wallet");

        signersController = setNode(signersController, _addressOf, true);
        emit SignersControllerChanged(signersController);
    }

    function setNode(address _from, address _to, bool needAttachment) private
        returns (address)
    {
        require(address(0) != _to, "Root.setNode: Address is empty");

        if (needAttachment) {
            require(0 == registered[_to], "Root.setNode: Duplicated node");

            
            if (address(0) != _from) {
                if (isContract(_from)) {
                    
                    MultiSigNode(_from).term();
                }

                delete registered[_from];
            }

            if (isContract(_to)) {
                
                registered[_to] = WALLET_TYPE_NODE;

                if (needAttachment) {
                    
                    MultiSigNode(_to).init(address(0));
                }
            }
            else {
                
                registered[_to] = WALLET_TYPE_WALLET;
            }
        }

        return _to;
    }

    function attachWalletOrNode(address _wallet) external
        onlyNode
        returns (bool)
    {
        require(address(0) != _wallet, "Root.attachWalletOrNode: Wallet address is empty");
        require(0 == registered[_wallet], "Root.attachWalletOrNode: Duplicated wallet address");

        bytes32 labelCode = MultiSigNode(msg.sender).labelCode();

        walletToNodes[_wallet] = msg.sender;
        walletToIndexes[_wallet] = MultiSigNode(msg.sender).walletsIndex(_wallet);
        walletToLabelCodes[_wallet] = labelCode;

        labelCodeToNodes[labelCode] = msg.sender;

        if (isContract(_wallet)) {
            
            registered[_wallet] = WALLET_TYPE_NODE;

            
            MultiSigNode(_wallet).init(msg.sender);
        }
        else {
            
            registered[_wallet] = WALLET_TYPE_WALLET;
        }

        emit WalletOrNodeAttached(_wallet);

        return true;
    }

    function detachWalletOrNode(address _wallet) external
        onlyNode
        returns (bool)
    {
        require(address(0) != _wallet, "Root.detachWalletOrNode: Wallet address is empty");
        require(0 != registered[_wallet], "Root.detachWalletOrNode: Wallet address is not registered");

        if (isContract(_wallet)) {
            
            MultiSigNode(_wallet).term();

            bytes32 labelCode = MultiSigNode(msg.sender).labelCode();

            delete labelCodeToNodes[labelCode];
        }

        delete registered[_wallet];
        delete walletToNodes[_wallet];
        delete walletToIndexes[_wallet];
        delete walletToLabelCodes[_wallet];

        emit WalletOrNodeDetached(_wallet);

        return true;
    }

}