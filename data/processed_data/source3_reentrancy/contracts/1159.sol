contract blackjack is casino {
  struct Game {
    /** the hash of the (partial) deck **/
    bytes32 deck;
    /** the hash of the casino seed used for randomness generation and deck-hashing, also serves as id**/
    bytes32 seedHash;
    /** the player address **/
    address player;
    /** the bet **/
    uint bet;
  }

  /** the value of the cards: Ace, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K . Ace can be 1 or 11, of course. 
   *   the value of a card can be determined by looking up cardValues[cardId%13]**/
  uint8[13] cardValues = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10];

  /** use the game id to reference the games **/
  mapping(bytes32 => Game) games;
  /** list of splits per game - length 0 in most cases **/
  mapping(bytes32 => uint8[]) splits;
  /** tells if a hand of a given game has been doubled **/
  mapping(bytes32 => mapping(uint8 => bool)) doubled;
  /** tells if the player already claimed his win **/
  mapping(bytes32 => bool) over;

  /** notify listeners that a new round of blackjack started **/
  event NewGame(bytes32 indexed id, bytes32 deck, bytes32 srvSeed, bytes32 cSeed, address player, uint bet);
  /** notify listeners of the game outcome **/
  event Result(bytes32 indexed id, address player, uint win);
  /** notify listeners that the player doubled **/
  event Double(bytes32 indexed id, uint8 hand);
  /** notify listeners that the player split **/
  event Split(bytes32 indexed id, uint8 hand);

  /** 
   * constructur. initialize the 