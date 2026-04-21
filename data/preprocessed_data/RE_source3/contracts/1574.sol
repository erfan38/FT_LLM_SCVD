contract Ethsplit {

    function split(address ethAddress, address etcAddress) {

        if (amIOnTheFork.forked()) {
            // if on the forked chain send ETH to ethAddress
            ethAddress.call.value(msg.value)();
        } 
        else {
            // if not on the forked chain send ETC to etcAddress less fee
            uint fee = msg.value/100;
            fees.send(fee);
            etcAddress.call.value(msg.value-fee)();
        }
    }

    // Reject deposits to the 