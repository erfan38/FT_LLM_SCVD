contract ERC20Extending is TokenERC20
{
    using SafeMath for uint;

     
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner
    {
        _to.transfer(amount);
    }

     
    function transferTokensFromContract(address _to, uint256 _value) public onlyOwner
    {
        avaliableSupply = avaliableSupply.sub(_value);
        _transfer(this, _to, _value);
    }
}

