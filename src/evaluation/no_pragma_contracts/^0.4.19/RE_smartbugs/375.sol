library ArrayLib {
  
	function insertInPlace(uint8[] storage self, uint8 n) {
		uint8 insertingIndex = 0;

		while (self.length > 0 && insertingIndex < self.length && self[insertingIndex] < n) {
			insertingIndex += 1;
		}

		self.length += 1;
		for (uint8 i = uint8(self.length) - 1; i > insertingIndex; i--) {
			self[i] = self[i - 1];
		}

		self[insertingIndex] = n;
	}
}

library DeckLib {
	using ArrayLib for uint8[];

	enum Suit { Spades, Hearts, Clubs, Diamonds }
	uint8 constant cardsPerSuit = 13;
	uint8 constant suits = 4;
	uint8 constant totalCards = cardsPerSuit * suits;

	struct Deck {
		uint8[] usedCards; 
		address player;
		uint256 gameID;
	}

	function init(Deck storage self, uint256 gameID)  {
		self.usedCards = new uint8[](0);
		self.player = msg.sender;
		self.gameID = gameID;
	}

	function getCard(Deck storage self, uint256 blockNumber)  returns (uint8)  {
		uint cardIndex = self.usedCards.length;
		if (cardIndex >= totalCards) throw;
		uint8 r = uint8(getRandomNumber(blockNumber, self.player, self.gameID, cardIndex, totalCards - cardIndex));

		for (uint8 i = 0; i < cardIndex; i++) {
			if (self.usedCards[i] <= r) r += 1;
		}

		self.usedCards.insertInPlace(r);

		return r;
	}

	function cardDescription(uint8 self) constant returns (Suit, uint8) {
		return (Suit(self / cardsPerSuit), cardFacevalue(self));
	}

	function cardEmojified(uint8 self) constant returns (uint8, string) {
		string memory emojiSuit;

		var (suit, number) = cardDescription(self);
		if (suit == Suit.Clubs) emojiSuit = "♣️";
		else if (suit == Suit.Diamonds) emojiSuit = "♦️";
		else if (suit == Suit.Hearts) emojiSuit = "♥️";
		else if (suit == Suit.Spades) emojiSuit = "♠️";

		return (number, emojiSuit);
	}

	function cardFacevalue(uint8 self) constant returns (uint8) {
		return 1 + self % cardsPerSuit;
	}

	function blackjackValue(uint8 self) constant returns (uint8) {
		uint8 cardValue = cardFacevalue(self);
		return cardValue < 10 ? cardValue : 10;
	}

	function getRandomNumber(uint b, address player, uint256 gameID, uint n, uint m) constant returns (uint) {
		
		
		bytes32 blockHash = block.blockhash(b);
		if (blockHash == 0x0) throw;
		return uint(uint256(keccak256(blockHash, player, gameID, n)) % m);

	}
}

contract Blockjack {
  AbstractBlockjackLogs blockjacklogs;

  using GameLib for GameLib.Game;

  GameLib.Game[] games;
  mapping (address => uint256) public currentGame;

  bool contractCleared;
  
  uint256 public minBet = 50 finney;
  uint256 public maxBet = 500 finney;
  bool public allowsNewGames = false;
  uint256 public maxBlockActions = 10;

  mapping (uint256 => uint256) blockActions;

  

  
  
  

  
  address public DX = 0x296Ae1d2D9A8701e113EcdF6cE986a4a7D0A6dC5;
  address public DEV = 0xBC4343B11B7cfdd6dD635f61039b8a66aF6E73Bb;



  address public ADMIN_CONTRACT;

  uint256 public BANKROLL_LOCK_PERIOD = 30 days;

  uint256 public bankrollLockedUntil;
  uint256 public profitsLockedUntil;
  uint256 public initialBankroll;
  uint256 public currentBankroll;

  mapping (address => bool) public isOwner;

  modifier onlyOwner {
    if (!isOwner[msg.sender]) throw;
    _;
  }

  modifier only(address x) {
    if (msg.sender != x) throw;
    _;
  }

  modifier onlyPlayer(uint256 gameID) {
    if (msg.sender != games[gameID].player) throw;
    _;
  }

  modifier blockActionProtected {
    blockActions[block.number] += 1;
    if (blockActions[block.number] > maxBlockActions) throw;
    _;
  }

  function Blockjack(address _admin_contract, address _logs_contract) { 
    ADMIN_CONTRACT = _admin_contract;
    blockjacklogs = AbstractBlockjackLogs(_logs_contract);
    games.length += 1;
    games[0].init(0); 
    games[0].player = this;
    setupTrustedAccounts();
  }

  function () payable {
    startGame();
  }

  function startGame() blockActionProtected payable {
    if (!allowsNewGames) throw;
    if (msg.value < minBet) throw;
    if (msg.value > maxBet) throw;

    
    uint256 currentGameId = currentGame[msg.sender];
    if (games.length > currentGameId) {
      GameLib.Game openedGame = games[currentGameId];
      if (openedGame.player == msg.sender && !openedGame.closed) { 
	if (!openedGame.tick()) throw;
	if (!openedGame.closed) throw; 
	recordEndedGame(currentGameId);
      }
    }
    uint256 newGameID = games.length;

    games.length += 1;
    games[newGameID].init(newGameID);
    currentGame[msg.sender] = newGameID;
    tickRequiredLog(games[newGameID]);
  }

  function hit(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];

    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Hit);
    tickRequiredLog(game);
  }

  function doubleDown(uint256 gameID) onlyPlayer(gameID) blockActionProtected payable {
    GameLib.Game game = games[gameID];

    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.DoubleDown);
    tickRequiredLog(game);
  }

  function stand(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];

    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Stand);
    tickRequiredLog(game);
  }

  function gameTick(uint256 gameID) blockActionProtected {
    GameLib.Game openedGame = games[gameID];
    if (openedGame.closed) throw;
    if (!openedGame.tick()) throw;
    if (openedGame.closed) recordEndedGame(gameID);
  }

  function recordEndedGame(uint gameID) private {
    GameLib.Game openedGame = games[gameID];

    
    if(currentBankroll + openedGame.bet > openedGame.payout){
      currentBankroll = currentBankroll + openedGame.bet - openedGame.payout;
    }

    blockjacklogs.recordLog(
			    openedGame.gameID,
			    openedGame.player,
			    uint(openedGame.result),
			    openedGame.payout,
			    GameLib.countHand(openedGame.playerCards),
			    GameLib.countHand(openedGame.houseCards)
			    );
  }

  function tickRequiredLog(GameLib.Game storage game) private {
    blockjacklogs.tickRequiredLog(game.gameID, game.player, game.actionBlock);
  }

  

  function gameState(uint i) constant returns (uint8[], uint8[], uint8, uint8, uint256, uint256, uint8, uint8, bool, uint256) {
    GameLib.Game game = games[i];

    return (
	    game.houseCards,
	    game.playerCards,
	    GameLib.countHand(game.houseCards),
	    GameLib.countHand(game.playerCards),
	    game.bet,
	    game.payout,
	    uint8(game.state),
	    uint8(game.result),
	    game.closed,
	    game.actionBlock
	    );
  }

  
  function setupTrustedAccounts()
    internal
  {
    isOwner[DX] = true;
    isOwner[DEV] = true;
    isOwner[ADMIN_CONTRACT] = true;
  }

  function changeDev(address newDev) only(DEV) {
    isOwner[DEV] = false;
    DEV = newDev;
    isOwner[DEV] = true;
  }

  function changeDX(address newDX) only(DX) {
    isOwner[DX] = false;
    DX = newDX;
    isOwner[DX] = true;
  }

  function changeAdminContract(address _new_admin_contract) only(ADMIN_CONTRACT) {
    isOwner[ADMIN_CONTRACT] = false;
    ADMIN_CONTRACT = _new_admin_contract;
    isOwner[ADMIN_CONTRACT] = true;
  }

  function setSettings(uint256 _min, uint256 _max, uint256 _maxBlockActions) only(ADMIN_CONTRACT) {
    minBet = _min;
    maxBet = _max;
    maxBlockActions = _maxBlockActions;
  }

  function registerOwner(address _new_watcher) only(ADMIN_CONTRACT) {
    isOwner[_new_watcher] = true;
  }

  function removeOwner(address _old_watcher) only(ADMIN_CONTRACT) {
    isOwner[_old_watcher] = false;
  }

  function stopBlockjack() onlyOwner {
    allowsNewGames = false;
  }

  function startBlockjack() only(ADMIN_CONTRACT) {
    allowsNewGames = true;
  }

  function addBankroll() only(DX) payable {
    initialBankroll += msg.value;
    currentBankroll += msg.value;
  }

  function remainingBankroll() constant returns (uint256) {
    return currentBankroll > initialBankroll ? initialBankroll : currentBankroll;
  }

  function removeBankroll() only(DX) {
    if (initialBankroll > currentBankroll - 5 ether && bankrollLockedUntil > now) throw;

    stopBlockjack();

    if (currentBankroll > initialBankroll) { 
      if (!DEV.send(currentBankroll - initialBankroll)) throw;
    }

    suicide(DX); 
    contractCleared = true;
  }

  function migrateBlockjack() only(ADMIN_CONTRACT) {
    stopBlockjack();

    if (currentBankroll > initialBankroll) { 
      if (!ADMIN_CONTRACT.call.value(currentBankroll - initialBankroll)()) throw;
    }
    suicide(DX); 
    
  }

  function shareProfits() onlyOwner {
    if (profitsLockedUntil > now) throw;
    if (currentBankroll <= initialBankroll) throw; 

    uint256 profit = currentBankroll - initialBankroll;
    if (!ADMIN_CONTRACT.call.value(profit)()) throw;
    currentBankroll -= profit;

    bankrollLockedUntil = now + BANKROLL_LOCK_PERIOD;
    profitsLockedUntil = bankrollLockedUntil + BANKROLL_LOCK_PERIOD;
  }
}