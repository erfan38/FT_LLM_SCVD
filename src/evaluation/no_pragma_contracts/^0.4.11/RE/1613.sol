contract NanoPyramid {
    uint private pyramidMultiplier = 140;
    uint private minAmount = 1 finney;
    uint private maxAmount = 1 ether;
    uint private fee = 1;
    uint private collectedFees = 0;
    uint private minFeePayout = 100 finney;

    address private owner;

    function NanoPyramid() {
        owner = msg.sender;
    }

    modifier onlyowner { if (msg.sender == owner) _ }

    struct Participant {
        address etherAddress;
        uint payout;
    }

    Participant[] public participants;

    uint public payoutOrder = 0;
    uint public balance = 0;

    function() {
        enter();
    }

    function enter() {
        // Check if amount is too small
        if (msg.value < minAmount) {
            // Amount is too small, no need to think about refund
            collectedFees += msg.value;
            return;
        }

        // Check if amount is too high
        uint amount;
        if (msg.value > maxAmount) {
            uint amountToRefund =  msg.value - maxAmount;
            if (amountToRefund >= minAmount) {
            	if (!msg.sender.send(amountToRefund)) {
            	    throw;
            	}
        	}
            amount = maxAmount;
        } else {
        	amount = msg.value;
        }

        //Adds new address to the participant array
        participants.push(Participant(
            msg.sender,
            amount * pyramidMultiplier / 100
        ));

        // Update fees and 