contract FundsHolderMixin is ReentryProtectorMixin, CarefulSenderMixin {

    // Record here how much wei is owned by an address.
    // Obviously, the entries here MUST be backed by actual ether
    // owned by the contract - we cannot enforce that in this mixin.
    mapping (address => uint) funds;

    event FundsWithdrawnEvent(
        address fromAddress,
        address toAddress,
        uint valueWei
    );

    /// @notice Amount of ether held for `_address`.
    function fundsOf(address _address) constant returns (uint valueWei) {
        return funds[_address];
    }

    /// @notice Send the caller (`msg.sender`) all ether they own.
    function withdrawFunds() {
        externalEnter();
        withdrawFundsRP();
        externalLeave();
    }

    /// @notice Send `_valueWei` of the ether owned by the caller
    /// (`msg.sender`) to `_toAddress`, including `_extraGas` gas
    /// beyond the normal stipend.
    function withdrawFundsAdvanced(
        address _toAddress,
        uint _valueWei,
        uint _extraGas
    ) {
        externalEnter();
        withdrawFundsAdvancedRP(_toAddress, _valueWei, _extraGas);
        externalLeave();
    }

    /// @dev internal version of withdrawFunds()
    function withdrawFundsRP() internal {
        address fromAddress = msg.sender;
        address toAddress = fromAddress;
        uint allAvailableWei = funds[fromAddress];
        withdrawFundsAdvancedRP(
            toAddress,
            allAvailableWei,
            suggestedExtraGasToIncludeWithSends
        );
    }

    /// @dev internal version of withdrawFundsAdvanced(), also used
    /// by withdrawFundsRP().
    function withdrawFundsAdvancedRP(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal {
        if (msg.value != 0) {
            throw;
        }
        address fromAddress = msg.sender;
        if (_valueWei > funds[fromAddress]) {
            throw;
        }
        funds[fromAddress] -= _valueWei;
        bool sentOk = carefulSendWithFixedGas(
            _toAddress,
            _valueWei,
            _extraGasIncluded
        );
        if (!sentOk) {
            throw;
        }
        FundsWithdrawnEvent(fromAddress, _toAddress, _valueWei);
    }

}


/// @title Mixin to help make nicer looking ether amounts.
