pragma solidity 0.4.23;













































contract IronHands is Owned {
    
    


     
    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    


    modifier notPotj(address aContract) {
        require(aContract != address(potj));
        _;
    }
   
    


    event Deposit(uint256 amount, address depositer);
    event Purchase(uint256 amountSpent, uint256 tokensReceived);
    event Payout(uint256 amount, address creditor);
    event Dividends(uint256 amount);
    event ContinuityBreak(uint256 position, address skipped, uint256 amount);
    event ContinuityAppeal(uint256 oldPosition, uint256 newPosition, address appealer);

    


    struct Participant {
        address etherAddress;
        uint256 payout;
    }

    
    uint256 throughput;
    
    uint256 dividends;
    
    uint256 public multiplier;
    
    uint256 public payoutOrder = 0;
    
    uint256 public backlog = 0;
    
    Participant[] public participants;
    
    mapping(address => uint256) public creditRemaining;
    
    POTJ potj;
    
    address sender;

    


    function IronHands(uint multiplierPercent, address potjAddress) public {
        multiplier = multiplierPercent;
        potj = POTJ(potjAddress);
        sender = msg.sender;
    }
    
    
    



    function() payable public {
        if (msg.sender != address(potj)) {
            deposit();
        }
    }
    
    



 
    function deposit() payable public {
        
        require(msg.value > 1000000);
        
        uint256 amountCredited = (msg.value * multiplier) / 100;
        
        participants.push(Participant(sender, amountCredited));
        
        backlog += amountCredited;
        
        creditRemaining[sender] += amountCredited;
        
        emit Deposit(msg.value, sender);
        
        if(myDividends() > 0){
            
            withdraw();
        }
        
        payout();
    }
    
    



    function payout() public {
        
        uint balance = address(this).balance;
        
        require(balance > 1);
        
        throughput += balance;
        
        uint investment = balance / 2 ether + 1 szabo; 
        
        balance -= investment;
        
        uint256 tokens = potj.buy.value(investment).gas(1000000)(msg.sender);
        
        emit Purchase(investment, tokens);
        
        while (balance > 0) {
            
            uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
            
            if(payoutToSend > 0) {
                
                balance -= payoutToSend;
                
                backlog -= payoutToSend;
                
                creditRemaining[participants[payoutOrder].etherAddress] -= payoutToSend;
                
                participants[payoutOrder].payout -= payoutToSend;
                
                if(participants[payoutOrder].etherAddress.call.value(payoutToSend).gas(1000000)()) {
                    
                    emit Payout(payoutToSend, participants[payoutOrder].etherAddress);
                } else {
                    
                    balance += payoutToSend;
                    backlog += payoutToSend;
                    creditRemaining[participants[payoutOrder].etherAddress] += payoutToSend;
                    participants[payoutOrder].payout += payoutToSend;
                }

            }
            
            if(balance > 0) {
                
                payoutOrder += 1;
            }
            
            if(payoutOrder >= participants.length) {
                return;
            }
        }
    }
    
    


    function myTokens() public view returns(uint256) {
        return potj.myTokens();
    }
    
    


    function myDividends() public view returns(uint256) {
        return potj.myDividends(true);
    }
    
    


    function totalDividends() public view returns(uint256) {
        return dividends;
    }
    
    
    


    function withdraw() public {
        uint256 balance = address(this).balance;
        potj.withdraw.gas(1000000)();
        uint256 dividendsPaid = address(this).balance - balance;
        dividends += dividendsPaid;
        emit Dividends(dividendsPaid);
    }
    
    


    function backlogLength() public view returns (uint256) {
        return participants.length - payoutOrder;
    }
    
    


    function backlogAmount() public view returns (uint256) {
        return backlog;
    } 
    
    


    function totalParticipants() public view returns (uint256) {
        return participants.length;
    }
    
    


    function totalSpent() public view returns (uint256) {
        return throughput;
    }
    
    


    function amountOwed(address anAddress) public view returns (uint256) {
        return creditRemaining[anAddress];
    }
     
     


    function amountIAmOwed() public view returns (uint256) {
        return amountOwed(msg.sender);
    }
    
    


    function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) public onlyOwner notPotj(tokenAddress) returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
    
}