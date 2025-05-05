contract TokenSale
{
    address public creator;
    address public tokenContract;
    uint public tokenPrice;  
    uint public deadline;
    constructor(address source)
    {
        creator = msg.sender;
        tokenContract = source;
    }
    function setPrice(uint price)
    {
        if (msg.sender == creator) tokenPrice = price;
    }
    function setDeadline(uint timestamp)
    {
        if (msg.sender == creator) deadline = timestamp;
    }
    function buyTokens(address beneficiary) payable
    {
        require(
            block.timestamp < deadline
            && tokenPrice > 0
            && YellowBetterToken(tokenContract).transfer(beneficiary, 1000000000000000000 * msg.value / tokenPrice));
    }
    function payout()
    {
        creator.transfer(this.balance);
    }
}