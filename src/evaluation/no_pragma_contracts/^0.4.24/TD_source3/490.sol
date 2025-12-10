contract CompetitionCompliance is ComplianceInterface, DBC, Owned {

    address public competitionAddress;

     

     
     
    function CompetitionCompliance(address ofCompetition) public {
        competitionAddress = ofCompetition;
    }

     

     
     
     
     
     
    function isInvestmentPermitted(
        address ofParticipant,
        uint256 giveQuantity,
        uint256 shareQuantity
    )
        view
        returns (bool)
    {
        return competitionAddress == ofParticipant;
    }

     
     
     
     
     
    function isRedemptionPermitted(
        address ofParticipant,
        uint256 shareQuantity,
        uint256 receiveQuantity
    )
        view
        returns (bool)
    {
        return competitionAddress == ofParticipant;
    }

     
     
     
    function isCompetitionAllowed(
        address x
    )
        view
        returns (bool)
    {
        return CompetitionInterface(competitionAddress).isWhitelisted(x) && CompetitionInterface(competitionAddress).isCompetitionActive();
    }


     

     
     
    function changeCompetitionAddress(
        address ofCompetition
    )
        pre_cond(isOwner())
    {
        competitionAddress = ofCompetition;
    }

}

interface GenericExchangeInterface {

     

    event OrderUpdated(uint id);

     
     

    function makeOrder(
        address onExchange,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) external returns (uint);
    function takeOrder(address onExchange, uint id, uint quantity) external returns (bool);
    function cancelOrder(address onExchange, uint id) external returns (bool);


     
     

    function isApproveOnly() view returns (bool);
    function getLastOrderId(address onExchange) view returns (uint);
    function isActive(address onExchange, uint id) view returns (bool);
    function getOwner(address onExchange, uint id) view returns (address);
    function getOrder(address onExchange, uint id) view returns (address, address, uint, uint);
    function getTimestamp(address onExchange, uint id) view returns (uint);

}

