contract ESSENTIA_PE is Ownable {

    using SafeMath for uint256;

    string public name = "ESSENTIA Public Engagement";       
    uint256 public tokenPrice = 0;         
    uint256 public maxCap = 0;             
    address public FWDaddrETH;             
    address public ESSgenesis;             
    uint256 public totalSold;              
    uint256 public decimals = 18;          

    mapping (address => uint256) public sold;        

    uint256 public pubEnd = 0;                       
    address contractAddr=this;                       

     
    uint256 public tokenUnit = uint256(10)**decimals;



     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     


    constructor
        (
        address toETHaddr,
        address addrESSgenesis
        ) public {
        FWDaddrETH = toETHaddr;
        ESSgenesis = addrESSgenesis;

    }



    function () public payable {
        buy();                
    }




    function setFWDaddrETH(address _value) public onlyOwner{
      FWDaddrETH=_value;      

    }


    function setGenesis(address _value) public onlyOwner{
      ESSgenesis=_value;      

    }


    function setMaxCap(uint256 _value) public onlyOwner{
      maxCap=_value;          

    }


    function setPrice(uint256 _value) public onlyOwner{
      tokenPrice=_value;      

    }


    function setPubEnd(uint256 _value) public onlyOwner{
      pubEnd=_value;          

    }




    function buy() public payable {

        require(block.timestamp < pubEnd);           
        require(msg.value > 0);                      
        require(msg.value <= msg.sender.balance);    

         
        require(msg.value + totalSold <= maxCap);

         
        uint256 tokenAmount = (msg.value * tokenUnit) / tokenPrice;

         
        require(tokenAmount<=TokenCHK(ESSgenesis).balanceOf(contractAddr));

        transferBuy(msg.sender, tokenAmount);        
        totalSold = totalSold.add(msg.value);        
        FWDaddrETH.transfer(msg.value);              

    }




    function withdrawPUB() public returns(bool){

        require(block.timestamp > pubEnd);           
        require(sold[msg.sender] > 0);               

         
        if(!ESSgenesis.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, sold[msg.sender])){revert();}

        delete sold[msg.sender];
        return true;

    }




    function transferBuy(address _to, uint256 _value) internal returns (bool) {

        require(_to != address(0));                  

        sold[_to]=sold[_to].add(_value);             

        return true;

    }



         
         
         
         
    function EMGwithdraw(uint256 weiValue) external onlyOwner {
        require(block.timestamp > pubEnd);           
        require(weiValue > 0);                       

        FWDaddrETH.transfer(weiValue);               
    }

}