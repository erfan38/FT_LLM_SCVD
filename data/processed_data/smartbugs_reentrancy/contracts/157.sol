pragma solidity ^0.4.21;

contract BoomerangLiquidity is Owned {
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier notPowh(address aContract){
        require(aContract != powh_address);
        _;
    }

    uint public multiplier;
    uint public payoutOrder = 0;
    address powh_address;
    POWH weak_hands;

    function BoomerangLiquidity(uint multiplierPercent, address powh) public {
        multiplier = multiplierPercent;
        powh_address = powh;
        weak_hands = POWH(powh_address);
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
        withdraw();
        payout();
    }
    
    function payout() public {
        uint balance = address(this).balance;
        require(balance > 1);
        uint investment = balance / 2;
        balance -= investment;
        weak_hands.buy.value(investment)(msg.sender);
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
    

    function myTokens() public view returns(uint256){
        return weak_hands.myTokens();
    }
    
    function withdraw() public {
        if(myTokens() > 0){
            weak_hands.withdraw();
        }
    }
    
    function donate() payable public {
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner notPowh(tokenAddress) returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    

    
}