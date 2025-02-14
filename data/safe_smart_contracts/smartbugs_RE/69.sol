pragma solidity ^0.4.24;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}







contract ERC827Token is ERC827, StandardToken {

    
















    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.approve(_spender, _value);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

    









    function transferAndCall(
        address _to,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_to != address(this));

        super.transfer(_to, _value);

        
        require(_to.call.value(msg.value)(_data));
        return true;
    }

    










    function transferFromAndCall(
        address _from,
        address _to,
        uint256 _value,
        bytes _data
    )
    public payable returns (bool)
    {
        require(_to != address(this));

        super.transferFrom(_from, _to, _value);

        
        require(_to.call.value(msg.value)(_data));
        return true;
    }

    












    function increaseApprovalAndCall(
        address _spender,
        uint _addedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.increaseApproval(_spender, _addedValue);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

    












    function decreaseApprovalAndCall(
        address _spender,
        uint _subtractedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.decreaseApproval(_spender, _subtractedValue);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

}




