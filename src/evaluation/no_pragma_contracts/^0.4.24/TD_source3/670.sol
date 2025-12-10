contract StreamityContract is ERC20Extending, StreamityCrowdsale
{
    using SafeMath for uint;

    uint public weisRaised;   

     
    function StreamityContract() public TokenERC20(130000000, "Streamity", "STM") {}  

     
    function () public payable
    {
        assert(msg.value >= 1 ether / 10);
        require(now >= ICO.startDate);

        if (now >= ICO.endDate) {
            pauseInternal();
            emit CrowdSaleFinished(crowdSaleStatus());
        }


        if (0 != startIcoDate) {
            if (now < startIcoDate) {
                revert();
            } else {
                startIcoDate = 0;
            }
        }

        if (paused == false) {
            sell(msg.sender, msg.value);
            weisRaised = weisRaised.add(msg.value);
        }
    }
}

 
