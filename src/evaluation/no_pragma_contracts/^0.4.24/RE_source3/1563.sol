contract CarefulSenderMixin {

    // Seems a reasonable amount for a well-written fallback function.
    uint constant suggestedExtraGasToIncludeWithSends = 23000;

    // Send `_valueWei` of our ether to `_toAddress`, including
    // `_extraGasIncluded` gas above the usual 2300 gas stipend
    // with the send call.
    //
    // This needs care because there is no way to tell if _toAddress
    // is externally owned or is another contract - and sending ether
    // to a 