pragma solidity ^0.4.19;

contract Payee{
    
    uint256 public price;
    address public storageAddress;
    address public founder;
    bool public changeable;
    mapping( address => bool) public adminStatus;

    
    
    Storage s;
    event Buy(address addr, uint256 count);
    event SetPrice(address addr, uint256 price);
    event Admin(address addr, bool yesno);

    
    modifier onlyAdmin() {
        assert (adminStatus[msg.sender]==true);
        _;
    }
    
    modifier onlyFounder() {
        require(msg.sender==founder);
        _;
    }
    
    function admin(address addr) public onlyFounder(){
        adminStatus[addr] = !adminStatus[addr];
        Admin(addr, adminStatus[addr]);
    }
    
    function Payee(address addr) public {
        founder=msg.sender;
        price=3000000000000000; 
        adminStatus[founder]=true;
        storageAddress=addr;
        s=Storage(storageAddress);
        changeable=true;
        
    }
    
    function setPrice(uint256 _price) public onlyAdmin(){
        price=_price;
        SetPrice(msg.sender, price);
    }
    
    function setStorageAddress(address _addr) public onlyAdmin(){
        storageAddress=_addr;
        s=Storage(storageAddress);

    }
    
    function halt() public onlyFounder(){
        changeable=!changeable;
    }
    
    function pay(address _addr, uint256 count) public payable {
        assert(changeable==true);
        assert(msg.value >= price*count);
        if(!founder.call.value(price*count)() || !msg.sender.call.value(msg.value-price*count)()){
            revert();
        }
        s.update(_addr,count);
        Buy(msg.sender,count);
    }
    
    function () public payable {
        pay(msg.sender,1);
    }
}