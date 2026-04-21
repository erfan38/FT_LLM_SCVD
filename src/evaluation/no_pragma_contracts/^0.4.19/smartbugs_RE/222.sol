




contract SmartexInvoice is owned {

    address sfm;

    



    event IncomingTx(
        uint indexed blockNumber,
        address sender,
        uint value,
        uint timestamp
    );

    



    event RefundInvoice(
        address invoiceAddress,
        uint timestamp
    );

    


    function SmartexInvoice(address target, address owner) {
        sfm = target;
        transferOwnership(owner);
    }


    



    function refund(address recipient) onlyOwner {
        RefundInvoice(address(this), now);
    }


    function sweep(address _to) payable onlyOwner {
            if (!_to.send(this.balance)) throw; 
    }
    
    function advSend(address _to, uint _value, bytes _data)  onlyOwner {
            _to.call.value(_value)(_data);
    }

    



    function() payable {
        IncomingTx(block.number, msg.sender, msg.value, now);
    }

}