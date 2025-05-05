contract ServiceProvider {

    ///@dev get human readable descriptor (or url) for this Service provider
    //
    function info() constant public returns(string);

    ///@dev called to post-approve/reject incoming single payment.
    ///@return `false` causes an exception and reverts the payment.
    //
    function onPayment(address _from, uint _value, bytes _paymentData) public returns (bool);

    ///@dev called to post-approve/reject subscription charge.
    ///@return `false` causes an exception and reverts the operation.
    //
    function onSubExecuted(uint subId) public returns (bool);

    ///@dev called to post-approve/reject a creation of the subscription.
    ///@return `false` causes an exception and reverts the operation.
    //
    function onSubNew(uint newSubId, uint offerId) public returns (bool);

    ///@dev called to notify service provider about subscription cancellation.
    ///     Provider is not able to prevent the cancellation.
    ///@return <<reserved for future implementation>>
    //
    function onSubCanceled(uint subId, address caller) public returns (bool);

    ///@dev called to notify service provider about subscription got hold/unhold.
    ///@return `false` causes an exception and reverts the operation.
    //
    function onSubUnHold(uint subId, address caller, bool isOnHold) public returns (bool);


    ///@dev following events should be used by ServiceProvider 