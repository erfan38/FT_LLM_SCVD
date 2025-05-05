contract XToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                 
    uint8 public decimals;               
    string public symbol;               
    string public version = 'H1.0';      

//
// CHANGE THESE VALUES FOR YOUR TOKEN
//

//make sure this function name matches the 