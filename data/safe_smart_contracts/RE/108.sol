contract SelfDestructible is Owned {
	
	uint public initiationTime;
	bool public selfDestructInitiated;
	address public selfDestructBeneficiary;
	uint public constant SELFDESTRUCT_DELAY = 4 weeks;

	/**
	 * @dev Constructor
	 * @param _owner The account which controls this contract.
	 */
	constructor(address _owner)
	    Owned(_owner)
	    public
	{
		require(_owner != address(0), "Owner must not be the zero address");
		selfDestructBeneficiary = _owner;
		emit SelfDestructBeneficiaryUpdated(_owner);
	}

	/**
	 * @notice Set the beneficiary address of this contract.
	 * @dev Only the 