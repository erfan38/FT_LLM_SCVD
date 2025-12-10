pragma solidity ^0.8.0;
}





contract CardsBase is JadeCoin {

function CardsBase() public {
setAdminContract(msg.sender,true);
setActionContract(msg.sender,true);
}