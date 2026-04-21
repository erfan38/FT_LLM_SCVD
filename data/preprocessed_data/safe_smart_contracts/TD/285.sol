contract EtherCityData
{
    struct WORLDDATA
    {
        uint256 ethBalance;
        uint256 ethDev;

        uint256 population;
        uint256 credits;

        uint256 starttime;
    }

    struct WORLDSNAPSHOT
    {
        bool valid;
        uint256 ethDay;
        uint256 ethBalance;
        uint256 ethRankFund;
        uint256 ethShopFund;

        uint256 ethRankFundRemain;
        uint256 ethShopFundRemain;

        uint256 population;
        uint256 credits;

        uint256 lasttime;
    }

    struct CITYDATA
    {
        bytes32 name;

        uint256 credits;

        uint256 population;
        uint256 creditsPerSec;    

        uint256 landOccupied;
        uint256 landUnoccupied;

        uint256 starttime;
        uint256 lasttime;
        uint256 withdrawSS;
    }

    struct CITYSNAPSHOT
    {
        bool valid;

        uint256 population;
        uint256 credits;

        uint256 shopCredits;

        uint256 lasttime;
    }

    struct BUILDINGDATA
    {
        uint256 constructCount;
        uint256 upgradeCount;

        uint256 population;
        uint256 creditsPerSec;    
    }

    uint256 private constant INTFLOATDIV = 100;

    address private owner;
    address private admin;
    address private city;
    bool private enabled;

    WORLDDATA private worldData;
    mapping(uint256 => WORLDSNAPSHOT) private worldSnapshot;

    address[] private playerlist;
    mapping(address => CITYDATA) private cityData;
    mapping(address => mapping(uint256 => CITYSNAPSHOT)) private citySnapshot;
    mapping(address => mapping(uint256 => BUILDINGDATA)) private buildings;
    mapping(address => uint256) private ethBalance;


    constructor() public payable
    {
        owner = msg.sender;

        enabled = true;
        worldData = WORLDDATA({ethBalance:0, ethDev:0, population:0, credits:0, starttime:block.timestamp});
        worldSnapshot[nowday()] = WORLDSNAPSHOT({valid:true, ethDay:0, ethBalance:0, ethRankFund:0, ethShopFund:0, ethRankFundRemain:0, ethShopFundRemain:0, population:0, credits:0, lasttime:block.timestamp});
    }

    function GetVersion() external pure returns(uint256)
    {
        return 1001;
    }

    function IsPlayer(address player) external view returns(bool)
    {
        for(uint256 index = 0; index < playerlist.length; index++)
         {
             if (playerlist[index] == player)
                return true;
         }

        return false;
    }

    function IsCityNameExist(bytes32 cityname) external view returns(bool)
    {
        for(uint256 index = 0; index < playerlist.length; index++)
        {
            if (cityData[playerlist[index]].name == cityname)
               return false;
        }

        return true;
    }

    function CreateCityData(address player, uint256 crdtsec, uint256 landcount) external
    {
        uint256 day;

        require(cityData[player].starttime == 0);
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        playerlist.push(player);     

        day = nowday();
        cityData[player] = CITYDATA({name:0, credits:0, population:0, creditsPerSec:crdtsec, landOccupied:0, landUnoccupied:landcount, starttime:block.timestamp, lasttime:block.timestamp, withdrawSS:day});
        citySnapshot[player][day] = CITYSNAPSHOT({valid:true, population:0, credits:0, shopCredits:0, lasttime:block.timestamp});
    }

    function GetWorldData() external view returns(uint256 ethBal, uint256 ethDev, uint256 population, uint256 credits, uint256 starttime)
    {
        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        ethBal = worldData.ethBalance;
        ethDev = worldData.ethDev;
        population = worldData.population;
        credits = worldData.credits;
        starttime = worldData.starttime;
    }

    function SetWorldData(uint256 ethBal, uint256 ethDev, uint256 population, uint256 credits, uint256 starttime) external
    {
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        worldData.ethBalance = ethBal;
        worldData.ethDev = ethDev;
        worldData.population = population;
        worldData.credits = credits;
        worldData.starttime = starttime;
    }

    function SetWorldSnapshot(uint256 day, bool valid, uint256 population, uint256 credits, uint256 lasttime) external
    {
        WORLDSNAPSHOT storage wss = worldSnapshot[day];

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        wss.valid = valid;
        wss.population = population;
        wss.credits = credits;
        wss.lasttime = lasttime;
    }

    function GetCityData(address player) external view returns(uint256 credits, uint256 population, uint256 creditsPerSec,
                                    uint256 landOccupied, uint256 landUnoccupied, uint256 lasttime)
    {
        CITYDATA storage cdata = cityData[player];

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        credits = cdata.credits;
        population = cdata.population;
        creditsPerSec = cdata.creditsPerSec;
        landOccupied = cdata.landOccupied;
        landUnoccupied = cdata.landUnoccupied;
        lasttime = cdata.lasttime;
    }

    function SetCityData(address player, uint256 credits, uint256 population, uint256 creditsPerSec,
                        uint256 landOccupied, uint256 landUnoccupied, uint256 lasttime) external
    {
        CITYDATA storage cdata = cityData[player];

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        cdata.credits = credits;
        cdata.population = population;
        cdata.creditsPerSec = creditsPerSec;
        cdata.landOccupied = landOccupied;
        cdata.landUnoccupied = landUnoccupied;
        cdata.lasttime = lasttime;
    }

    function GetCityName(address player) external view returns(bytes32)
    {
        return cityData[player].name;
    }

    function SetCityName(address player, bytes32 name) external
    {
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        cityData[player].name = name;
    }

    function GetCitySnapshot(address player, uint256 day) external view returns(bool valid, uint256 population, uint256 credits, uint256 shopCredits, uint256 lasttime)
    {
        CITYSNAPSHOT storage css = citySnapshot[player][day];

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        valid = css.valid;
        population = css.population;
        credits = css.credits;
        shopCredits = css.shopCredits;
        lasttime = css.lasttime;
    }

    function SetCitySnapshot(address player, uint256 day, bool valid, uint256 population, uint256 credits, uint256 shopCredits, uint256 lasttime) external
    {
        CITYSNAPSHOT storage css = citySnapshot[player][day];

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        css.valid = valid;
        css.population = population;
        css.credits = credits;
        css.shopCredits = shopCredits;
        css.lasttime = lasttime;
    }

    function GetBuildingData(address player, uint256 id) external view returns(uint256 constructCount, uint256 upgradeCount, uint256 population, uint256 creditsPerSec)
    {
        BUILDINGDATA storage bdata = buildings[player][id];

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        constructCount = bdata.constructCount;
        upgradeCount = bdata.upgradeCount;
        population = bdata.population;
        creditsPerSec = bdata.creditsPerSec;
    }

    function SetBuildingData(address player, uint256 id, uint256 constructCount, uint256 upgradeCount, uint256 population, uint256 creditsPerSec) external
    {
        BUILDINGDATA storage bdata = buildings[player][id];

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        bdata.constructCount = constructCount;
        bdata.upgradeCount = upgradeCount;
        bdata.population = population;
        bdata.creditsPerSec = creditsPerSec;
    }

    function GetEthBalance(address player) external view returns(uint256)
    {
        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        return ethBalance[player];
    }

    function SetEthBalance(address player, uint256 eth) external
    {
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        ethBalance[player] = eth;
    }

    function AddEthBalance(address player, uint256 eth) external
    {
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        ethBalance[player] += eth;
    }

    function GetWithdrawBalance(address player) external view returns(uint256 ethBal)
    {
        uint256 startday;

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        ethBal = ethBalance[player];

        startday = cityData[player].withdrawSS;
        for(uint256 day = nowday() - 1; day >= startday; day--)
        {
            WORLDSNAPSHOT memory wss = TestWorldSnapshotInternal(day);
            CITYSNAPSHOT memory css = TestCitySnapshotInternal(player, day);
            ethBal += Math.min256(SafeMath.muldiv(wss.ethRankFund, css.population, wss.population), wss.ethRankFundRemain);
        }
    }

    function WithdrawEther(address player) external
    {
        uint256 startday;
        uint256 ethBal;
        uint256 eth;
        CITYDATA storage cdata = cityData[player];

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        ethBal = ethBalance[player];

        startday = cdata.withdrawSS;
        for(uint256 day = nowday() - 1; day >= startday; day--)
        {
            WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(day);
            CITYSNAPSHOT storage css = ValidateCitySnapshotInternal(player, day);

            if (wss.ethRankFundRemain > 0)
            {
                eth = Math.min256(SafeMath.muldiv(wss.ethRankFund, css.population, wss.population), wss.ethRankFundRemain);
                wss.ethRankFundRemain -= eth;
                ethBal += eth;
            }
        }

        require(0 < ethBal);

        ethBalance[player] = 0;
        cdata.withdrawSS = nowday() - 1;

        player.transfer(ethBal);
    }

    function GetEthShop(address player) external view returns(uint256 shopEth, uint256 shopCredits)
    {
        uint256 day;
        CITYSNAPSHOT memory css;
        WORLDSNAPSHOT memory wss;

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        day = nowday() - 1;
        if (day < cityData[player].starttime / 24 hours)
        {
            shopEth = 0;
            shopCredits = 0;
            return;
        }

        wss = TestWorldSnapshotInternal(day);
        css = TestCitySnapshotInternal(player, day);

        shopEth = Math.min256(SafeMath.muldiv(wss.ethShopFund, css.shopCredits, wss.credits), wss.ethShopFundRemain);
        shopCredits = css.shopCredits;
    }

    function TradeEthShop(address player, uint256 credits) external
    {
        uint256 day;
        uint256 shopEth;

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        day = nowday() - 1;
        require(day >= cityData[player].starttime / 24 hours);

        WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(day);
        CITYSNAPSHOT storage css = ValidateCitySnapshotInternal(player, day);

        require(wss.ethShopFundRemain > 0);
        require((0 < credits) && (credits <= css.shopCredits));

        shopEth = Math.min256(SafeMath.muldiv(wss.ethShopFund, css.shopCredits, wss.credits), wss.ethShopFundRemain);

        wss.ethShopFundRemain -= shopEth;
        css.shopCredits -= credits;

        ethBalance[player] += shopEth;
    }

    function UpdateEthBalance(uint256 bal, uint256 devf, uint256 rnkf, uint256 shpf) external payable
    {
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        worldData.ethBalance += bal + devf + rnkf + shpf;
        worldData.ethDev += devf;

        WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(nowday());
        wss.ethDay += bal + devf + rnkf + shpf;
        wss.ethBalance += bal;
        wss.ethRankFund += rnkf;
        wss.ethShopFund += shpf;
        wss.ethRankFundRemain += rnkf;
        wss.ethShopFundRemain += shpf;
        wss.lasttime = block.timestamp;

        ethBalance[owner] += devf;
    }

    function ValidateWorldSnapshot(uint256 day) external returns(uint256 ethRankFund, uint256 population, uint256 credits, uint256 lasttime)
    {
        WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(day);

        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        ethRankFund = wss.ethRankFund;
        population = wss.population;
        credits = wss.credits;
        lasttime = wss.lasttime;
    }

    function TestWorldSnapshot(uint256 day) external view returns(uint256 ethRankFund, uint256 population, uint256 credits, uint256 lasttime)
    {
        WORLDSNAPSHOT memory wss = TestWorldSnapshotInternal(day);

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        ethRankFund = wss.ethRankFund;
        population = wss.population;
        credits = wss.credits;
        lasttime = wss.lasttime;
    }

    function ValidateCitySnapshot(address player, uint256 day) external returns(uint256 population, uint256 credits, uint256 shopCredits, uint256 lasttime)
    {
        CITYSNAPSHOT storage css = ValidateCitySnapshotInternal(player, day);
    
        require(owner == msg.sender || admin == msg.sender || (enabled && city == msg.sender));

        population = css.population;
        credits = css.credits;
        shopCredits = css.shopCredits;
        lasttime = css.lasttime;
    }

    function TestCitySnapshot(address player, uint256 day) external view returns(uint256 population, uint256 credits, uint256 shopCredits, uint256 lasttime)
    {
        CITYSNAPSHOT memory css = TestCitySnapshotInternal(player, day);

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        population = css.population;
        credits = css.credits;
        shopCredits = css.shopCredits;
        lasttime = css.lasttime;
    }

     
     
    function nowday() private view returns(uint256)
    {
        return block.timestamp / 24 hours;
    }

    function adminSetAdmin(address addr) external
    {
        require(owner == msg.sender);

        admin = addr;
    }

    function adminSetCity(address addr) external
    {
        require(owner == msg.sender || admin == msg.sender);

        city = addr;
    }

    function adminGetEnabled() external view returns(bool)
    {
        require(owner == msg.sender || admin == msg.sender);

        return enabled;
    }

    function adminSetEnabled(bool bval) external
    {
        require(owner == msg.sender || admin == msg.sender);

        enabled = bval;
    }

    function adminGetWorldData() external view returns(uint256 eth, uint256 ethDev,
                                                 uint256 population, uint256 credits, uint256 starttime)
    {
        require(msg.sender == owner || msg.sender == admin);

        eth = worldData.ethBalance;
        ethDev = worldData.ethDev;
        population = worldData.population;
        credits = worldData.credits;
        starttime = worldData.starttime;
    }

    function adminGetWorldSnapshot(uint256 day) external view returns(bool valid, uint256 ethDay, uint256 ethBal, uint256 ethRankFund, uint256 ethShopFund, uint256 ethRankFundRemain,
                                uint256 ethShopFundRemain, uint256 population, uint256 credits, uint256 lasttime)
    {
        WORLDSNAPSHOT storage wss = worldSnapshot[day];

        require(owner == msg.sender || admin == msg.sender);

        valid = wss.valid;
        ethDay = wss.ethDay;
        ethBal = wss.ethBalance;
        ethRankFund = wss.ethRankFund;
        ethShopFund = wss.ethShopFund;
        ethRankFundRemain = wss.ethRankFundRemain;
        ethShopFundRemain = wss.ethShopFundRemain;
        population = wss.population;
        credits = wss.credits;
        lasttime = wss.lasttime;
    }

    function adminSetWorldSnapshot(uint256 day, bool valid, uint256 ethDay, uint256 ethBal, uint256 ethRankFund, uint256 ethShopFund, uint256 ethRankFundRemain,
                                uint256 ethShopFundRemain, uint256 population, uint256 credits, uint256 lasttime) external
    {
        WORLDSNAPSHOT storage wss = worldSnapshot[day];

        require(owner == msg.sender || admin == msg.sender);

        wss.valid = valid;
        wss.ethDay = ethDay;
        wss.ethBalance = ethBal;
        wss.ethRankFund = ethRankFund;
        wss.ethShopFund = ethShopFund;
        wss.ethRankFundRemain = ethRankFundRemain;
        wss.ethShopFundRemain = ethShopFundRemain;
        wss.population = population;
        wss.credits = credits;
        wss.lasttime = lasttime;
    }

    function adminGetCityData(address player) external view returns(bytes32 name, uint256 credits, uint256 population, uint256 creditsPerSec,
                                    uint256 landOccupied, uint256 landUnoccupied, uint256 starttime, uint256 lasttime, uint256 withdrawSS)
    {
        CITYDATA storage cdata = cityData[player];

        require(owner == msg.sender || admin == msg.sender);

        name = cdata.name;
        credits = cdata.credits;
        population = cdata.population;
        creditsPerSec = cdata.creditsPerSec;
        landOccupied = cdata.landOccupied;
        landUnoccupied = cdata.landUnoccupied;
        starttime = cdata.starttime;
        lasttime = cdata.lasttime;
        withdrawSS = cdata.withdrawSS;
    }

    function adminSetCityData(address player, bytes32 name, uint256 credits, uint256 population, uint256 creditsPerSec,
                        uint256 landOccupied, uint256 landUnoccupied, uint256 starttime, uint256 lasttime, uint256 withdrawSS) external
    {
        CITYDATA storage cdata = cityData[player];

        require(owner == msg.sender || admin == msg.sender);

        cdata.name = name;
        cdata.credits = credits;
        cdata.population = population;
        cdata.creditsPerSec = creditsPerSec;
        cdata.landOccupied = landOccupied;
        cdata.landUnoccupied = landUnoccupied;
        cdata.starttime = starttime;
        cdata.lasttime = lasttime;
        cdata.withdrawSS = withdrawSS;
    }

    function adminUpdateWorldSnapshot() external
    {
        require(msg.sender == owner || msg.sender == admin);

        ValidateWorldSnapshotInternal(nowday());
    }

    function adminGetPastShopFund() external view returns(uint256 ethBal)
    {
        uint256 startday;
        WORLDSNAPSHOT memory wss;

        require(msg.sender == owner || msg.sender == admin);

        ethBal = 0;

        startday = worldData.starttime / 24 hours;
        for(uint256 day = nowday() - 2; day >= startday; day--)
        {
            wss = TestWorldSnapshotInternal(day);
            ethBal += wss.ethShopFundRemain;
        }
    }

    function adminCollectPastShopFund() external
    {
        uint256 startday;
        uint256 ethBal;

        require(msg.sender == owner || msg.sender == admin);

        ethBal = ethBalance[owner];

        startday = worldData.starttime / 24 hours;
        for(uint256 day = nowday() - 2; day >= startday; day--)
        {
            WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(day);

            ethBal += wss.ethShopFundRemain;
            wss.ethShopFundRemain = 0;
        }

        ethBalance[owner] = ethBal;
    }

    function adminSendWorldBalance() external payable
    {
        require(msg.sender == owner || msg.sender == admin);

        WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(nowday());
        wss.ethBalance += msg.value;
    }

    function adminTransferWorldBalance(uint256 eth) external
    {
        require(msg.sender == owner || msg.sender == admin);

        WORLDSNAPSHOT storage wss = ValidateWorldSnapshotInternal(nowday());
        require(eth <= wss.ethBalance);

        ethBalance[owner] += eth;
        wss.ethBalance -= eth;
    }

    function adminGetContractBalance() external view returns(uint256)
    {
        require(msg.sender == owner || msg.sender == admin);

        return address(this).balance;
    }

    function adminTransferContractBalance(uint256 eth) external
    {
        require(msg.sender == owner || msg.sender == admin);
        owner.transfer(eth);
    }

    function adminGetPlayerCount() external view returns(uint256)
    {
        require(msg.sender == owner || msg.sender == admin);

        return playerlist.length;
    }

    function adminGetPlayer(uint256 index) external view returns(address player, uint256 eth)
    {
        require(msg.sender == owner || msg.sender == admin);

        player = playerlist[index];
        eth = ethBalance[player];
    }


     
     
    function ValidateWorldSnapshotInternal(uint256 day) private returns(WORLDSNAPSHOT storage)
    {
        uint256 fndf;
        uint256 sday;

        sday = day;
        while (!worldSnapshot[sday].valid)
            sday--;

        WORLDSNAPSHOT storage prev = worldSnapshot[sday];
        sday++;

        while (sday <= day)
        {
            worldSnapshot[sday] = WORLDSNAPSHOT({valid:true, ethDay:0, ethBalance:0, ethRankFund:0, ethShopFund:0, ethRankFundRemain:0, ethShopFundRemain:0, population:prev.population, credits:prev.credits, lasttime:prev.lasttime / 24 hours + 1});
            WORLDSNAPSHOT storage wss = worldSnapshot[sday];
            wss.ethBalance = prev.ethBalance * 90 /100;
            fndf = prev.ethBalance - wss.ethBalance;
            wss.ethRankFund = fndf * 70 / 100;
            wss.ethShopFund = fndf - wss.ethRankFund;
            wss.ethRankFund = wss.ethRankFund;
            wss.ethShopFund = wss.ethShopFund;
            wss.ethRankFundRemain = wss.ethRankFund;
            wss.ethShopFundRemain = wss.ethShopFund;

            prev = wss;
            sday++;
        }

        return prev;
    }

    function TestWorldSnapshotInternal(uint256 day) private view returns(WORLDSNAPSHOT memory)
    {
        uint256 fndf;
        uint256 sday;

        sday = day;
        while (!worldSnapshot[sday].valid)
            sday--;

        WORLDSNAPSHOT memory prev = worldSnapshot[sday];
        sday++;

        while (sday <= day)
        {
            WORLDSNAPSHOT memory wss = WORLDSNAPSHOT({valid:true, ethDay:0, ethBalance:0, ethRankFund:0, ethShopFund:0, ethRankFundRemain:0, ethShopFundRemain:0, population:prev.population, credits:prev.credits, lasttime:prev.lasttime / 24 hours + 1});
            wss.ethBalance = prev.ethBalance * 90 /100;
            fndf = prev.ethBalance - wss.ethBalance;
            wss.ethRankFund = fndf * 70 / 100;
            wss.ethShopFund = fndf - wss.ethRankFund;
            wss.ethRankFund = wss.ethRankFund;
            wss.ethShopFund = wss.ethShopFund;
            wss.ethRankFundRemain = wss.ethRankFund;
            wss.ethShopFundRemain = wss.ethShopFund;

            prev = wss;
            sday++;
        }

        return prev;
    }

    function ValidateCitySnapshotInternal(address player, uint256 day) private returns(CITYSNAPSHOT storage)
    {
        uint256 sday;

        sday = day;
        while (!citySnapshot[player][sday].valid)
            sday--;

        CITYSNAPSHOT storage css = citySnapshot[player][sday];
        sday++;

        while (sday <= day)
        {
            citySnapshot[player][sday] = CITYSNAPSHOT({valid:true, population:css.population, credits:css.credits, shopCredits:css.credits, lasttime:sday * 24 hours});
            css = citySnapshot[player][sday];
            sday++;
        }
    
        return css;
    }

    function TestCitySnapshotInternal(address player, uint256 day) private view returns(CITYSNAPSHOT memory)
    {
        uint256 sday;

        sday = day;
        while (!citySnapshot[player][sday].valid)
            sday--;

        CITYSNAPSHOT memory css = citySnapshot[player][sday];
        sday++;

        while (sday <= day)
        {
            css = CITYSNAPSHOT({valid:true, population:css.population, credits:css.credits, shopCredits:css.credits, lasttime:sday * 24 hours});
            sday++;
        }

        return css;
    }
}


