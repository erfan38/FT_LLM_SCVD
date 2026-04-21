contract Coffers {
    struct Coffer {address owner; uint[] slots;}
    Coffer[] public coffers;
    
    /** @dev Create coffers.
     *  @param _slots The amount of slots the coffer will have.
     * */
    function createCoffer(uint _slots) external {
        Coffer storage coffer = coffers[coffers.length++];
        coffer.owner = msg.sender;
        coffer.slots.length = _slots;
    }
    
    /** @dev Deposit money in one's coffer slot.
     *  @dev _coffer The coffer to deposit money on.
     *  @param _slot The slot to deposit money.
     * */
    function deposit(uint _coffer, uint _slot) payable external {
        Coffer storage coffer = coffers[_coffer];
        coffer.slots[_slot] += msg.value;
    }
    
    /** @dev withdraw all of the money of one's coffer slot.
     *  @param _slot The slot to withdraw money from.
     * */
    function withdraw(uint _coffer, uint _slot) external {
        Coffer storage coffer = coffers[_coffer];
        require(coffer.owner == msg.sender);
        msg.sender.transfer(coffer.slots[_slot]);
        coffer.slots[_slot] = 0;
    }
}

//*** Exercise Bonus ***//
// One of the previous contracts has 2 vulnerabilities.
// Find which one and describe the second vulnerability.

