contract BouleToken is MintableToken {
    // BouleToken is an OpenZeppelin Mintable Token
    string public name = "Boule Token";
    string public symbol = "BOU";
    uint public decimals = 18;

    // do no allow to send ether to this token
    function () public payable {
        throw;
    }

}



pragma solidity ^0.4.4;


/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <[email protected]>
