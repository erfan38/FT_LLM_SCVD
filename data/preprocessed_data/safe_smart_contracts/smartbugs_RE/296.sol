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

contract MultiSigRegulator is Label {
    using SafeMathUint8 for uint8;
    using SafeMathUint256 for uint256;

    event TransactionLimitChanged(string requirementType, uint256 limit);

    address payable public root;

    address private creator;

    
    address private argTo;
    uint256 private argValue;

    bool public isSealed;

    
    mapping(bytes32 => TransactionLimit) public transactionLimits;

    struct TransactionLimit {
        uint256 datetime;
        uint256 volume;
        uint256 upperLimit;
    }

    modifier onlySealed() {
        require(isSealed, "Regulator.onlySealed: Not sealed");
        _;
    }

    modifier onlyMe() {
        require(msg.sender == address(this), "Regulator.onlyMe: Access denied");
        _;
    }

    modifier onlyRoot() {
        require(msg.sender == root, "Regulator.onlyRoot: Access denied");
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Regulator.onlyCreator: Access denied");
        _;
    }

    


    function () external
        onlyMe
        onlySealed
    {
        revert("Regulator: Not supported");
    }

    constructor(address payable _root, string memory _label, string memory _description) public
        Label("REGULATOR", _label, _description)
    {
        require(address(0) != _root, "Regulator: Root address is empty");
        root = _root;
        creator = msg.sender;
    }

    



    function increaseSupply(uint256 _value, address ) external
        onlyMe
        onlySealed
    {
        defaultRequirement("increaseSupply", _value);
    }

    



    function decreaseSupply(uint256 _value, address ) external
        onlyMe
        onlySealed
    {
        defaultRequirement("decreaseSupply", _value);
    }

    



    function freeze(address , uint256 ) external
        onlyMe
        onlySealed
    {
        requirement1Backsys();
    }

    



    function unfreeze(address , uint256 ) external
        onlyMe
        onlySealed
    {
        requirement1Backsys();
    }

    



    function freezeAddress(address ) external
        onlyMe
        onlySealed
    {
        requirement1Backsys();
    }

    



    function unfreezeAddress(address ) external
        onlyMe
        onlySealed
    {
        requirement1Backsys();
    }

    



    function acceptOwnership () external
        onlyMe
        onlySealed
    {
        requirement(LABEL_CODE_OPS, 2, 1); 
        requirement(LABEL_CODE_SIGNER_CONTROLLER, 1, 1); 
    }

    



    function transferOwnership (address payable ) external
        onlyMe
        onlySealed
    {
        requirement(LABEL_CODE_STAKER, WALLET_FLAG_ALL, 1); 
        requirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, uint8(-1)); 
        requirement(LABEL_CODE_SIGNER_CONTROLLER, WALLET_FLAG_ALL, 1); 
    }

    



    function pause () external
        onlyMe
        onlySealed
    {
        requirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, 1); 
    }

    



    function resume () external
        onlyMe
        onlySealed
    {
        requirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, 2); 
    }

    


    function setTransactionLimit(string calldata _requirementType, uint256 _limit) external
    {
        if (msg.sender == root || !isSealed) {
            
            transactionLimits[encodePacked(_requirementType)].upperLimit = _limit;
            emit TransactionLimitChanged(_requirementType, _limit);
        }
        else {
            require(msg.sender == address(this), "Regulator.setTransactionLimit: Access denied");

            
            requirement(LABEL_CODE_STAKER_CONTROLLER, WALLET_FLAG_ALL, 2); 
        }
    }

    function seal() external
        onlyCreator
    {
        require(!isSealed, "Regulator.seal: Access denied");
        isSealed = true;
    }

    function createRequirement(uint256 , address , address _to, uint256 _value, bytes calldata _data) external
        onlyRoot
    {
        
        argTo = _to;
        argValue = _value;

        
        (bool success, bytes memory returnData) = address(this).call.value(_value)(_data);

        if (!success) {
            
            if (0 == returnData.length || bytes4(0x08c379a0) != convertBytesToBytes4(returnData))
                revert("Regulator.createRequirement: Function call failed");
            else {
                bytes memory bytesArray = new bytes(returnData.length);
                for (uint256 i = 0; i < returnData.length.sub(4); i = i.add(1)) {
                    bytesArray[i] = returnData[i.add(4)];
                }

                (string memory reason) = abi.decode(bytesArray, (string));
                revert(reason);
            }
        }
    }

    function requirement(bytes32 _labelCode, uint256 _flag, uint8 _required) private
    {
        MultiSigRoot(root).createRequirement(_labelCode, _flag, _required);
    }

    function defaultRequirement(string memory _requirementType, uint256 _value) private
    {
        bytes32 t = encodePacked(_requirementType);

        
        TransactionLimit storage limit = transactionLimits[t];

        
        if (0 < limit.upperLimit) {
            
            uint256 dt = now - (now % 86400);

            if (dt == limit.datetime)
                limit.volume = limit.volume.add(_value);
            else {
                
                limit.datetime = dt;
                limit.volume = _value;
            }

            require(limit.upperLimit >= limit.volume, "Regulator.defaultRequirement: Exceeded limit");
        }

        
        requirement(LABEL_CODE_OPS, WALLET_FLAG_ALL, 4); 
    }

    function requirement1Backsys() private
    {
        requirement(LABEL_CODE_BACKSYS, WALLET_FLAG_ALL, 1); 
    }

}

