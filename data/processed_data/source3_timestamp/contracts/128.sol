contract TheEthGame {
    using SafeMath for uint256;
    
    struct Player {
        uint256 score;
        uint256 lastCellBoughtOnBlockNumber;
        uint256 numberOfCellsOwned;
        uint256 numberOfCellsBought;
        uint256 earnings;

        uint256 partialHarmonicSum;
        uint256 partialScoreSum;
        
        address referreal;

        bytes32 name;
    }
    
    struct Cell {
        address owner;
        uint256 price;
    }
    
    address public owner;
    
    uint256 constant private NUMBER_OF_LINES = 6;
    uint256 constant private NUMBER_OF_COLUMNS = 6;
    uint256 constant private NUMBER_OF_CELLS = NUMBER_OF_COLUMNS * NUMBER_OF_LINES;
    uint256 constant private DEFAULT_POINTS_PER_CELL = 3;
    uint256 constant private POINTS_PER_NEIGHBOUR = 1;

    uint256 constant private CELL_STARTING_PRICE = 0.01 ether;
    uint256 constant private BLOCKS_TO_CONFIRM_TO_WIN_THE_GAME = 10000;
    uint256 constant private PRICE_INCREASE_PERCENTAGE = uint(2);
    uint256 constant private REFERREAL_PERCENTAGE = uint(10);
    uint256 constant private POT_PERCENTAGE = uint(30);
    uint256 constant private DEVELOPER_PERCENTAGE = uint(5);
    uint256 constant private SCORE_PERCENTAGE = uint(25);
    uint256 constant private NUMBER_OF_CELLS_PERCENTAGE = uint(30);
    
    Cell[NUMBER_OF_CELLS] cells;
    
    address[] private ranking;
    mapping(address => Player) players;
    mapping(bytes32 => address) nameToAddress;
    
    uint256 public numberOfCellsBought;
    uint256 private totalScore;
    
    uint256 private developersCut = 0 ether;
    uint256 private potCut = 0 ether;
    uint256 private harmonicSum;
    uint256 private totalScoreSum;
    
    address private rankOnePlayerAddress;
    uint256 private isFirstSinceBlock;
    
    address public trophyAddress;
    
    event Bought (address indexed _from, address indexed _to);

    constructor () public {
        owner = msg.sender;
        trophyAddress = new TheEthGameTrophy();
    }
    
     
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
     
    function nextPriceOf (uint256 _cellId) public view returns (uint256 _nextPrice) {
        return priceOf(_cellId).mul(100 + PRICE_INCREASE_PERCENTAGE) / 100;
    }
    
    function priceOf (uint256 _cellId) public view returns (uint256 _price) {
        if (cells[_cellId].price == 0) {
            return CELL_STARTING_PRICE;
        }
        
        return cells[_cellId].price;
    }
    
    function earningsFromNumberOfCells (address _address) internal view returns (uint256 _earnings) {
        return harmonicSum.sub(players[_address].partialHarmonicSum).mul(players[_address].numberOfCellsBought);
    }
    
    function distributeEarningsBasedOnNumberOfCells (address _address) internal {
        players[_address].earnings = players[_address].earnings.add(earningsFromNumberOfCells(_address));
        players[_address].partialHarmonicSum = harmonicSum;
    }
    
    function earningsFromScore (address _address) internal view returns (uint256 _earnings) {
        return totalScoreSum.sub(players[_address].partialScoreSum).mul(scoreOf(_address));
    }
    
    function distributeEarningsBasedOnScore (address _newOwner, address _oldOwner) internal {
        players[_newOwner].earnings = players[_newOwner].earnings.add(earningsFromScore(_newOwner));
        players[_newOwner].partialScoreSum = totalScoreSum;
        
        if (_oldOwner != address(0)) {
            players[_oldOwner].earnings = players[_oldOwner].earnings.add(earningsFromScore(_oldOwner));
            players[_oldOwner].partialScoreSum = totalScoreSum;
        }
    }
    
    function earningsOfPlayer () public view returns (uint256 _wei) {
        return players[msg.sender].earnings.add(earningsFromScore(msg.sender)).add(earningsFromNumberOfCells(msg.sender));
    }
    
    function getRankOnePlayer (address _oldOwner) internal view returns (address _address, uint256 _oldOwnerIndex) {
        address rankOnePlayer;
        uint256 oldOwnerIndex;
        
        for (uint256 i = 0; i < ranking.length; i++) {
            if (scoreOf(ranking[i]) > scoreOf(rankOnePlayer)) {
                    rankOnePlayer = ranking[i];
            } else if (scoreOf(ranking[i]) == scoreOf(rankOnePlayer) && players[ranking[i]].lastCellBoughtOnBlockNumber > players[rankOnePlayer].lastCellBoughtOnBlockNumber) {
                    rankOnePlayer = ranking[i];
            }
            
            if (ranking[i] == _oldOwner) {
                oldOwnerIndex = i;
            }
        }
        
        
        return (rankOnePlayer, oldOwnerIndex);
    }

    function buy (uint256 _cellId, address _referreal) payable public {
        require(msg.value >= priceOf(_cellId));
        require(!isContract(msg.sender));
        require(_cellId < NUMBER_OF_CELLS);
        require(msg.sender != address(0));
        require(!isGameFinished());  
        require(ownerOf(_cellId) != msg.sender);
        require(msg.sender != _referreal);
        
        address oldOwner = ownerOf(_cellId);
        address newOwner = msg.sender;
        uint256 price = priceOf(_cellId);
        uint256 excess = msg.value.sub(price);

        bool isReferrealDistributed = distributeToReferreal(price, _referreal);
        
         
        if (numberOfCellsBought > 0) {
            harmonicSum = harmonicSum.add(price.mul(NUMBER_OF_CELLS_PERCENTAGE) / (numberOfCellsBought * 100));
            if (isReferrealDistributed) {
                totalScoreSum = totalScoreSum.add(price.mul(SCORE_PERCENTAGE) / (totalScore * 100));
            } else {
                totalScoreSum = totalScoreSum.add(price.mul(SCORE_PERCENTAGE.add(REFERREAL_PERCENTAGE)) / (totalScore * 100));
            }
        }else{
             
            potCut = potCut.add(price.mul(NUMBER_OF_CELLS_PERCENTAGE.add(SCORE_PERCENTAGE)) / 100);
        }
        
        numberOfCellsBought++;
        
        distributeEarningsBasedOnNumberOfCells(newOwner);
        
        players[newOwner].numberOfCellsBought++;
        players[newOwner].numberOfCellsOwned++;
        
        if (ownerOf(_cellId) != address(0)) {
             players[oldOwner].numberOfCellsOwned--;
        }
        
        players[newOwner].lastCellBoughtOnBlockNumber = block.number;
         
        address oldRankOnePlayer = rankOnePlayerAddress;
        
        (uint256 newOwnerScore, uint256 oldOwnerScore) = calculateScoresIfCellIsBought(newOwner, oldOwner, _cellId);
        
        distributeEarningsBasedOnScore(newOwner, oldOwner);
        
        totalScore = totalScore.sub(scoreOf(newOwner).add(scoreOf(oldOwner)));
                
        players[newOwner].score = newOwnerScore;
        players[oldOwner].score = oldOwnerScore;
        
        totalScore = totalScore.add(scoreOf(newOwner).add(scoreOf(oldOwner)));

        cells[_cellId].price = nextPriceOf(_cellId);
        
         
        if (players[newOwner].numberOfCellsOwned == 1) {
           ranking.push(newOwner);
        }
        
        if (oldOwner == rankOnePlayerAddress || (players[oldOwner].numberOfCellsOwned == 0 && oldOwner != address(0))) {
            (address rankOnePlayer, uint256 oldOwnerIndex) = getRankOnePlayer(oldOwner); 
            if (players[oldOwner].numberOfCellsOwned == 0 && oldOwner != address(0)) {
                delete ranking[oldOwnerIndex];
            }
            rankOnePlayerAddress = rankOnePlayer;
        }else{  
            if (scoreOf(newOwner) >= scoreOf(rankOnePlayerAddress)) {
                rankOnePlayerAddress = newOwner;
            }
        }
        
        if (rankOnePlayerAddress != oldRankOnePlayer) {
            isFirstSinceBlock = block.number;
        }
        

        developersCut = developersCut.add(price.mul(DEVELOPER_PERCENTAGE) / 100);
        potCut = potCut.add(price.mul(POT_PERCENTAGE) / 100);

        _transfer(oldOwner, newOwner, _cellId);
        
        emit Bought(oldOwner, newOwner);
        
        if (excess > 0) {
          newOwner.transfer(excess);
        }
    }
    
    function distributeToReferreal (uint256 _price, address _referreal) internal returns (bool _isDstributed) {
        if (_referreal != address(0) && _referreal != msg.sender) {
            players[msg.sender].referreal = _referreal;
        }
        
         
        if (players[msg.sender].referreal != address(0)) {
            address ref = players[msg.sender].referreal;
            players[ref].earnings = players[ref].earnings.add(_price.mul(REFERREAL_PERCENTAGE) / 100);
            return true;
        }
        
        return false;
    }
    
     
    function getPlayers () external view returns(uint256[] _scores, uint256[] _lastCellBoughtOnBlock, address[] _addresses, bytes32[] _names) {
        uint256[] memory scores = new uint256[](ranking.length);
        address[] memory addresses = new address[](ranking.length);
        uint256[] memory lastCellBoughtOnBlock = new uint256[](ranking.length);
        bytes32[] memory names = new bytes32[](ranking.length);
        
        for (uint256 i = 0; i < ranking.length; i++) {
            Player memory p = players[ranking[i]];
            
            scores[i] = p.score;
            addresses[i] = ranking[i];
            lastCellBoughtOnBlock[i] = p.lastCellBoughtOnBlockNumber;
            names[i] = p.name;
        }
        
        return (scores, lastCellBoughtOnBlock, addresses, names);
    }
    
    function getCells () external view returns (uint256[] _prices, uint256[] _nextPrice, address[] _owner, bytes32[] _names) {
        uint256[] memory prices = new uint256[](NUMBER_OF_CELLS);
        address[] memory owners = new address[](NUMBER_OF_CELLS);
        bytes32[] memory names = new bytes32[](NUMBER_OF_CELLS);
        uint256[] memory nextPrices = new uint256[](NUMBER_OF_CELLS);
        
        for (uint256 i = 0; i < NUMBER_OF_CELLS; i++) {
             prices[i] = priceOf(i);
             owners[i] = ownerOf(i);
             names[i] = players[ownerOf(i)].name;
             nextPrices[i] = nextPriceOf(i);
        }
        
        return (prices, nextPrices, owners, names);
    }
    
    function getPlayer () external view returns (bytes32 _name, uint256 _score, uint256 _earnings, uint256 _numberOfCellsBought) {
        return (players[msg.sender].name, players[msg.sender].score, earningsOfPlayer(), players[msg.sender].numberOfCellsBought);
    }
    
    function getCurrentPotSize () public view returns (uint256 _wei) {
        return potCut;
    }
    
    function getCurrentWinner () public view returns (address _address) {
        return rankOnePlayerAddress;
    }
    
    function getNumberOfBlocksRemainingToWin () public view returns (int256 _numberOfBlocks) {
        return int256(BLOCKS_TO_CONFIRM_TO_WIN_THE_GAME) - int256(block.number.sub(isFirstSinceBlock));
    }
    
    function scoreOf (address _address) public view returns (uint256 _score) {
        return players[_address].score;
    }
    
    function ownerOf (uint256 _cellId) public view returns (address _owner) {
        return cells[_cellId].owner;
    }
    
    function isGameFinished() public view returns (bool _isGameFinished) {
        return rankOnePlayerAddress != address(0) && getNumberOfBlocksRemainingToWin() < 0;
    }
    
    function calculateScoresIfCellIsBought (address _newOwner, address _oldOwner, uint256 _cellId) internal view returns (uint256 _newOwnerScore, uint256 _oldOwnerScore) {
         
        uint256 oldOwnerScoreAdjustment = DEFAULT_POINTS_PER_CELL;
        
         
        uint256 newOwnerScoreAdjustment = DEFAULT_POINTS_PER_CELL;
        
         
         
        oldOwnerScoreAdjustment = oldOwnerScoreAdjustment.add(calculateNumberOfNeighbours(_cellId, _oldOwner).mul(POINTS_PER_NEIGHBOUR).mul(2));
        newOwnerScoreAdjustment = newOwnerScoreAdjustment.add(calculateNumberOfNeighbours(_cellId, _newOwner).mul(POINTS_PER_NEIGHBOUR).mul(2));
        
        if (_oldOwner == address(0)) {
            oldOwnerScoreAdjustment = 0;
        }
        
        return (scoreOf(_newOwner).add(newOwnerScoreAdjustment), scoreOf(_oldOwner).sub(oldOwnerScoreAdjustment));
    }
    
     
    function calculateNumberOfNeighbours(uint256 _cellId, address _address) internal view returns (uint256 _numberOfNeighbours) {
        uint256 numberOfNeighbours;
        
        (uint256 top, uint256 bottom, uint256 left, uint256 right) = getNeighbourhoodOf(_cellId);
        
        if (top != NUMBER_OF_CELLS && ownerOf(top) == _address) {
            numberOfNeighbours = numberOfNeighbours.add(1);
        }
        
        if (bottom != NUMBER_OF_CELLS && ownerOf(bottom) == _address) {
            numberOfNeighbours = numberOfNeighbours.add(1);
        }
        
        if (left != NUMBER_OF_CELLS && ownerOf(left) == _address) {
            numberOfNeighbours = numberOfNeighbours.add(1);
        }
        
        if (right != NUMBER_OF_CELLS && ownerOf(right) == _address) {
            numberOfNeighbours = numberOfNeighbours.add(1);
        }
        
        return numberOfNeighbours;
    }

    function getNeighbourhoodOf(uint256 _cellId) internal pure returns (uint256 _top, uint256 _bottom, uint256 _left, uint256 _right) {
         
        
         
        uint256 topCellId = NUMBER_OF_CELLS;
        
         
        if(_cellId >= NUMBER_OF_LINES){
           topCellId = _cellId.sub(NUMBER_OF_LINES);
        }
        
         
        uint256 bottomCellId = _cellId.add(NUMBER_OF_LINES);
        
         
        if (bottomCellId >= NUMBER_OF_CELLS) {
            bottomCellId = NUMBER_OF_CELLS;
        }
        
         
        uint256 leftCellId = NUMBER_OF_CELLS;
        
         
         
        if ((_cellId % NUMBER_OF_LINES) != 0) {
            leftCellId = _cellId.sub(1);
        }
        
         
        uint256 rightCellId = _cellId.add(1);

         
         
        if ((rightCellId % NUMBER_OF_LINES) == 0) {
            rightCellId = NUMBER_OF_CELLS;
        }
        
        return (topCellId, bottomCellId, leftCellId, rightCellId);
    }

    function _transfer(address _from, address _to, uint256 _cellId) internal {
        require(_cellId < NUMBER_OF_CELLS);
        require(ownerOf(_cellId) == _from);
        require(_to != address(0));
        require(_to != address(this));
        cells[_cellId].owner = _to;
    }
    
     
    function withdrawPot(string _message) public {
        require(!isContract(msg.sender));
        require(msg.sender != owner);
         
         
        require(rankOnePlayerAddress == msg.sender);
        require(isGameFinished());
        
        uint256 toWithdraw = potCut;
        potCut = 0;
        msg.sender.transfer(toWithdraw);
        
        TheEthGameTrophy trophy = TheEthGameTrophy(trophyAddress);
        trophy.award(msg.sender, _message);
    }
    
    function withdrawDevelopersCut () onlyOwner() public {
        uint256 toWithdraw = developersCut;
        developersCut = 0;
        owner.transfer(toWithdraw);
    }
  
    function withdrawEarnings () public {
        distributeEarningsBasedOnScore(msg.sender, address(0));
        distributeEarningsBasedOnNumberOfCells(msg.sender);
        
        uint256 toWithdraw = earningsOfPlayer();
        players[msg.sender].earnings = 0;
        
        msg.sender.transfer(toWithdraw);
    }
    
     
    function setName(bytes32 _name) public {
        if (nameToAddress[_name] != address(0)) {
            return;
        }
        
        players[msg.sender].name = _name;
        nameToAddress[_name] = msg.sender;
    }
    
    function nameOf(address _address) external view returns(bytes32 _name) {
        return players[_address].name;
    }
    
    function addressOf(bytes32 _name) external view returns (address _address) {
        return nameToAddress[_name];
    }
    
     
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }  
        return size > 0;
    }
}

