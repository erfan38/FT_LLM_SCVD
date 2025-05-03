contract Ownable {

     address public owner;

     address public pendingOwner;

     address public manager;


     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     

     modifier onlyOwner() {

         require(msg.sender == owner);

         _;

     }


     

     modifier onlyManager() {

         require(msg.sender == manager);

         _;

     }


     

     modifier onlyPendingOwner() {

         require(msg.sender == pendingOwner);

         _;

     }


     constructor() public {

         owner = msg.sender;

     }


     

     function transferOwnership(address newOwner) public onlyOwner {

         pendingOwner = newOwner;

     }


     

     function claimOwnership() public onlyPendingOwner {

         emit OwnershipTransferred(owner, pendingOwner);

         owner = pendingOwner;

         pendingOwner = address(0);

     }


     

     function setManager(address _manager) public onlyOwner {

         require(_manager != address(0));

         manager = _manager;

     }


 }






