contract cryptocurrencyClubTest {
    
    uint originalTime;
    
    constructor() public{
        originalTime = now;
    }
    
    
    
    function BirthdayBoyClickHere() public view returns(string) {
        require(now < originalTime + 23 hours);
        return "Happy Birthday Harrison! I know this 