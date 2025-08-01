contract Caller{
   
   function callCallee(address _addr) public returns(bool){
       bytes4 methodId = bytes4(keccak256("increaseData(uint256)"));
       
       // the second parameter 1 is the parameter sent to the function increaseData() as _val
       return _addr.call(methodId, 1);
   } 
   
}
