contract MultiSigFactory {
    
    event Create(address indexed caller, address createdContract);

    function create(address[] owners, uint256 required) returns (address wallet){
        wallet = new MultiSigStub(owners, required); 
        Create(msg.sender, wallet);
    }
    
}

///////////////////////////////////////////////////////////////////
// MultiSigTokenWallet as in 0xc0FFeEE61948d8993864a73a099c0E38D887d3F4
///////////////////////////////////////////////////////////////////

pragma solidity ^0.4.15;

