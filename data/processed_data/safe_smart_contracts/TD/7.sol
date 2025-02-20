contract AccessService is AccessAdmin {
    address public addrService;
    address public addrFinance;

    modifier onlyService() {
        require(msg.sender == addrService);
        _;
    }

    modifier onlyFinance() {
        require(msg.sender == addrFinance);
        _;
    }

    function setService(address _newService) external {
        require(msg.sender == addrService || msg.sender == addrAdmin);
        require(_newService != address(0));
        addrService = _newService;
    }

    function setFinance(address _newFinance) external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_newFinance != address(0));
        addrFinance = _newFinance;
    }

    function withdraw(address _target, uint256 _amount) 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_amount > 0);
        address receiver = _target == address(0) ? addrFinance : _target;
        uint256 balance = address(this).balance;
        if (_amount < balance) {
            receiver.transfer(_amount);
        } else {
            receiver.transfer(address(this).balance);
        }      
    }
}

interface WarTokenInterface {
    function getFashion(uint256 _tokenId) external view returns(uint16[12]);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferByContract(uint256 _tokenId, address _to) external;
} 

interface WonderTokenInterface {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function safeGiveByContract(uint256 _tokenId, address _to) external;
    function getProtoIdByTokenId(uint256 _tokenId) external view returns(uint256); 
}

interface ManagerTokenInterface {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function safeGiveByContract(uint256 _tokenId, address _to) external;
    function getProtoIdByTokenId(uint256 _tokenId) external view returns(uint256);
}

interface TalentCardInterface {
    function safeSendCard(uint256 _amount, address _to) external;
}

interface ERC20BaseInterface {
    function balanceOf(address _from) external view returns(uint256);
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external; 
}

