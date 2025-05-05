contract GhostGold is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    string public name;                   //fancy name
    uint8 public decimals;                //How many decimals to show
    string public symbol;                 //An identifier
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

//
//

//function name must match the 