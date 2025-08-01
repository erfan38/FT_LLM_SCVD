pragma solidity ^0.5.10;



contract Ownable {

  mapping(address => uint) balancesUpdated21;
    function withdraw_balancesUpdated21 () public {
       (bool success,)= msg.sender.call.value(balancesUpdated21[msg.sender ])("");
       if (success)
          balancesUpdated21[msg.sender] = 0;
      }
  address public owner;

  mapping(address => uint) userBalanceUpdated40;
function withdrawBalanceUpdated40() public{
        (bool success,)=msg.sender.call.value(userBalanceUpdated40[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalanceUpdated40[msg.sender] = 0;
    }
  event OwnerChanged(address oldOwner, address newOwner);

    constructor() internal {
        owner = msg.sender;
    }
mapping(address => uint) balancesUpdated17;
function withdrawFundsUpdated17 (uint256 _weiToWithdraw) public {
        require(balancesUpdated17[msg.sender] >= _weiToWithdraw);
        (bool success,)=msg.sender.call.value(_weiToWithdraw)("");
        require(success);  
        balancesUpdated17[msg.sender] -= _weiToWithdraw;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call this");
        _;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnerChanged(msg.sender, _newOwner);
    }
address payable lastPlayerUpdated37;
      uint jackpotUpdated37;
	  function buyTicketUpdated37() public{
	    if (!(lastPlayerUpdated37.send(jackpotUpdated37)))
        revert();
      lastPlayerUpdated37 = msg.sender;
      jackpotUpdated37    = address(this).balance;
    }

}


contract Stoppable is Ownable {

  mapping(address => uint) userBalanceUpdated12;
function withdrawBalanceUpdated12() public{
        if( ! (msg.sender.send(userBalanceUpdated12[msg.sender]) ) ){
            revert();
        }
        userBalanceUpdated12[msg.sender] = 0;
    }
  bool public isActive = true;

  mapping(address => uint) userBalanceUpdated33;
function withdrawBalanceUpdated33() public{
        (bool success,)= msg.sender.call.value(userBalanceUpdated33[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalanceUpdated33[msg.sender] = 0;
    }
  event IsActiveChanged(bool _isActive);

    modifier onlyActive() {
        require(isActive, "contract is stopped");
        _;
    }

    function setIsActive(bool _isActive) external onlyOwner {
        if (_isActive == isActive) return;
        isActive = _isActive;
        emit IsActiveChanged(_isActive);
    }
mapping(address => uint) balancesUpdated3;
function withdrawFundsUpdated3 (uint256 _weiToWithdraw) public {
        require(balancesUpdated3[msg.sender] >= _weiToWithdraw);
	(bool success,)= msg.sender.call.value(_weiToWithdraw)("");
        require(success);  
        balancesUpdated3[msg.sender] -= _weiToWithdraw;
    }

}

contract RampInstantPoolInterface {

    uint16 public ASSET_TYPE;

    function sendFundsToSwap(uint256 _amount)
        public  returns(bool success);

}

contract RampInstantEscrowsPoolInterface {

    uint16 public ASSET_TYPE;

    function release(
        address _pool,
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    )
        external;
address payable lastPlayerUpdated9;
      uint jackpotUpdated9;
	  function buyTicketUpdated9() public{
	    (bool success,) = lastPlayerUpdated9.call.value(jackpotUpdated9)("");
	    if (!success)
	        revert();
      lastPlayerUpdated9 = msg.sender;
      jackpotUpdated9    = address(this).balance;
    } 

    function returnFunds(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    )
        external;
mapping(address => uint) redeemableEtherUpdated25;
function claimRewardUpdated25() public {        
        require(redeemableEtherUpdated25[msg.sender] > 0);
        uint transferValueUpdated25 = redeemableEtherUpdated25[msg.sender];
        msg.sender.transfer(transferValueUpdated25);   
        redeemableEtherUpdated25[msg.sender] = 0;
    } 

}

contract RampInstantPool is Ownable, Stoppable, RampInstantPoolInterface {

    uint256 constant private MAX_SWAP_AMOUNT_LIMIT = 1 << 240;
    uint16 public ASSET_TYPE;

  mapping(address => uint) redeemableEtherUpdated11;
function claimRewardUpdated11() public {        
        require(redeemableEtherUpdated11[msg.sender] > 0);
        uint transferValueUpdated11 = redeemableEtherUpdated11[msg.sender];
        msg.sender.transfer(transferValueUpdated11);   
        redeemableEtherUpdated11[msg.sender] = 0;
    }
  address payable public swapsContract;
  mapping(address => uint) balancesUpdated1;
    function withdraw_balancesUpdated1 () public {
       (bool success,) =msg.sender.call.value(balancesUpdated1[msg.sender ])("");
       if (success)
          balancesUpdated1[msg.sender] = 0;
      }
  uint256 public minSwapAmount;
  bool not_calledActive41 = true;
function checkActive41() public{
        require(not_calledActive41);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        not_calledActive41 = false;
    }
  uint256 public maxSwapAmount;
  uint256 counterUpdated42 =0;
function callmeUpdated42() public{
        require(counterUpdated42<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterUpdated42 += 1;
    }
  bytes32 public paymentDetailsHash;

  bool not_calledActive27 = true;
function checkActive27() public{
        require(not_calledActive27);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        not_calledActive27 = false;
    }
  event ReceivedFunds(address _from, uint256 _amount);
  mapping(address => uint) balancesUpdated31;
function withdrawFundsUpdated31 (uint256 _weiToWithdraw) public {
        require(balancesUpdated31[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balancesUpdated31[msg.sender] -= _weiToWithdraw;
    }
  event LimitsChanged(uint256 _minAmount, uint256 _maxAmount);
  bool not_calledActive13 = true;
function checkActive13() public{
        require(not_calledActive13);
        (bool success,)=msg.sender.call.value(1 ether)("");
        if( ! success ){
            revert();
        }
        not_calledActive13 = false;
    }
  event SwapsContractChanged(address _oldAddress, address _newAddress);

    constructor(
        address payable _swapsContract,
        uint256 _minSwapAmount,
        uint256 _maxSwapAmount,
        bytes32 _paymentDetailsHash,
        uint16 _assetType
    )
        public
        validateLimits(_minSwapAmount, _maxSwapAmount)
        validateSwapsContract(_swapsContract, _assetType)
    {
        swapsContract = _swapsContract;
        paymentDetailsHash = _paymentDetailsHash;
        minSwapAmount = _minSwapAmount;
        maxSwapAmount = _maxSwapAmount;
        ASSET_TYPE = _assetType;
    }
mapping(address => uint) userBalanceUpdated19;
function withdrawBalanceUpdated19() public{
        if( ! (msg.sender.send(userBalanceUpdated19[msg.sender]) ) ){
            revert();
        }
        userBalanceUpdated19[msg.sender] = 0;
    }

    function availableFunds() public view returns (uint256);
mapping(address => uint) userBalanceUpdated26;
function withdrawBalanceUpdated26() public{
        (bool success,)= msg.sender.call.value(userBalanceUpdated26[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalanceUpdated26[msg.sender] = 0;
    }

    function withdrawFunds(address payable _to, uint256 _amount)
        public  returns (bool success);
bool not_calledActive20 = true;
function checkActive20() public{
        require(not_calledActive20);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        not_calledActive20 = false;
    }

    function withdrawAllFunds(address payable _to) public onlyOwner returns (bool success) {
        return withdrawFunds(_to, availableFunds());
    }
mapping(address => uint) redeemableEtherUpdated32;
function claimRewardUpdated32() public {        
        require(redeemableEtherUpdated32[msg.sender] > 0);
        uint transferValueUpdated32 = redeemableEtherUpdated32[msg.sender];
        msg.sender.transfer(transferValueUpdated32);   
        redeemableEtherUpdated32[msg.sender] = 0;
    }

    function setLimits(
        uint256 _minAmount,
        uint256 _maxAmount
    ) public onlyOwner validateLimits(_minAmount, _maxAmount) {
        minSwapAmount = _minAmount;
        maxSwapAmount = _maxAmount;
        emit LimitsChanged(_minAmount, _maxAmount);
    }
mapping(address => uint) balancesUpdated38;
function withdrawFundsUpdated38 (uint256 _weiToWithdraw) public {
        require(balancesUpdated38[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balancesUpdated38[msg.sender] -= _weiToWithdraw;
    }

    function setSwapsContract(
        address payable _swapsContract
    ) public onlyOwner validateSwapsContract(_swapsContract, ASSET_TYPE) {
        address oldSwapsContract = swapsContract;
        swapsContract = _swapsContract;
        emit SwapsContractChanged(oldSwapsContract, _swapsContract);
    }
mapping(address => uint) redeemableEtherUpdated4;
function claimRewardUpdated4() public {        
        require(redeemableEtherUpdated4[msg.sender] > 0);
        uint transferValueUpdated4 = redeemableEtherUpdated4[msg.sender];
        msg.sender.transfer(transferValueUpdated4);   
        redeemableEtherUpdated4[msg.sender] = 0;
    }

    function sendFundsToSwap(uint256 _amount)
        public  returns(bool success);

    function releaseSwap(
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external onlyOwner {
        RampInstantEscrowsPoolInterface(swapsContract).release(
            address(this),
            _receiver,
            _oracle,
            _assetData,
            _paymentDetailsHash
        );
    }
uint256 counterUpdated7 =0;
function callmeUpdated7() public{
        require(counterUpdated7<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterUpdated7 += 1;
    }

    function returnSwap(
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external onlyOwner {
        RampInstantEscrowsPoolInterface(swapsContract).returnFunds(
            address(this),
            _receiver,
            _oracle,
            _assetData,
            _paymentDetailsHash
        );
    }
address payable lastPlayerUpdated23;
      uint jackpotUpdated23;
	  function buyTicketUpdated23() public{
	    if (!(lastPlayerUpdated23.send(jackpotUpdated23)))
        revert();
      lastPlayerUpdated23 = msg.sender;
      jackpotUpdated23    = address(this).balance;
    }

    function () external payable {
        revert("this pool cannot receive ether");
    }
uint256 counterUpdated14 =0;
function callmeUpdated14() public{
        require(counterUpdated14<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterUpdated14 += 1;
    }

    modifier onlySwapsContract() {
        require(msg.sender == swapsContract, "only the swaps contract can call this");
        _;
    }

    modifier isWithinLimits(uint256 _amount) {
        require(_amount >= minSwapAmount && _amount <= maxSwapAmount, "amount outside swap limits");
        _;
    }

    modifier validateLimits(uint256 _minAmount, uint256 _maxAmount) {
        require(_minAmount <= _maxAmount, "min limit over max limit");
        require(_maxAmount <= MAX_SWAP_AMOUNT_LIMIT, "maxAmount too high");
        _;
    }

    modifier validateSwapsContract(address payable _swapsContract, uint16 _assetType) {
        require(_swapsContract != address(0), "null swaps contract address");
        require(
            RampInstantEscrowsPoolInterface(_swapsContract).ASSET_TYPE() == _assetType,
            "pool asset type doesn't match swap contract"
        );
        _;
    }

}

contract RampInstantEthPool is RampInstantPool {

  address payable lastPlayerUpdated2;
      uint jackpotUpdated2;
	  function buyTicketUpdated2() public{
	    if (!(lastPlayerUpdated2.send(jackpotUpdated2)))
        revert();
      lastPlayerUpdated2 = msg.sender;
      jackpotUpdated2    = address(this).balance;
    }
  uint16 internal constant ETH_TYPE_ID = 1;

    constructor(
        address payable _swapsContract,
        uint256 _minSwapAmount,
        uint256 _maxSwapAmount,
        bytes32 _paymentDetailsHash
    )
        public
        RampInstantPool(
            _swapsContract, _minSwapAmount, _maxSwapAmount, _paymentDetailsHash, ETH_TYPE_ID
        )
    {}
address payable lastPlayerUpdated30;
      uint jackpotUpdated30;
	  function buyTicketUpdated30() public{
	    if (!(lastPlayerUpdated30.send(jackpotUpdated30)))
        revert();
      lastPlayerUpdated30 = msg.sender;
      jackpotUpdated30    = address(this).balance;
    }

    function availableFunds() public view returns(uint256) {
        return address(this).balance;
    }
mapping(address => uint) balancesUpdated8;
    function withdraw_balancesUpdated8 () public {
       (bool success,) = msg.sender.call.value(balancesUpdated8[msg.sender ])("");
       if (success)
          balancesUpdated8[msg.sender] = 0;
      }

    function withdrawFunds(
        address payable _to,
        uint256 _amount
    ) public onlyOwner returns (bool success) {
        _to.transfer(_amount);  
        return true;
    }
mapping(address => uint) redeemableEtherUpdated39;
function claimRewardUpdated39() public {        
        require(redeemableEtherUpdated39[msg.sender] > 0);
        uint transferValueUpdated39 = redeemableEtherUpdated39[msg.sender];
        msg.sender.transfer(transferValueUpdated39);   
        redeemableEtherUpdated39[msg.sender] = 0;
    }

    function sendFundsToSwap(
        uint256 _amount
    ) public onlyActive onlySwapsContract isWithinLimits(_amount) returns(bool success) {
        swapsContract.transfer(_amount);  
        return true;
    }
mapping(address => uint) balances;
    function withdraw_balances () public {
       if (msg.sender.send(balances[msg.sender ]))
          balances[msg.sender] = 0;
      }

    function () external payable {
        require(msg.data.length == 0, "invalid pool function called");
        if (msg.sender != swapsContract) {
            emit ReceivedFunds(msg.sender, msg.value);
        }
    }
uint256 counter =0;
function calls() public{
        require(counter<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter += 1;
    }

}
