contract EtherCityConfig
{
    struct BuildingData
    {
        uint256 population;
        uint256 creditsPerSec;    
        uint256 maxUpgrade;
        uint256 constructCredit;
        uint256 constructEther;
        uint256 upgradeCredit;
        uint256 demolishCredit;

        uint256 constructSale;
        uint256 upgradeSale;
        uint256 demolishSale;
    }

    uint256 private initCredits;
    uint256 private initLandCount;
    uint256 private initcreditsPerSec;

    uint256 private maxLandCount;
    uint256 private ethLandCost;

    uint256 private creditsPerEth;

    address private owner;
    address private admin;

    mapping(uint256 => BuildingData) private buildingData;
    
    constructor() public payable
    {
        owner = msg.sender;
        creditsPerEth = 1;
    }

    function SetAdmin(address addr) external
    {
        assert(msg.sender == owner);

        admin = addr;
    }
    
    function GetVersion() external pure returns(uint256)
    {
        return 1000;
    }

    function GetInitData() external view returns(uint256 ethland, uint256 maxland, uint256 credits, uint256 crdtsec, uint256 landCount)
    {
        ethland = ethLandCost;
        maxland = maxLandCount;
        credits = initCredits;
        crdtsec = initcreditsPerSec;
        landCount = initLandCount;
    }

    function SetInitData(uint256 ethland, uint256 maxland, uint256 credits, uint256 crdtsec, uint256 landCount) external
    {
        require(msg.sender == owner || msg.sender == admin);

        ethLandCost = ethland;
        maxLandCount = maxland;
        initCredits = credits;
        initcreditsPerSec = crdtsec;
        initLandCount = landCount;
    }

    function GetCreditsPerEth() external view returns(uint256)
    {
        return creditsPerEth;
    }

    function SetCreditsPerEth(uint256 crdteth) external
    {
        require(crdteth > 0);
        require(msg.sender == owner || msg.sender == admin);

        creditsPerEth = crdteth;
    }

    function GetLandData() external view returns(uint256 ethland, uint256 maxland)
    {
        ethland = ethLandCost;
        maxland = maxLandCount;
    }

    function GetBuildingData(uint256 id) external view returns(uint256 bid, uint256 population, uint256 crdtsec, 
                            uint256 maxupd, uint256 cnstcrdt, uint256 cnsteth, uint256 updcrdt, uint256 dmlcrdt,
                            uint256 cnstcrdtsale, uint256 cnstethsale, uint256 updcrdtsale, uint256 dmlcrdtsale)
    {
        BuildingData storage bdata = buildingData[id];

        bid = id;
        population = bdata.population;    
        crdtsec = bdata.creditsPerSec;    
        maxupd = bdata.maxUpgrade;
        cnstcrdt = bdata.constructCredit;
        cnsteth = bdata.constructEther;
        updcrdt = bdata.upgradeCredit;
        dmlcrdt = bdata.demolishCredit;
        cnstcrdtsale = bdata.constructCredit * bdata.constructSale / 100;
        cnstethsale = bdata.constructEther * bdata.constructSale /100;
        updcrdtsale = bdata.upgradeCredit * bdata.upgradeSale / 100;
        dmlcrdtsale = bdata.demolishCredit * bdata.demolishSale / 100;
    }

    function SetBuildingData(uint256 bid, uint256 pop, uint256 crdtsec, uint256 maxupd,
                            uint256 cnstcrdt, uint256 cnsteth, uint256 updcrdt, uint256 dmlcrdt) external
    {
        require(msg.sender == owner || msg.sender == admin);

        buildingData[bid] = BuildingData({population:pop, creditsPerSec:crdtsec, maxUpgrade:maxupd,
                            constructCredit:cnstcrdt, constructEther:cnsteth, upgradeCredit:updcrdt, demolishCredit:dmlcrdt,
                            constructSale:100, upgradeSale:100, demolishSale:100
                            });
    }

    function SetBuildingSale(uint256 bid, uint256 cnstsale, uint256 updsale, uint256 dmlsale) external
    {
        BuildingData storage bdata = buildingData[bid];

        require(0 < cnstsale && cnstsale <= 100);
        require(0 < updsale && updsale <= 100);
        require(msg.sender == owner || msg.sender == admin);

        bdata.constructSale = cnstsale;
        bdata.upgradeSale = updsale;
        bdata.demolishSale = dmlsale;
    }

    function SetBuildingDataArray(uint256[] data) external
    {
        require(data.length % 8 == 0);
        require(msg.sender == owner || msg.sender == admin);

        for(uint256 index = 0; index < data.length; index += 8)
        {
            BuildingData storage bdata = buildingData[data[index]];

            bdata.population = data[index + 1];
            bdata.creditsPerSec = data[index + 2];
            bdata.maxUpgrade = data[index + 3];
            bdata.constructCredit = data[index + 4];
            bdata.constructEther = data[index + 5];
            bdata.upgradeCredit = data[index + 6];
            bdata.demolishCredit = data[index + 7];
            bdata.constructSale = 100;
            bdata.upgradeSale = 100;
            bdata.demolishSale = 100;
        }
    }

    function GetBuildingParam(uint256 id) external view
                returns(uint256 population, uint256 crdtsec, uint256 maxupd)
    {
        BuildingData storage bdata = buildingData[id];

        population = bdata.population;    
        crdtsec = bdata.creditsPerSec;    
        maxupd = bdata.maxUpgrade;
    }

    function GetConstructCost(uint256 id, uint256 count) external view
                returns(uint256 cnstcrdt, uint256 cnsteth)
    {
        BuildingData storage bdata = buildingData[id];

        cnstcrdt = bdata.constructCredit * bdata.constructSale / 100  * count;
        cnsteth = bdata.constructEther * bdata.constructSale / 100  * count;
    }

    function GetUpgradeCost(uint256 id, uint256 count) external view
                returns(uint256 updcrdt)
    {
        BuildingData storage bdata = buildingData[id];

        updcrdt = bdata.upgradeCredit * bdata.upgradeSale / 100 * count;
    }

    function GetDemolishCost(uint256 id, uint256 count) external view
                returns(uint256)
    {
        BuildingData storage bdata = buildingData[id];

        return bdata.demolishCredit * bdata.demolishSale / 100 * count;
   }
}

