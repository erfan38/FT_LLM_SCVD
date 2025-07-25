contract SpaceWar  {
    using NumericSequence for uint;
    using SafeMath for uint;

    struct MinerData
    {
        uint256[9]   spaces;  
        uint8[3]     hasUpgrade;
        uint256      money;
        uint256      lastUpdateTime;
        uint256      premamentMineBonusPct;
        uint256      unclaimedPot;
        uint256      lastPotClaimIndex;
    }

    struct SpaceData
    {
        uint256 basePrice;
        uint256 baseOutput;
        uint256 pricePerLevel;
        uint256 priceInETH;
        uint256 limit;
    }

    struct BoostData
    {
        uint256 percentBonus;
        uint256 priceInWEI;
    }

    struct PVPData
    {
        uint256[6] troops;
        uint256    immunityTime;
        uint256    exhaustTime;
    }

    struct TroopData
    {
        uint256 attackPower;
        uint256 defensePower;
        uint256 priceGold;
        uint256 priceETH;
    }

    uint8 private constant NUMBER_OF_RIG_TYPES = 9;
    SpaceData[9]  private spaceData;

    uint8 private constant NUMBER_OF_UPGRADES = 3;
    BoostData[3] private boostData;

    uint8 private constant NUMBER_OF_TROOPS = 6;
    uint8 private constant ATTACKER_START_IDX = 0;
    uint8 private constant ATTACKER_END_IDX = 3;
    uint8 private constant DEFENDER_START_IDX = 3;
    uint8 private constant DEFENDER_END_IDX = 6;
    TroopData[6] private troopData;

     
    uint256 private honeyPotAmount;
    uint256 private honeyPotSharePct;  
    uint256 private jackPot;
    uint256 private devFund;
    uint256 private nextPotDistributionTime;
    mapping(address => mapping(uint256 => uint256)) private minerICOPerCycle;
    uint256[] private honeyPotPerCycle;
    uint256[] private globalICOPerCycle;
    uint256 private cycleCount;

     
    uint256 private constant NUMBER_OF_BOOSTERS = 5;
    uint256 private boosterIndex;
    uint256 private nextBoosterPrice;
    address[5] private boosterHolders;

    mapping(address => MinerData) private miners;
    mapping(address => PVPData)   private pvpMap;
    mapping(uint256 => address)   private indexes;
    uint256 private topindex;

    address private owner;

     
     
     
    function SpaceWar() public {
        owner = msg.sender;

         
        spaceData[0] = SpaceData(500,             1,        5,               0,          999);
        spaceData[1] = SpaceData(50000,           10,       500,             0,          999);
        spaceData[2] = SpaceData(5000000,         100,      50000,           0,          999);
        spaceData[3] = SpaceData(80000000,        1000,     800000,          0,          999);
        spaceData[4] = SpaceData(500000000,       20000,    5000000,         0.01 ether, 999);
        spaceData[5] = SpaceData(10000000000,     100000,   100000000,       0,          999);
        spaceData[6] = SpaceData(100000000000,    1000000,  1000000000,      0,          999);
        spaceData[7] = SpaceData(1000000000000,   50000000, 10000000000,     0.1 ether,  999);
        spaceData[8] = SpaceData(10000000000000,  100000000,100000000000,    0,          999);

        boostData[0] = BoostData(30,  0.01 ether);
        boostData[1] = BoostData(50,  0.1 ether);
        boostData[2] = BoostData(100, 1 ether);

        topindex = 0;
        honeyPotAmount = 0;
        devFund = 0;
        jackPot = 0;
        nextPotDistributionTime = block.timestamp;
        honeyPotSharePct = 90;

         
        boosterHolders[0] = owner;
        boosterHolders[1] = owner;
        boosterHolders[2] = owner;
        boosterHolders[3] = owner;
        boosterHolders[4] = owner;

        boosterIndex = 0;
        nextBoosterPrice = 0.1 ether;

         
        troopData[0] = TroopData(10,     0,      100000,   0);
        troopData[1] = TroopData(1000,   0,      80000000, 0);
        troopData[2] = TroopData(100000, 0,      1000000000,   0.01 ether);
        troopData[3] = TroopData(0,      15,     100000,   0);
        troopData[4] = TroopData(0,      1500,   80000000, 0);
        troopData[5] = TroopData(0,      150000, 1000000000,   0.01 ether);

        honeyPotPerCycle.push(0);
        globalICOPerCycle.push(1);
        cycleCount = 0;
    }

     
     
     
    function GetMinerData(address minerAddr) public constant returns
        (uint256 money, uint256 lastupdate, uint256 prodPerSec,
         uint256[9] spaces, uint[3] upgrades, uint256 unclaimedPot, bool hasBooster, uint256 unconfirmedMoney)
    {
        uint8 i = 0;

        money = miners[minerAddr].money;
        lastupdate = miners[minerAddr].lastUpdateTime;
        prodPerSec = GetProductionPerSecond(minerAddr);

        for(i = 0; i < NUMBER_OF_RIG_TYPES; ++i)
        {
            spaces[i] = miners[minerAddr].spaces[i];
        }

        for(i = 0; i < NUMBER_OF_UPGRADES; ++i)
        {
            upgrades[i] = miners[minerAddr].hasUpgrade[i];
        }

        unclaimedPot = miners[minerAddr].unclaimedPot;
        hasBooster = HasBooster(minerAddr);

        unconfirmedMoney = money + (prodPerSec * (now - lastupdate));
    }

    function GetTotalMinerCount() public constant returns (uint256 count)
    {
        count = topindex;
    }

    function GetMinerAt(uint256 idx) public constant returns (address minerAddr)
    {
        require(idx < topindex);
        minerAddr = indexes[idx];
    }

    function GetPotInfo() public constant returns (uint256 _honeyPotAmount, uint256 _devFunds, uint256 _jackPot, uint256 _nextDistributionTime)
    {
        _honeyPotAmount = honeyPotAmount;
        _devFunds = devFund;
        _jackPot = jackPot;
        _nextDistributionTime = nextPotDistributionTime;
    }

    function GetProductionPerSecond(address minerAddr) public constant returns (uint256 personalProduction)
    {
        MinerData storage m = miners[minerAddr];

        personalProduction = 0;
        uint256 productionSpeed = 100 + m.premamentMineBonusPct;

        if(HasBooster(minerAddr))  
            productionSpeed += 100;

        for(uint8 j = 0; j < NUMBER_OF_RIG_TYPES; ++j)
        {
            personalProduction += m.spaces[j] * spaceData[j].baseOutput;
        }

        personalProduction = personalProduction * productionSpeed / 100;
    }

    function GetGlobalProduction() public constant returns (uint256 globalMoney, uint256 globalHashRate)
    {
        globalMoney = 0;
        globalHashRate = 0;
        uint i = 0;
        for(i = 0; i < topindex; ++i)
        {
            MinerData storage m = miners[indexes[i]];
            globalMoney += m.money;
            globalHashRate += GetProductionPerSecond(indexes[i]);
        }
    }

    function GetBoosterData() public constant returns (address[5] _boosterHolders, uint256 currentPrice, uint256 currentIndex)
    {
        for(uint i = 0; i < NUMBER_OF_BOOSTERS; ++i)
        {
            _boosterHolders[i] = boosterHolders[i];
        }
        currentPrice = nextBoosterPrice;
        currentIndex = boosterIndex;
    }

    function HasBooster(address addr) public constant returns (bool hasBoost)
    {
        for(uint i = 0; i < NUMBER_OF_BOOSTERS; ++i)
        {
           if(boosterHolders[i] == addr)
            return true;
        }
        return false;
    }

    function GetPVPData(address addr) public constant returns (uint256 attackpower, uint256 defensepower, uint256 immunityTime, uint256 exhaustTime,
    uint256[6] troops)
    {
        PVPData storage a = pvpMap[addr];

        immunityTime = a.immunityTime;
        exhaustTime = a.exhaustTime;

        attackpower = 0;
        defensepower = 0;
        for(uint i = 0; i < NUMBER_OF_TROOPS; ++i)
        {
            attackpower  += a.troops[i] * troopData[i].attackPower;
            defensepower += a.troops[i] * troopData[i].defensePower;

            troops[i] = a.troops[i];
        }
    }

    function GetCurrentICOCycle() public constant returns (uint256)
    {
        return cycleCount;
    }

    function GetICOData(uint256 idx) public constant returns (uint256 ICOFund, uint256 ICOPot)
    {
        require(idx <= cycleCount);
        ICOFund = globalICOPerCycle[idx];
        if(idx < cycleCount)
        {
            ICOPot = honeyPotPerCycle[idx];
        } else
        {
            ICOPot =  honeyPotAmount / 10;  
        }
    }

    function GetMinerICOData(address miner, uint256 idx) public constant returns (uint256 ICOFund, uint256 ICOShare, uint256 lastClaimIndex)
    {
        require(idx <= cycleCount);
        ICOFund = minerICOPerCycle[miner][idx];
        if(idx < cycleCount)
        {
            ICOShare = (honeyPotPerCycle[idx] * minerICOPerCycle[miner][idx]) / globalICOPerCycle[idx];
        } else
        {
            ICOShare = (honeyPotAmount / 10) * minerICOPerCycle[miner][idx] / globalICOPerCycle[idx];
        }
        lastClaimIndex = miners[miner].lastPotClaimIndex;
    }

    function GetMinerUnclaimedICOShare(address miner) public constant returns (uint256 unclaimedPot)
    {
        MinerData storage m = miners[miner];

        require(m.lastUpdateTime != 0);
        require(m.lastPotClaimIndex < cycleCount);

        uint256 i = m.lastPotClaimIndex;
        uint256 limit = cycleCount;

        if((limit - i) > 30)  
            limit = i + 30;

        unclaimedPot = 0;
        for(; i < cycleCount; ++i)
        {
            if(minerICOPerCycle[miner][i] > 0)
                unclaimedPot += (honeyPotPerCycle[i] * minerICOPerCycle[miner][i]) / globalICOPerCycle[i];
        }
    }

     
     
     
    function StartNewMiner() external
    {
        require(miners[msg.sender].lastUpdateTime == 0);

        miners[msg.sender].lastUpdateTime = block.timestamp;
        miners[msg.sender].money = 0;
        miners[msg.sender].spaces[0] = 1;
        miners[msg.sender].unclaimedPot = 0;
        miners[msg.sender].lastPotClaimIndex = cycleCount;

        pvpMap[msg.sender].immunityTime = block.timestamp + 14400;
        pvpMap[msg.sender].exhaustTime  = block.timestamp;

        indexes[topindex] = msg.sender;
        ++topindex;
    }

    function UpgradeSpace(uint8 spaceIdx, uint16 count) external
    {
        require(spaceIdx < NUMBER_OF_RIG_TYPES);
        require(count > 0);
        require(count <= 999);
        require(spaceData[spaceIdx].priceInETH == 0);
        MinerData storage m = miners[msg.sender];

        require(spaceData[spaceIdx].limit >= (m.spaces[spaceIdx] + count));

        UpdateMoney();

         
        uint256 price = NumericSequence.sumOfN(spaceData[spaceIdx].basePrice, spaceData[spaceIdx].pricePerLevel, m.spaces[spaceIdx], count);

        require(m.money >= price);

        m.spaces[spaceIdx] = m.spaces[spaceIdx] + count;

        if(m.spaces[spaceIdx] > spaceData[spaceIdx].limit)
            m.spaces[spaceIdx] = spaceData[spaceIdx].limit;

        m.money -= price;
    }

    function UpgradeSpaceETH(uint8 spaceIdx, uint256 count) external payable
    {
        require(spaceIdx < NUMBER_OF_RIG_TYPES);
        require(count > 0);
        require(count <= 999);
        require(spaceData[spaceIdx].priceInETH > 0);

        MinerData storage m = miners[msg.sender];

        require(spaceData[spaceIdx].limit >= (m.spaces[spaceIdx] + count));

        uint256 price = (spaceData[spaceIdx].priceInETH).mul(count);

        uint256 priceCoin = NumericSequence.sumOfN(spaceData[spaceIdx].basePrice, spaceData[spaceIdx].pricePerLevel, m.spaces[spaceIdx], count);

        UpdateMoney();
        require(msg.value >= price);
        require(m.money >= priceCoin);

        BuyHandler(msg.value);

        m.spaces[spaceIdx] = m.spaces[spaceIdx] + count;

        if(m.spaces[spaceIdx] > spaceData[spaceIdx].limit)
            m.spaces[spaceIdx] = spaceData[spaceIdx].limit;

        m.money -= priceCoin;
    }

    function UpdateMoney() private
    {
        require(miners[msg.sender].lastUpdateTime != 0);
        require(block.timestamp >= miners[msg.sender].lastUpdateTime);

        MinerData storage m = miners[msg.sender];
        uint256 diff = block.timestamp - m.lastUpdateTime;
        uint256 revenue = GetProductionPerSecond(msg.sender);

        m.lastUpdateTime = block.timestamp;
        if(revenue > 0)
        {
            revenue *= diff;

            m.money += revenue;
        }
    }

    function UpdateMoneyAt(address addr) private
    {
        require(miners[addr].lastUpdateTime != 0);
        require(block.timestamp >= miners[addr].lastUpdateTime);

        MinerData storage m = miners[addr];
        uint256 diff = block.timestamp - m.lastUpdateTime;
        uint256 revenue = GetProductionPerSecond(addr);

        m.lastUpdateTime = block.timestamp;
        if(revenue > 0)
        {
            revenue *= diff;

            m.money += revenue;
        }
    }

    function BuyUpgrade(uint256 idx) external payable
    {
        require(idx < NUMBER_OF_UPGRADES);
        require(msg.value >= boostData[idx].priceInWEI);
        require(miners[msg.sender].hasUpgrade[idx] == 0);
        require(miners[msg.sender].lastUpdateTime != 0);

        BuyHandler(msg.value);

        UpdateMoney();

        miners[msg.sender].hasUpgrade[idx] = 1;
        miners[msg.sender].premamentMineBonusPct +=  boostData[idx].percentBonus;
    }

     
     
     
    function BuyBooster() external payable
    {
        require(msg.value >= nextBoosterPrice);
        require(miners[msg.sender].lastUpdateTime != 0);

        for(uint i = 0; i < NUMBER_OF_BOOSTERS; ++i)
            if(boosterHolders[i] == msg.sender)
                revert();

        address beneficiary = boosterHolders[boosterIndex];

        MinerData storage m = miners[beneficiary];

         
        m.unclaimedPot += (msg.value * 9403) / 10000;

         
        honeyPotAmount += (msg.value * 597) / 20000;
        devFund += (msg.value * 597) / 20000;

         
        nextBoosterPrice += nextBoosterPrice / 20;

        UpdateMoney();
        UpdateMoneyAt(beneficiary);

         
        boosterHolders[boosterIndex] = msg.sender;

         
        boosterIndex += 1;
        if(boosterIndex >= 5)
            boosterIndex = 0;
    }

     
     
     
     
    function BuyTroop(uint256 idx, uint256 count) external payable
    {
        require(idx < NUMBER_OF_TROOPS);
        require(count > 0);
        require(count <= 1000);

        PVPData storage pvp = pvpMap[msg.sender];
        MinerData storage m = miners[msg.sender];

        uint256 owned = pvp.troops[idx];

        uint256 priceGold = NumericSequence.sumOfN(troopData[idx].priceGold, troopData[idx].priceGold / 100, owned, count);
        uint256 priceETH = (troopData[idx].priceETH).mul(count);

        UpdateMoney();

        require(m.money >= priceGold);
        require(msg.value >= priceETH);

        if(priceGold > 0)
            m.money -= priceGold;

        if(msg.value > 0)
            BuyHandler(msg.value);

        pvp.troops[idx] += count;
    }

    function Attack(address defenderAddr) external
    {
        require(msg.sender != defenderAddr);
        require(miners[msg.sender].lastUpdateTime != 0);
        require(miners[defenderAddr].lastUpdateTime != 0);

        PVPData storage attacker = pvpMap[msg.sender];
        PVPData storage defender = pvpMap[defenderAddr];
        uint i = 0;
        uint256 count = 0;

        require(block.timestamp > attacker.exhaustTime);
        require(block.timestamp > defender.immunityTime);

         
        if(attacker.immunityTime > block.timestamp)
            attacker.immunityTime = block.timestamp - 1;

        attacker.exhaustTime = block.timestamp + 3600;

        uint256 attackpower = 0;
        uint256 defensepower = 0;
        for(i = 0; i < ATTACKER_END_IDX; ++i)
        {
            attackpower  += attacker.troops[i] * troopData[i].attackPower;
            defensepower += defender.troops[i + DEFENDER_START_IDX] * troopData[i + DEFENDER_START_IDX].defensePower;
        }

        if(attackpower > defensepower)
        {
            if(defender.immunityTime < block.timestamp + 14400)
                defender.immunityTime = block.timestamp + 14400;

            UpdateMoneyAt(defenderAddr);

            MinerData storage m = miners[defenderAddr];
            MinerData storage m2 = miners[msg.sender];
            uint256 moneyStolen = m.money / 2;

            for(i = DEFENDER_START_IDX; i < DEFENDER_END_IDX; ++i)
            {
                defender.troops[i] = defender.troops[i]/2;
            }

            for(i = ATTACKER_START_IDX; i < ATTACKER_END_IDX; ++i)
            {
                if(troopData[i].attackPower > 0)
                {
                    count = attacker.troops[i];

                     
                    if((count * troopData[i].attackPower) > defensepower)
                        {
                            count = count * defensepower / attackpower / 2;
                        }
                    else
                         {
                             count =  count/2;
                         }
                    attacker.troops[i] = SafeMath.sub(attacker.troops[i],count);
                    defensepower -= count * troopData[i].attackPower;
                }
            }

            m.money -= moneyStolen;
            m2.money += moneyStolen;
        } else
        {
            for(i = ATTACKER_START_IDX; i < ATTACKER_END_IDX; ++i)
            {
                attacker.troops[i] = attacker.troops[i] / 2;
            }

            for(i = DEFENDER_START_IDX; i < DEFENDER_END_IDX; ++i)
            {
                if(troopData[i].defensePower > 0)
                {
                    count = defender.troops[i];

                     
                    if((count * troopData[i].defensePower) > attackpower)
                        count = count * attackpower / defensepower / 2;

                    defender.troops[i] -= count;
                    attackpower -= count * troopData[i].defensePower;
                }
            }
        }
    }

     
     
     
    function ReleaseICO() external
    {
        require(miners[msg.sender].lastUpdateTime != 0);
        require(nextPotDistributionTime <= block.timestamp);
        require(honeyPotAmount > 0);
        require(globalICOPerCycle[cycleCount] > 0);

        nextPotDistributionTime = block.timestamp + 86400;

        honeyPotPerCycle[cycleCount] = honeyPotAmount / 10;  

        honeyPotAmount -= honeyPotAmount / 10;

        honeyPotPerCycle.push(0);
        globalICOPerCycle.push(0);
        cycleCount = cycleCount + 1;

        MinerData storage jakpotWinner = miners[msg.sender];
        jakpotWinner.unclaimedPot += jackPot;
        jackPot = 0;
    }

    function FundICO(uint amount) external
    {
        require(miners[msg.sender].lastUpdateTime != 0);
        require(amount > 0);

        MinerData storage m = miners[msg.sender];

        UpdateMoney();

        require(m.money >= amount);

        m.money = (m.money).sub(amount);

        globalICOPerCycle[cycleCount] = globalICOPerCycle[cycleCount].add(uint(amount));
        minerICOPerCycle[msg.sender][cycleCount] = minerICOPerCycle[msg.sender][cycleCount].add(uint(amount));
    }

    function WithdrawICOEarnings() external
    {
        MinerData storage m = miners[msg.sender];

        require(miners[msg.sender].lastUpdateTime != 0);
        require(miners[msg.sender].lastPotClaimIndex < cycleCount);

        uint256 i = m.lastPotClaimIndex;
        uint256 limit = cycleCount;

        if((limit - i) > 30)  
            limit = i + 30;

        m.lastPotClaimIndex = limit;
        for(; i < cycleCount; ++i)
        {
            if(minerICOPerCycle[msg.sender][i] > 0)
                m.unclaimedPot += (honeyPotPerCycle[i] * minerICOPerCycle[msg.sender][i]) / globalICOPerCycle[i];
        }
    }

     
     
     
    function BuyHandler(uint amount) private
    {
         
        honeyPotAmount += (amount * honeyPotSharePct) / 100;
        jackPot += amount / 100;
        devFund += (amount * (100-(honeyPotSharePct+1))) / 100;
    }

    function WithdrawPotShare() public
    {
        MinerData storage m = miners[msg.sender];

        require(m.unclaimedPot > 0);
        require(m.lastUpdateTime != 0);

        uint256 amntToSend = m.unclaimedPot;
        m.unclaimedPot = 0;

        if(msg.sender.send(amntToSend))
        {
            m.unclaimedPot = 0;
        }
    }

    function WithdrawDevFunds() public
    {
        require(msg.sender == owner);

        if(owner.send(devFund))
        {
            devFund = 0;
        }
    }

     
    function() public payable {
         devFund += msg.value;
    }
}