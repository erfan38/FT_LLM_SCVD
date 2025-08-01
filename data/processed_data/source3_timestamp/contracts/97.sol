contract Token is ERC223 {
    using SafeMath for uint256;

    string constant TOKEN_NAME = "YOUToken";
    string constant TOKEN_SYMBOL = "YOU";
    uint8 constant TOKEN_DECIMALS = 18;  
    address constant public TOKEN_OWNER = 0x57Cdd07287f668eC4D58f3E362b4FCC2bC54F5b8;  

    function () public {

    }

    constructor () public {
        owner = msg.sender;
         
         
        teamFrozenBalances[0x3d220cfDdc45900C78FF47D3D2f4302A2e994370][1546300801] = uint256(1398652000 *10 **18);
         
        teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1546300801] = uint256(131104417 *10 **18);
         
        teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1577836801] = uint256(131104417 *10 **18);
         
        teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1609459201] = uint256(131104417 *10 **18);
         
        teamFrozenBalances[0x41cf7D41ADf0d5de82b35143C9Bbca68af819a89][1546300801] = uint256(87415750 *10 **18);
         
        teamFrozenBalances[0x61c3b0Fc6c6eE51DF1972c5F8DCE4663e573a398][1546300801] = uint256(43707875 *10 **18);
         
        teamFrozenBalances[0x51D8cC55d6Bfc41676a64FefA6BbAc56B61A7104][1546300801] = uint256(87415750 *10 **18);
         
        teamFrozenBalances[0xfBfBF95152FcC8901974d35Ab0AEf172445B3047][1546300801] = uint256(43707875 *10 **18);

        uint256 totalReward = 2054212501 *10 **uint256(TOKEN_DECIMALS);
        totalSupply = totalSupply.add(totalReward);
    }

    function name() pure external returns (string) {
        return TOKEN_NAME;
    }

    function symbol() pure external returns (string) {
        return TOKEN_SYMBOL;
    }

    function decimals() pure external returns (uint8) {
        return uint8(TOKEN_DECIMALS);
    }

    function balanceOf(address _who) public view returns (uint256) {
        return balances[_who];
    }

    function transfer(address _to, uint _value) public {
        require(_to != address(0x00));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        bytes memory data;
        emit Transfer(msg.sender, _to, _value, data);
    }

    function transfer(address _to, uint _value, bytes _data) public {
        require(_to != address(0x00));
        require(balances[msg.sender] >= _value);

        uint codeLength;
         
        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if(codeLength > 0x00) {
            ERC223ReceivingContractInterface receiver = ERC223ReceivingContractInterface(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        emit Transfer(msg.sender, _to, _value, _data);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_from != address(0x00));
        require(_to != address(0x00));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        bytes memory data;
        emit Transfer(_from, _to, _value, data);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        require(_owner != address(0x00));
        require(_spender != address(0x00));

        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        require(_spender != address(0x00));
        require(_addedValue <= balances[msg.sender]);

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        require(_spender != address(0x00));

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0x00;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function mint(address _to, uint256 _amount)
        onlyOwner
        canMint
        public
        returns (bool)
    {
        require(_to != address(0x00));

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        bytes memory data;
        emit Mint(_to, _amount);
        emit Transfer(address(0x00), _to, _amount, data);
        return true;
    }

    function finishMinting()
        onlyOwner
        canMint
        public
        returns (bool)
    {
        mintingFinished = true;

        emit MintFinished();
        return true;
    }

    function burn(uint256 _value) public {
        require(_value > 0x00);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
    }

     
     
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x00));

        owner = _newOwner;

        emit OwnershipTransferred(msg.sender, owner);
    }


    function unfreezeFoundingTeamBalance() public onlyOwner {
        uint64 timestamp = uint64(block.timestamp);
        uint256 fronzenBalance;
         
        require(timestamp >= 1546300801);
         
        if (timestamp < 1577836801) {
         
            fronzenBalance = teamFrozenBalances[0x3d220cfDdc45900C78FF47D3D2f4302A2e994370][1546300801];
            teamFrozenBalances[0x3d220cfDdc45900C78FF47D3D2f4302A2e994370][1546300801] = 0;
            balances[0x3d220cfDdc45900C78FF47D3D2f4302A2e994370] = balances[0x3d220cfDdc45900C78FF47D3D2f4302A2e994370].add(fronzenBalance);
         
            fronzenBalance = teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1546300801];
            teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1546300801] = 0;
            balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97] = balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97].add(fronzenBalance);
         
            fronzenBalance = teamFrozenBalances[0x41cf7D41ADf0d5de82b35143C9Bbca68af819a89][1546300801];
            teamFrozenBalances[0x41cf7D41ADf0d5de82b35143C9Bbca68af819a89][1546300801] = 0;
            balances[0x41cf7D41ADf0d5de82b35143C9Bbca68af819a89] = balances[0x41cf7D41ADf0d5de82b35143C9Bbca68af819a89].add(fronzenBalance);
         
            fronzenBalance = teamFrozenBalances[0x61c3b0Fc6c6eE51DF1972c5F8DCE4663e573a398][1546300801];
            teamFrozenBalances[0x61c3b0Fc6c6eE51DF1972c5F8DCE4663e573a398][1546300801] = 0;
            balances[0x61c3b0Fc6c6eE51DF1972c5F8DCE4663e573a398] = balances[0x61c3b0Fc6c6eE51DF1972c5F8DCE4663e573a398].add(fronzenBalance);
         
            fronzenBalance = teamFrozenBalances[0x51D8cC55d6Bfc41676a64FefA6BbAc56B61A7104][1546300801];
            teamFrozenBalances[0x51D8cC55d6Bfc41676a64FefA6BbAc56B61A7104][1546300801] = 0;
            balances[0x51D8cC55d6Bfc41676a64FefA6BbAc56B61A7104] = balances[0x51D8cC55d6Bfc41676a64FefA6BbAc56B61A7104].add(fronzenBalance);
         
            fronzenBalance = teamFrozenBalances[0xfBfBF95152FcC8901974d35Ab0AEf172445B3047][1546300801];
            teamFrozenBalances[0xfBfBF95152FcC8901974d35Ab0AEf172445B3047][1546300801] = 0;
            balances[0xfBfBF95152FcC8901974d35Ab0AEf172445B3047] = balances[0xfBfBF95152FcC8901974d35Ab0AEf172445B3047].add(fronzenBalance);
         
        } else if(timestamp < 1609459201) {
         
            fronzenBalance = teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1577836801];
            teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1577836801] = 0;
            balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97] = balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97].add(fronzenBalance);
         
        } else {
         
            fronzenBalance = teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1609459201];
            teamFrozenBalances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97][1609459201] = 0;
            balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97] = balances[0xCd975cE2903Cf9F17d924d96d2bC752C06a3BB97].add(fronzenBalance);
        }
    }
}


library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

}


interface ERC223ReceivingContractInterface {
    function tokenFallback(address _from, uint _value, bytes _data) external;
}