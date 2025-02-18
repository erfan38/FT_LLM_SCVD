pragma solidity ^0.4.13;

interface FundInterface {

    

    event PortfolioContent(address[] assets, uint[] holdings, uint[] prices);
    event RequestUpdated(uint id);
    event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
    event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
    event ErrorMessage(string errorMessage);

    
    
    function requestInvestment(uint giveQuantity, uint shareQuantity, address investmentAsset) external;
    function executeRequest(uint requestId) external;
    function cancelRequest(uint requestId) external;
    function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
    
    function enableInvestment(address[] ofAssets) external;
    function disableInvestment(address[] ofAssets) external;
    function shutDown() external;

    
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
    function calcSharePriceAndAllocateFees() public returns (uint);


    
    
    function getModules() view returns (address, address, address);
    function getLastRequestId() view returns (uint);
    function getManager() view returns (address);

    
    function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
    function calcSharePrice() view returns (uint);
}

interface AssetInterface {
    








    
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    

    
    
    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    
    
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    
    function balanceOf(address _owner) view public returns (uint balance);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
}

contract DSExec {
    function tryExec( address target, bytes calldata, uint value)
             internal
             returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint value)
             internal
    {
        if(!tryExec(target, calldata, value)) {
            revert();
        }
    }

    
    function exec( address t, bytes c )
        internal
    {
        exec(t, c, 0);
    }
    function exec( address t, uint256 v )
        internal
    {
        bytes memory c; exec(t, c, v);
    }
    function tryExec( address t, bytes c )
        internal
        returns (bool)
    {
        return tryExec(t, c, 0);
    }
    function tryExec( address t, uint256 v )
        internal
        returns (bool)
    {
        bytes memory c; return tryExec(t, c, v);
    }
}
