contract ERC20Token is StandardToken {

    function () {
        
        revert();
    }

    string public name;                   //optional
    uint8 public decimals;                //optional
    string public symbol;                 //Optional
    string public version = 'H1.0';       //Optional


//this function name matches the 