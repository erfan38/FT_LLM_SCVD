contract ERC20nator is StandardToken, Ownable {

    address public fundraiserAddress;
    bytes public fundraiserCallData;

    uint constant issueFeePercent = 2; // fee in percent that is collected for all paid in funds

    event requestedRedeem(address indexed requestor, uint amount);
    
    event redeemed(address redeemer, uint amount);

    // fallback function invests in fundraiser
    // fee percentage is given to owner for providing this service
    // remainder is invested in fundraiser
    function() payable {
        uint issuedTokens = msg.value * (100 - issueFeePercent) / 100;

        // pay fee to owner
        if(!owner.send(msg.value - issuedTokens))
            throw;
        
        // invest remainder into fundraiser
        if(!fundraiserAddress.call.value(issuedTokens)(fundraiserCallData))
            throw;

        // issue tokens by increasing total supply and balance
        totalSupply += issuedTokens;
        balances[msg.sender] += issuedTokens;
    }

    // allow owner to set fundraiser target address
    function setFundraiserAddress(address _fundraiserAddress) onlyOwner {
        fundraiserAddress = _fundraiserAddress;
    }

    // allow owner to set call data to be sent along to fundraiser target address
    function setFundraiserCallData(string _fundraiserCallData) onlyOwner {
        fundraiserCallData = hexStrToBytes(_fundraiserCallData);
    }

    // this is just to inform the owner that a user wants to redeem some of their IOU tokens
    function requestRedeem(uint _amount) {
        requestedRedeem(msg.sender, _amount);
    }

    // this is just to inform the investor that the owner redeemed some of their IOU tokens
    function redeem(uint _amount) onlyOwner{
        redeemed(msg.sender, _amount);
    }

    // helper function to input bytes via remix
    // from https://ethereum.stackexchange.com/a/13658/16
    function hexStrToBytes(string _hexString) constant returns (bytes) {
        //Check hex string is valid
        if (bytes(_hexString)[0]!='0' ||
            bytes(_hexString)[1]!='x' ||
            bytes(_hexString).length%2!=0 ||
            bytes(_hexString).length<4) {
                throw;
            }

        bytes memory bytes_array = new bytes((bytes(_hexString).length-2)/2);
        uint len = bytes(_hexString).length;
        
        for (uint i=2; i<len; i+=2) {
            uint tetrad1=16;
            uint tetrad2=16;

            //left digit
            if (uint(bytes(_hexString)[i])>=48 &&uint(bytes(_hexString)[i])<=57)
                tetrad1=uint(bytes(_hexString)[i])-48;

            //right digit
            if (uint(bytes(_hexString)[i+1])>=48 &&uint(bytes(_hexString)[i+1])<=57)
                tetrad2=uint(bytes(_hexString)[i+1])-48;

            //left A->F
            if (uint(bytes(_hexString)[i])>=65 &&uint(bytes(_hexString)[i])<=70)
                tetrad1=uint(bytes(_hexString)[i])-65+10;

            //right A->F
            if (uint(bytes(_hexString)[i+1])>=65 &&uint(bytes(_hexString)[i+1])<=70)
                tetrad2=uint(bytes(_hexString)[i+1])-65+10;

            //left a->f
            if (uint(bytes(_hexString)[i])>=97 &&uint(bytes(_hexString)[i])<=102)
                tetrad1=uint(bytes(_hexString)[i])-97+10;

            //right a->f
            if (uint(bytes(_hexString)[i+1])>=97 &&uint(bytes(_hexString)[i+1])<=102)
                tetrad2=uint(bytes(_hexString)[i+1])-97+10;

            //Check all symbols are allowed
            if (tetrad1==16 || tetrad2==16)
                throw;

            bytes_array[i/2-1]=byte(16*tetrad1 + tetrad2);
        }

        return bytes_array;
    }

}