contract WithFee is WithBeneficiary {
    // @notice Contracts asking for a confirmation of a certification need to pass this fee.
    uint256 private queryFee;

    event LogQueryFeeSet(uint256 previousQueryFee, uint256 newQueryFee);

    function WithFee(
            address beneficiary,
            uint256 _queryFee)
        WithBeneficiary(beneficiary) {
        queryFee = _queryFee;
    }

    modifier requestFeePaid {
        if (msg.value < queryFee) {
            throw;
        }
        asyncSend(getBeneficiary(), msg.value);
        _;
    }

    function getQueryFee()
        constant
        returns (uint256) {
        return queryFee;
    }

    function setQueryFee(uint256 newQueryFee)
        fromOwner
        returns (bool success) {
        if (queryFee != newQueryFee) {
            LogQueryFeeSet(queryFee, newQueryFee);
            queryFee = newQueryFee;
        }
        success = true;
    }
}

/*
 * @notice Base 