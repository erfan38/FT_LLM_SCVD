contract ShopKeeper is SafeMath{
    
    ValueTrader public shop;
    address holderA; //actually manages the trader, recieves equal share of profits
    address holderB; //only recieves manages own profits, (for profit-container type contracts)
    
    
    modifier onlyHolders(){
        assert(msg.sender == holderA || msg.sender == holderB);
        _;
    }
    
    modifier onlyA(){
        assert(msg.sender == holderA);
        _;
    }
    
    function(){
        //this 