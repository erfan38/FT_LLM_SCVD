pragma solidity 0.4.24;

contract TransactionRequestCore is TransactionRequestInterface {
    using RequestLib for RequestLib.Request;
    using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;

    RequestLib.Request txnRequest;
    bool private initialized = false;

    


















    function initialize(
        address[4]  addressArgs,
        uint[12]    uintArgs,
        bytes       callData
    )
        public payable
    {
        require(!initialized);

        txnRequest.initialize(addressArgs, uintArgs, callData);
        initialized = true;
    }

    



    function() public payable {}

    


    function execute() public returns (bool) {
        return txnRequest.execute();
    }

    function cancel() public returns (bool) {
        return txnRequest.cancel();
    }

    function claim() public payable returns (bool) {
        return txnRequest.claim();
    }

    



    
    
    function requestData()
        public view returns (address[6], bool[3], uint[15], uint8[1])
    {
        return txnRequest.serialize();
    }

    function callData()
        public view returns (bytes data)
    {
        data = txnRequest.txnData.callData;
    }

    








    function proxy(address _to, bytes _data)
        public payable returns (bool success)
    {
        require(txnRequest.meta.owner == msg.sender && txnRequest.schedule.isAfterWindow());
        
        
        return _to.call.value(msg.value)(_data);
    }

    


    function refundClaimDeposit() public returns (bool) {
        txnRequest.refundClaimDeposit();
    }

    function sendFee() public returns (bool) {
        return txnRequest.sendFee();
    }

    function sendBounty() public returns (bool) {
        return txnRequest.sendBounty();
    }

    function sendOwnerEther() public returns (bool) {
        return txnRequest.sendOwnerEther();
    }

    function sendOwnerEther(address recipient) public returns (bool) {
        return txnRequest.sendOwnerEther(recipient);
    }

    

    event Aborted(uint8 reason);
    event Cancelled(uint rewardPayment, uint measuredGasConsumption);
    event Claimed();
    event Executed(uint bounty, uint fee, uint measuredGasConsumption);
}
