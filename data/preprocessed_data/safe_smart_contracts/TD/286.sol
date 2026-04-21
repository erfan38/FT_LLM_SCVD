contract EtherCity
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
        uint256 population;
        uint256 credits;
        uint256 lasttime;
    }

    struct CITYDATA
    {
        uint256 credits;

        uint256 population;
        uint256 creditsPerSec;    

        uint256 landOccupied;
        uint256 landUnoccupied;

        uint256 lasttime;
    }

    struct CITYSNAPSHOT
    {
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

    EtherCityConfig private config;
    EtherCityData private data;
    EtherCityRank private rank;

     
    event OnConstructed(address player, uint256 id, uint256 count);
    event OnUpdated(address player, uint256 id, uint256 count);
    event OnDemolished(address player, uint256 id, uint256 count);
    event OnBuyLands(address player, uint256 count);
    event OnBuyCredits(address player, uint256 eth);


    constructor() public payable
    {
        owner = msg.sender;
    }

    function GetVersion() external pure returns(uint256)
    {
        return 1001;
    }

    function IsPlayer() external view returns(bool)
    {
        return data.IsPlayer(msg.sender);
    }

    function StartCity() external
    {
        uint256 ethland;
        uint256 maxland;
        uint256 initcrdt;
        uint256 crdtsec;
        uint256 landcount;

        (ethland, maxland, initcrdt, crdtsec, landcount) = config.GetInitData();
        CITYDATA memory cdata = dtCreateCityData(msg.sender, crdtsec, landcount);

        UpdateCityData(cdata, 0, initcrdt, 0, 0);

        dtSetCityData(msg.sender, cdata);
    }

    function GetCityName(address player) external view returns(bytes32)
    {
        return data.GetCityName(player);
    }

    function SetCityName(bytes32 name) external
    {
        data.SetCityName(msg.sender, name);
    }

    function GetWorldSnapshot() external view returns(uint256 ethFund, uint256 population, uint256 credits, 
                                                    uint256 lasttime, uint256 nexttime, uint256 timestamp)
    {
        WORLDSNAPSHOT memory wss;
        
        (ethFund, wss) = dtTestWorldSnapshot(nowday());

        population = wss.population;
        credits = wss.credits;
        lasttime = wss.lasttime;
        nexttime = daytime(nowday() + 1);

        timestamp = block.timestamp;
    }

    function GetCityData() external view returns(bytes32 cityname, uint256 population, uint256 credits, uint256 creditsPerSec,
                                                                    uint256 occupied, uint256 unoccupied, uint256 timestamp)
    {
        CITYDATA memory cdata = dtGetCityData(msg.sender);

        cityname = data.GetCityName(msg.sender);
        credits = CalcIncCredits(cdata) + cdata.credits;
        population = cdata.population;
        creditsPerSec = cdata.creditsPerSec;    
        occupied = cdata.landOccupied;
        unoccupied = cdata.landUnoccupied;
        timestamp = block.timestamp;
    }

    function GetCitySnapshot() external view returns(uint256 population, uint256 credits, uint256 timestamp)
    {
        CITYSNAPSHOT memory css = dtTestCitySnapshot(msg.sender, nowday());

        population = css.population;
        credits = css.credits;
        timestamp = block.timestamp;
    }

    function GetBuildingData(uint256 id) external view returns(uint256 constructCount, uint256 upgradeCount, uint256 population, uint256 creditsPerSec)
    {
        BUILDINGDATA memory bdata = dtGetBuildingData(msg.sender, id);

        constructCount = bdata.constructCount;
        upgradeCount = bdata.upgradeCount;
        (population, creditsPerSec) = CalcBuildingParam(bdata);
    }

    function GetConstructCost(uint256 id, uint256 count) external view returns(uint256 cnstcrdt, uint256 cnsteth)
    {
        (cnstcrdt, cnsteth) = config.GetConstructCost(id, count);
    }

    function ConstructByCredits(uint256 id, uint256 count) external
    {
        CITYDATA memory cdata = dtGetCityData(msg.sender);

        require(count > 0);
        if (!ConstructBuilding(cdata, id, count, true))
            require(false);

        dtSetCityData(msg.sender, cdata);

        emit OnConstructed(msg.sender, id, count);
    }

    function ConstructByEth(uint256 id, uint256 count) external payable
    {
        CITYDATA memory cdata = dtGetCityData(msg.sender);

        require(count > 0);
        if (!ConstructBuilding(cdata, id, count, false))
            require(false);

        dtSetCityData(msg.sender, cdata);

        emit OnConstructed(msg.sender, id, count);
    }

    function BuyLandsByEth(uint256 count) external payable
    {
        uint256 ethland;
        uint256 maxland;

        require(count > 0);

        (ethland, maxland) = config.GetLandData();

        CITYDATA memory cdata = dtGetCityData(msg.sender);
        require(cdata.landOccupied + cdata.landUnoccupied + count <= maxland);

        UpdateEthBalance(ethland * count, msg.value);
        UpdateCityData(cdata, 0, 0, 0, 0);

        cdata.landUnoccupied += count;

        dtSetCityData(msg.sender, cdata);

        emit OnBuyLands(msg.sender, count);
    }

    function BuyCreditsByEth(uint256 eth) external payable
    {
        CITYDATA memory cdata = dtGetCityData(msg.sender);

        require(eth > 0);

        UpdateEthBalance(eth, msg.value);
        UpdateCityData(cdata, 0, 0, 0, 0);

        cdata.credits += eth * config.GetCreditsPerEth();

        dtSetCityData(msg.sender, cdata);

        emit OnBuyCredits(msg.sender, eth);
    }

    function GetUpgradeCost(uint256 id, uint256 count) external view returns(uint256)
    {
        return config.GetUpgradeCost(id, count);
    }

    function UpgradeByCredits(uint256 id, uint256 count) external
    {
        uint256 a_population;
        uint256 a_crdtsec;
        uint256 updcrdt;
        CITYDATA memory cdata = dtGetCityData(msg.sender);
        
        require(count > 0);

        (a_population, a_crdtsec) = UpdateBuildingParam(cdata, id, 0, count);
        require((a_population > 0) || (a_crdtsec > 0));

        updcrdt = config.GetUpgradeCost(id, count);

        UpdateCityData(cdata, a_population, 0, updcrdt, a_crdtsec);
        if (a_population != 0)
            rank.UpdateRank(msg.sender, cdata.population, cdata.lasttime);

        dtSetCityData(msg.sender, cdata);

        emit OnUpdated(msg.sender, id, count);
    }

    function GetDemolishCost(uint256 id, uint256 count) external view returns (uint256)
    {
        require(count > 0);

        return config.GetDemolishCost(id, count);
    }

    function DemolishByCredits(uint256 id, uint256 count) external
    {
        uint256 a_population;
        uint256 a_crdtsec;
        uint256 dmlcrdt;
        CITYDATA memory cdata = dtGetCityData(msg.sender);
        
        require(count > 0);

        (a_population, a_crdtsec) = UpdateBuildingParam(cdata, id, -count, 0);
        require((a_population > 0) || (a_crdtsec > 0));

        dmlcrdt = config.GetDemolishCost(id, count);

        UpdateCityData(cdata, a_population, 0, dmlcrdt, a_crdtsec);
        if (a_population != 0)
            rank.UpdateRank(msg.sender, cdata.population, cdata.lasttime);

        dtSetCityData(msg.sender, cdata);

        emit OnDemolished(msg.sender, id, count);
    }

    function GetEthBalance() external view returns(uint256 ethBal)
    {
        return data.GetWithdrawBalance(msg.sender);
    }

    function WithdrawEther() external
    {
        data.WithdrawEther(msg.sender);

        CITYDATA memory cdata = dtGetCityData(msg.sender);
        UpdateCityData(cdata, 0, 0, 0, 0);
        dtSetCityData(msg.sender, cdata);
    }

    function GetEthShop() external view returns(uint256 shopEth, uint256 shopCredits)
    {
        (shopEth, shopCredits) = data.GetEthShop(msg.sender);
    }

    function TradeEthShop(uint256 credits) external
    {
        data.TradeEthShop(msg.sender, credits);

        CITYDATA memory cdata = dtGetCityData(msg.sender);
        UpdateCityData(cdata, 0, 0, credits, 0);
        dtSetCityData(msg.sender, cdata);
    }

     
     
    function adminIsAdmin() external view returns(bool)
    {
        return msg.sender == owner || msg.sender == admin;
    }

    function adminSetAdmin(address addr) external
    {
        require(msg.sender == owner);

        admin = addr;
    }

    function adminSetConfig(address dta, address cfg, address rnk) external
    {
        require(msg.sender == owner || msg.sender == admin);

        data = EtherCityData(dta);
        config = EtherCityConfig(cfg);
        rank = EtherCityRank(rnk);
    }

    function adminAddWorldBalance() external payable
    {
        require(msg.value > 0);
        require(msg.sender == owner || msg.sender == admin);

        UpdateEthBalance(msg.value, msg.value);
    }

    function adminGetBalance() external view returns(uint256 dta_bal, uint256 cfg_bal, uint256 rnk_bal, uint256 cty_bal)
    {
        require(msg.sender == owner || msg.sender == admin);

        dta_bal = address(data).balance;
        cfg_bal = address(config).balance;
        rnk_bal = address(rank).balance;
        cty_bal = address(this).balance;
    }

     
     
    function nowday() private view returns(uint256)
    {
        return block.timestamp / 24 hours;
    }

    function daytime(uint256 day) private pure returns(uint256)
    {
        return day * 24 hours;
    }

    function ConstructBuilding(CITYDATA memory cdata, uint256 id, uint256 count, bool byCredit) private returns(bool)
    {
        uint256 a_population;
        uint256 a_crdtsec;
        uint256 cnstcrdt;
        uint256 cnsteth;

        if (count > cdata.landUnoccupied)
            return false;

        (a_population, a_crdtsec) = UpdateBuildingParam(cdata, id, count, 0);

        if ((a_population == 0) && (a_crdtsec == 0))
            return false;

        (cnstcrdt, cnsteth) = config.GetConstructCost(id, count);

        if (!byCredit)
            UpdateEthBalance(cnsteth, msg.value);

        UpdateCityData(cdata, a_population, 0, cnstcrdt, a_crdtsec);
        if (a_population != 0)
            rank.UpdateRank(msg.sender, cdata.population, cdata.lasttime);

        return true;            
    }

    function UpdateBuildingParam(CITYDATA memory cdata, uint256 id, uint256 cnstcount, uint256 updcount) private returns(uint256 a_population, uint256 a_crdtsec)
    {
        uint256 population;
        uint256 crdtsec;
        uint256 maxupd;
        BUILDINGDATA memory bdata = dtGetBuildingData(msg.sender, id);

        if (bdata.upgradeCount == 0)
            bdata.upgradeCount = 1;

        a_population = 0;
        a_crdtsec = 0;

        (population, crdtsec, maxupd) = config.GetBuildingParam(id);
        if (cnstcount > cdata.landUnoccupied)
            return;

        cdata.landOccupied += cnstcount;
        cdata.landUnoccupied -= cnstcount;

        if (bdata.upgradeCount + updcount > maxupd)
            return;

        (a_population, a_crdtsec) = CalcBuildingParam(bdata);
        bdata.population = population;
        bdata.creditsPerSec = crdtsec;
        bdata.constructCount += cnstcount;
        bdata.upgradeCount += updcount;
        (population, crdtsec) = CalcBuildingParam(bdata);

        dtSetBuildingData(msg.sender, id, bdata);

        a_population = population - a_population;
        a_crdtsec = crdtsec - a_crdtsec;
    }

    function CalcBuildingParam(BUILDINGDATA memory bdata) private pure returns(uint256 population, uint256 crdtsec)
    {
        uint256 count;

        count = bdata.constructCount * bdata.upgradeCount;
        population = bdata.population * count;
        crdtsec = bdata.creditsPerSec * count;
    }

    function CalcIncCredits(CITYDATA memory cdata) private view returns(uint256)
    {
        return SafeMath.muldiv(cdata.creditsPerSec, block.timestamp - cdata.lasttime, INTFLOATDIV);
    }

    function UpdateCityData(CITYDATA memory cdata, uint256 pop, uint256 inccrdt, uint256 deccrdt, uint256 crdtsec) private
    {
        uint256 day;

        day = nowday();

        inccrdt += CalcIncCredits(cdata);
        require((cdata.credits + inccrdt) >= deccrdt);

        inccrdt -= deccrdt;

        cdata.population += pop;
        cdata.credits += inccrdt;
        cdata.creditsPerSec += crdtsec;
        cdata.lasttime = block.timestamp;

        WORLDDATA memory wdata = dtGetWorldData();
        wdata.population += pop;
        wdata.credits += inccrdt;
        dtSetWorldData(wdata);

        WORLDSNAPSHOT memory wss = dtValidateWorldSnapshot(day);
        wss.population += pop;
        wss.credits += inccrdt;
        wss.lasttime = block.timestamp;
        dtSetWorldSnapshot(day, wss);

        CITYSNAPSHOT memory css = dtValidateCitySnapshot(msg.sender, day);
        css.population += pop;
        css.credits += inccrdt;
        css.shopCredits += inccrdt;
        css.lasttime = block.timestamp;
        dtSetCitySnapshot(msg.sender, day, css);
    }

    function UpdateEthBalance(uint256 eth, uint256 val) private returns(bool)
    {
        uint256 devf;
        uint256 fndf;
        uint256 rnkf;

        if (eth > val)
        {
            fndf = dtGetEthBalance(msg.sender);
            require(eth - val <= fndf);
            dtSetEthBalance(msg.sender, fndf - eth + val);
        }

        devf = eth * 17 / 100;
        fndf = eth * 33 / 100;
        rnkf = fndf * 70 / 100;

        data.UpdateEthBalance.value(val)(eth - devf - fndf, devf, rnkf, fndf - rnkf);
    }

     
     
    function dtGetWorldData() private view returns(WORLDDATA memory wdata)
    {
         (wdata.ethBalance, wdata.ethDev, wdata.population, wdata.credits, wdata.starttime) = data.GetWorldData();
    }

    function dtSetWorldData(WORLDDATA memory wdata) private
    {
        data.SetWorldData(wdata.ethBalance, wdata.ethDev, wdata.population, wdata.credits, wdata.starttime);
    }

    function dtSetWorldSnapshot(uint256 day, WORLDSNAPSHOT memory wss) private
    {
        data.SetWorldSnapshot(day, true, wss.population, wss.credits, wss.lasttime);
    }

    function dtCreateCityData(address player, uint256 crdtsec, uint256 landcount) private returns(CITYDATA memory)
    {
        data.CreateCityData(player, crdtsec, landcount);
        return dtGetCityData(player);
    }

    function dtGetCityData(address player) private view returns(CITYDATA memory cdata)
    {
        (cdata.credits, cdata.population, cdata.creditsPerSec, cdata.landOccupied, cdata.landUnoccupied, cdata.lasttime) = data.GetCityData(player);
    }

    function dtSetCityData(address player, CITYDATA memory cdata) private
    {
        data.SetCityData(player, cdata.credits, cdata.population, cdata.creditsPerSec, cdata.landOccupied, cdata.landUnoccupied, cdata.lasttime);
    }

    function dtSetCitySnapshot(address player, uint256 day, CITYSNAPSHOT memory css) private
    {
        data.SetCitySnapshot(player, day, true, css.population, css.credits, css.shopCredits, css.lasttime);
    }

    function dtGetBuildingData(address player, uint256 id) private view returns(BUILDINGDATA memory bdata)
    {
        (bdata.constructCount, bdata.upgradeCount, bdata.population, bdata.creditsPerSec) = data.GetBuildingData(player, id);
    }

    function dtSetBuildingData(address player, uint256 id, BUILDINGDATA memory bdata) private
    {
        data.SetBuildingData(player, id, bdata.constructCount, bdata.upgradeCount, bdata.population, bdata.creditsPerSec);
    }

    function dtGetEthBalance(address player) private view returns(uint256)
    {
        return data.GetEthBalance(player);
    }

    function dtSetEthBalance(address player, uint256 eth) private
    {
        data.SetEthBalance(player, eth);
    }

    function dtAddEthBalance(address player, uint256 eth) private
    {
        data.AddEthBalance(player, eth);
    }

    function dtValidateWorldSnapshot(uint256 day) private returns(WORLDSNAPSHOT memory wss)
    {
        uint256 ethRankFund;

        (ethRankFund, wss.population, wss.credits, wss.lasttime) = data.ValidateWorldSnapshot(day);
    }

    function dtTestWorldSnapshot(uint256 day) private view returns(uint256 ethRankFund, WORLDSNAPSHOT memory wss)
    {
        (ethRankFund, wss.population, wss.credits, wss.lasttime) = data.TestWorldSnapshot(day);
    }

    function dtValidateCitySnapshot(address player, uint256 day) private returns(CITYSNAPSHOT memory css)
    {
        (css.population, css.credits, css.shopCredits, css.lasttime) = data.ValidateCitySnapshot(player, day);
    }

    function dtTestCitySnapshot(address player, uint256 day) private view returns(CITYSNAPSHOT memory css)
    {
        (css.population, css.credits, css.shopCredits, css.lasttime) = data.TestCitySnapshot(player, day);
    }
}