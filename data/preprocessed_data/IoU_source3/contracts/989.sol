contract Lottery {
 uint public ticketPrice;
 uint public totalPool;

 function buyTickets(uint numberOfTickets) public payable {
 require(msg.value >= ticketPrice * numberOfTickets, "Insufficient payment");
 totalPool += msg.value;
 }
}