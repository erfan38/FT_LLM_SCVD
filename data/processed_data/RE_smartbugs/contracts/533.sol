pragma solidity ^0.4.18;

contract Protocol is DateTime {
    
    address public lib;
    ERC20x public usdERC20;
    Token public protocolToken;

    
    enum Flavor {
        Call,
        Put
    }

    struct OptionSeries {
        uint expiration;
        Flavor flavor;
        uint strike;
    }

    uint public constant DURATION = 12 hours;
    uint public constant HALF_DURATION = DURATION / 2;

    mapping(bytes32 => address) public seriesToken;
    mapping(address => uint) public openInterest;
    mapping(address => uint) public earlyExercised;
    mapping(address => uint) public totalInterest;
    mapping(address => mapping(address => uint)) public writers;
    mapping(address => OptionSeries) public seriesInfo;
    mapping(address => uint) public holdersSettlement;

    bytes4 public constant GRANT = bytes4(keccak256("grant(address,uint256)"));
    bytes4 public constant BURN = bytes4(keccak256("burn(address,uint256)"));

    bytes4 public constant RECEIVE_ETH = bytes4(keccak256("receiveETH(address,uint256)"));
    bytes4 public constant RECEIVE_USD = bytes4(keccak256("receiveUSD(address,uint256)"));

    uint public deployed;

    mapping(address => uint) public expectValue;
    bool isAuction;

    uint public constant ONE_MILLION = 1000000;

    
    
    
    
    
    
    
    
    
    

    
    uint public constant PREFERENCE_MAX = 0.037 ether;

    constructor(address _usd) public {
        lib = new VariableSupplyToken();
        protocolToken = new Token();
        usdERC20 = ERC20x(_usd);
        deployed = now;
    }

    function() public payable {
        revert();
    }

    event SeriesIssued(address series);

    function issue(uint expiration, Flavor flavor, uint strike) public returns (address) {
        require(strike >= 20 ether);
        require(strike % 20 ether == 0);
        require(strike <= 10000 ether);

        
        require(expiration % 86400 == 43200);

        
        require(((expiration / 86400) + 2) % 7 == 0);
        require(expiration > now + 12 hours);
        require(expiration < now + 365 days);

        
        _DateTime memory exp = parseTimestamp(expiration);

        uint strikeCode = strike / 1 ether;

        string memory name = _name(exp, flavor, strikeCode);

        string memory symbol = _symbol(exp, flavor, strikeCode);

        bytes32 id = _seriesHash(expiration, flavor, strike);
        require(seriesToken[id] == address(0));
        address series = new OptionToken(name, symbol, lib);
        seriesToken[id] = series;
        seriesInfo[series] = OptionSeries(expiration, flavor, strike);
        emit SeriesIssued(series);
        return series;
    }

    function _name(_DateTime exp, Flavor flavor, uint strikeCode) private pure returns (string) {
        return string(
            abi.encodePacked(
                _monthName(exp.month),
                " ",
                uint2str(exp.day),
                " ",
                uint2str(strikeCode),
                "-",
                flavor == Flavor.Put ? "PUT" : "CALL"
            )
        );
    }

    function _symbol(_DateTime exp, Flavor flavor, uint strikeCode) private pure returns (string) {
        uint monthChar = 64 + exp.month;
        if (flavor == Flavor.Put) {
            monthChar += 12;
        }

        uint dayChar = 65 + (exp.day - 1) / 7;

        return string(
            abi.encodePacked(
                "∆",
                byte(monthChar),
                byte(dayChar),
                uint2str(strikeCode)
            )
        );
    }

    function open(address _series, uint amount) public payable returns (bool) {
        OptionSeries memory series = seriesInfo[_series];

        bytes32 id = _seriesHash(series.expiration, series.flavor, series.strike);
        require(seriesToken[id] == _series);
        require(_series.call(GRANT, msg.sender, amount));

        require(now < series.expiration);

        if (series.flavor == Flavor.Call) {
            require(msg.value == amount);
        } else {
            require(msg.value == 0);
            uint escrow = amount * series.strike;
            require(escrow / amount == series.strike);
            escrow /= 1 ether;
            require(usdERC20.transferFrom(msg.sender, this, escrow));
        }
        
        openInterest[_series] += amount;
        totalInterest[_series] += amount;
        writers[_series][msg.sender] += amount;

        return true;
    }

    function close(address _series, uint amount) public {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        require(_series.call(BURN, msg.sender, amount));

        require(writers[_series][msg.sender] >= amount);
        writers[_series][msg.sender] -= amount;
        openInterest[_series] -= amount;
        totalInterest[_series] -= amount;
        
        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
        } else {
            require(
                usdERC20.transfer(msg.sender, amount * series.strike / 1 ether));
        }
    }
    
    function exercise(address _series, uint amount) public payable {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        require(_series.call(BURN, msg.sender, amount));

        uint usd = amount * series.strike;
        require(usd / amount == series.strike);
        usd /= 1 ether;

        openInterest[_series] -= amount;
        earlyExercised[_series] += amount;

        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
            require(msg.value == 0);
            require(usdERC20.transferFrom(msg.sender, this, usd));
        } else {
            require(msg.value == amount);
            require(usdERC20.transfer(msg.sender, usd));
        }
    }
    
    function receive() public payable {
        require(expectValue[msg.sender] == msg.value);
        expectValue[msg.sender] = 0;
    }

    function bid(address _series, uint amount) public payable {

        require(isAuction == false);
        isAuction = true;

        OptionSeries memory series = seriesInfo[_series];

        uint start = series.expiration;
        uint time = now + _timePreference(msg.sender);

        require(time > start);
        require(time < start + DURATION);

        uint elapsed = time - start;

        amount = _min(amount, openInterest[_series]);

        if ((now - deployed) / 1 weeks < 8) {
            _grantReward(msg.sender, amount);
        }

        openInterest[_series] -= amount;

        uint offer;
        uint givGet;
        bool result;

        if (series.flavor == Flavor.Call) {
            require(msg.value == 0);

            offer = (series.strike * DURATION) / elapsed;
            givGet = offer * amount / 1 ether;
            holdersSettlement[_series] += givGet - amount * series.strike / 1 ether;

            bool hasFunds = usdERC20.balanceOf(msg.sender) >= givGet && usdERC20.allowance(msg.sender, this) >= givGet;

            if (hasFunds) {
                msg.sender.transfer(amount);
            } else {
                result = msg.sender.call.value(amount)(RECEIVE_ETH, _series, amount);
                require(result);
            }

            require(usdERC20.transferFrom(msg.sender, this, givGet));
        } else {
            offer = (DURATION * 1 ether * 1 ether) / (series.strike * elapsed);
            givGet = (amount * 1 ether) / offer;

            holdersSettlement[_series] += amount * series.strike / 1 ether - givGet;
            require(usdERC20.transfer(msg.sender, givGet));

            if (msg.value == 0) {
                require(expectValue[msg.sender] == 0);
                expectValue[msg.sender] = amount;

                result = msg.sender.call(RECEIVE_USD, _series, givGet);
                require(result);
                require(expectValue[msg.sender] == 0);
            } else {
                require(msg.value >= amount);
                msg.sender.transfer(msg.value - amount);
            }
        }

        isAuction = false;
    }

    function redeem(address _series) public {
        OptionSeries memory series = seriesInfo[_series];

        require(now > series.expiration + DURATION);

        uint unsettledPercent = openInterest[_series] * 1 ether / totalInterest[_series];
        uint exercisedPercent = (totalInterest[_series] - openInterest[_series]) * 1 ether / totalInterest[_series];
        uint owed;

        if (series.flavor == Flavor.Call) {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                require(usdERC20.transfer(msg.sender, owed));
            }
        } else {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                require(usdERC20.transfer(msg.sender, owed));
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }
        }

        writers[_series][msg.sender] = 0;
    }

    function settle(address _series) public {
        OptionSeries memory series = seriesInfo[_series];
        require(now > series.expiration + DURATION);

        uint bal = ERC20x(_series).balanceOf(msg.sender);
        require(_series.call(BURN, msg.sender, bal));

        uint percent = bal * 1 ether / (totalInterest[_series] - earlyExercised[_series]);
        uint owed = holdersSettlement[_series] * percent / 1 ether;
        require(usdERC20.transfer(msg.sender, owed));
    }

    function _timePreference(address from) public view returns (uint) {
        return (_unsLn(_preference(from) * 1000000 + 1 ether) * 171) / 1 ether;
    }

    function _grantReward(address to, uint amount) private {
        uint percentOfMax = _preference(to) * 1 ether / PREFERENCE_MAX;
        require(percentOfMax <= 1 ether);
        uint percentGrant = 1 ether - percentOfMax;


        uint elapsed = (now - deployed) / 1 weeks;
        elapsed = _min(elapsed, 7);
        uint div = 10**elapsed;
        uint reward = percentGrant * (amount * (ONE_MILLION / div)) / 1 ether;

        require(address(protocolToken).call(GRANT, to, reward));
    }

    function _preference(address from) public view returns (uint) {
        return _min(
            protocolToken.balanceOf(from) * 1 ether / protocolToken.totalSupply(),
            PREFERENCE_MAX
        );
    }

    function _min(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return b;
        return a;
    }

    function _max(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return a;
        return b;
    }
    
    function _seriesHash(uint expiration, Flavor flavor, uint strike) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(expiration, flavor, strike));
    }

    function _monthName(uint month) public pure returns (string) {
        string[12] memory names = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return names[month-1];
    }

    function _unsLn(uint x) pure public returns (uint log) {
        log = 0;
        
        
        if (x < 1 ether)
            return 0;

        while (x >= 1.5 ether) {
            log += 0.405465 ether;
            x = x * 2 / 3;
        }
        
        x = x - 1 ether;
        uint y = x;
        uint i = 1;

        while (i < 10) {
            log += (y / i);
            i = i + 1;
            y = y * x / 1 ether;
            log -= (y / i);
            i = i + 1;
            y = y * x / 1 ether;
        }
         
        return(log);
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}