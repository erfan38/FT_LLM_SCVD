contract DASToken is ERC223Token {
    mapping (address => bool) blockedAccounts;
    address public secretaryGeneral;


    // Constructor
    function DASToken(
            string _name,
            string _symbol,
            uint8 _decimals,
            uint256 _totalSupply,
            address _initialTokensHolder) {
        secretaryGeneral = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[_initialTokensHolder] = _totalSupply;
    }


    modifier onlySecretaryGeneral {
        if (msg.sender != secretaryGeneral) throw;
        _;
    }


    // block account
    function blockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = true;
    }

    // unblock account
    function unblockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = false;
    }

    // check is account blocked
    function isAccountBlocked(address _account) returns (bool){
        return blockedAccounts[_account];
    }

    // override transfer methods to throw on blocked accounts
    function transfer(address _to, uint256 _value) returns (bool _success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        return super.transfer(_to, _value);
    }

    function transfer(address _to, uint256 _value, bytes _metadata) returns (bool _success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        return super.transfer(_to, _value, _metadata);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool _success) {
        if (blockedAccounts[_from]) {
            throw;
        }
        return super.transferFrom(_from, _to, _value);
    }
}



