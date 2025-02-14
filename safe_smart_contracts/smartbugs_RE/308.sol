pragma solidity 0.4.25;





library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}






contract EtHero is Ownable{

   using SafeMath for uint;
    
    mapping (address => uint) public balances;
    
    mapping (address => uint) private time;
    
    
    
    
    address public  fund1 = 0xf846f84841b3242Ccdeac8c43C9cF73Bd781baA7;
    address public  fund2 = 0xa7A20b9f36CD88fC2c776C9BB23FcEA34ba80ef7;
    address public stabFund;
    uint estGas = 100000;
    
    uint standartPersent = 30; 
    uint  minPercent = 5; 
    uint public minPayment = 5 finney; 
    
    
    uint dividendsTime = 1 days;
    
    event NewInvestor(address indexed investor, uint deposit);
    event PayOffDividends(address indexed investor, uint value);
    event NewDeposit(address indexed investor, uint value);
    event ResiveFromStubFund(uint value);
    
    uint public allDeposits;
    uint public allPercents;
    uint public allBeneficiaries;
    uint public lastPayment;
    
    struct Beneficiaries{
      address investorAddress;
      uint registerTime;
      uint persentWithdraw;
      uint ethWithdraw;
      uint deposits;
      bool real;
      
  }
  
  mapping(address => Beneficiaries) beneficiaries;
  
  
  function setStubFund(address _address)onlyOwner public{
      require(_address>0, 'Incorrect address');
      stabFund = _address;
      
      
  }
  
  
  function insertBeneficiaries(address _address, uint _persentWithdraw, uint _ethWithdraw, uint _deposits)private{
      
      Beneficiaries storage s_beneficiaries = beneficiaries[_address];
      
      if (!s_beneficiaries.real){
          
          s_beneficiaries.real = true;
          s_beneficiaries.investorAddress = _address;
          s_beneficiaries.persentWithdraw = _persentWithdraw;
          s_beneficiaries.ethWithdraw = _ethWithdraw;
          s_beneficiaries.deposits = _deposits;
          s_beneficiaries.registerTime = now;
          
          allBeneficiaries+=1;
      }else{
          s_beneficiaries.persentWithdraw += _persentWithdraw;
          s_beneficiaries.ethWithdraw += _ethWithdraw;
      }
  } 
  
  function getBeneficiaries(address _address)public view returns(
      address investorAddress,
      uint persentWithdraw,
      uint ethWithdraw,
      uint registerTime 
      ){
      
      Beneficiaries storage s_beneficiaries = beneficiaries[_address];
      
      require(s_beneficiaries.real, '404: Investor Not Found :(');
      
      
      return(
          s_beneficiaries.investorAddress,
          s_beneficiaries.persentWithdraw,
          s_beneficiaries.ethWithdraw,
          s_beneficiaries.registerTime
          );
  } 
    
    
    
    modifier isIssetRecepient(){
        require(balances[msg.sender] > 0, "Deposit not found");
        _;
    }
    
    


    modifier timeCheck(){
        
         require(now >= time[msg.sender].add(dividendsTime), "Too fast payout request");
         _;
        
    }
    
   
    function receivePayment()isIssetRecepient timeCheck internal{
        uint percent = getPercent();
        uint rate = balances[msg.sender].mul(percent).div(1000);
        time[msg.sender] = now;
        msg.sender.transfer(rate);
        
        allPercents+=rate;
        lastPayment =now;
        
        insertBeneficiaries(msg.sender, percent, rate,0);
        emit PayOffDividends(msg.sender, rate);
        
    }
    
    
    function authorizationPayment()public view returns(bool){
        
        if (balances[msg.sender] > 0 && now >= (time[msg.sender].add(dividendsTime))){
            return (true);
        }else{
            return(false);
        }
        
    }
   
    
    function getPercent()internal  returns(uint){
        
        
        uint value = balances[msg.sender].mul(standartPersent).div(1000);
        uint min_value = balances[msg.sender].mul(minPercent).div(1000);
        
        
        
        if(address(this).balance < min_value){
            
            EtheroStabilizationFund stubF = EtheroStabilizationFund(stabFund);
            require(stubF.ReturnEthToEthero(), 'Forgive, the stabilization fund can not cover your deposit, try to withdraw your interest later ');
            emit ResiveFromStubFund(25);
        }
        
        
        
        uint contractBalance = address(this).balance;
        
        require(contractBalance > min_value, 'Out of money, wait a few days, we will attract new investments');
       
        if(contractBalance > (value.mul(standartPersent).div(1000))){
            return(30);
        }
        if(contractBalance > (value.mul(standartPersent.sub(5)).div(1000))){
            return(25);
        }
        if(contractBalance > (value.mul(standartPersent.sub(10)).div(1000))){
            return(20);
        }
        if(contractBalance > (value.mul(standartPersent.sub(15)).div(1000))){
            return(15);
        }
        if(contractBalance > (value.mul(standartPersent.sub(20)).div(1000))){
            return(10);
        }
         if(contractBalance > (value.mul(standartPersent.sub(25)).div(1000))){
            return(5);
        }
        
        
        
    }
    
    function createDeposit() private{
        
        uint value = msg.value;
        uint rateFund1 = value.mul(5).div(100);
        uint rateFund2 = value.mul(5).div(100);
        uint rateStubFund = value.mul(10).div(100);
        
        if(msg.value > 0){
            
            if (balances[msg.sender] == 0){
                emit NewInvestor(msg.sender, msg.value);
            }
            
            balances[msg.sender] = balances[msg.sender].add(msg.value);
            time[msg.sender] = now;
            insertBeneficiaries(msg.sender,0,0, msg.value);
            
            fund1.transfer(rateFund1);
            fund2.transfer(rateFund2);
            stabFund.call.value(rateStubFund).gas(estGas)();
            
            allDeposits+=msg.value;
            
            emit NewDeposit(msg.sender, msg.value);
            
        }else{
            
            receivePayment();
            
        }
        
    }
    
    function() external payable{
        
        
        require((balances[msg.sender].add(msg.value)) >= balances[msg.sender]);
        if(msg.sender!=stabFund){
            createDeposit();
        }else{
            emit ResiveFromStubFund(msg.value);
        }        
        
       
    }
    
    
}