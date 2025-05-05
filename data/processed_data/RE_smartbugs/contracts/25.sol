pragma solidity ^0.4.18;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract TorusCoin is StandardToken {
    using SafeMath for uint256;

    string public name = "Torus";
    string public symbol = "TORUS";
    uint256 public decimals = 18;

    uint256 public startDatetime;
    uint256 public endDatetime;

    
    
    address public founder;

    
    address public admin;

    uint256 public coinAllocation = 700 * 10**8 * 10**decimals; 
    uint256 public founderAllocation = 300 * 10**8 * 10**decimals; 

    bool public founderAllocated = false; 

    uint256 public saleTokenSupply = 0; 
    uint256 public salesVolume = 0; 

    bool public halted = false; 

    event Buy(address sender, address recipient, uint256 eth, uint256 tokens);
    event AllocateFounderTokens(address sender, address founder, uint256 tokens);
    event AllocateInflatedTokens(address sender, address holder, uint256 tokens);

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    modifier duringCrowdSale {
        require(block.timestamp >= startDatetime && block.timestamp < endDatetime);
        _;
    }

    



    function TorusCoin(uint256 startDatetimeInSeconds, address founderWallet) public {

        admin = msg.sender;
        founder = founderWallet;

        startDatetime = startDatetimeInSeconds;
        endDatetime = startDatetime + 16 * 1 days;
    }

    


    function() public payable {
        buy(msg.sender);
    }

    



    function buy(address recipient) payable public duringCrowdSale  {

        require(!halted);
        require(msg.value >= 0.01 ether);

        uint256 tokens = msg.value.mul(35e4);

        require(tokens > 0);

        require(saleTokenSupply.add(tokens)<=coinAllocation );

        balances[recipient] = balances[recipient].add(tokens);

        totalSupply_ = totalSupply_.add(tokens);
        saleTokenSupply = saleTokenSupply.add(tokens);
        salesVolume = salesVolume.add(msg.value);

        if (!founder.call.value(msg.value)()) revert(); 

        Buy(msg.sender, recipient, msg.value, tokens);
    }

    


    function allocateFounderTokens() public onlyAdmin {
        require( block.timestamp > endDatetime );
        require(!founderAllocated);

        balances[founder] = balances[founder].add(founderAllocation);
        totalSupply_ = totalSupply_.add(founderAllocation);
        founderAllocated = true;

        AllocateFounderTokens(msg.sender, founder, founderAllocation);
    }

    


    function halt() public onlyAdmin {
        halted = true;
    }

    function unhalt() public onlyAdmin {
        halted = false;
    }

    


    function changeAdmin(address newAdmin) public onlyAdmin  {
        admin = newAdmin;
    }

    


    function changeFounder(address newFounder) public onlyAdmin  {
        founder = newFounder;
    }

     


    function inflate(address holder, uint256 tokens) public onlyAdmin {
        require( block.timestamp > endDatetime );
        require(saleTokenSupply.add(tokens) <= coinAllocation );

        balances[holder] = balances[holder].add(tokens);
        saleTokenSupply = saleTokenSupply.add(tokens);
        totalSupply_ = totalSupply_.add(tokens);

        AllocateInflatedTokens(msg.sender, holder, tokens);

     }

    


    function withdrawForeignTokens(address tokenContract) onlyAdmin public returns (bool) {
        ForeignToken token = ForeignToken(tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(admin, amount);
    }


}