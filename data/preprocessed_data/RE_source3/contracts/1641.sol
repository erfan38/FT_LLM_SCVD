contract PreICOProxyBuyer is Ownable, Haltable {
  using SafeMath for uint;

  /** How many investors we have now */
  uint public investorCount;

  /** How many wei we have raised totla. */
  uint public weiRaised;

  /** Who are our investors (iterable) */
  address[] public investors;

  /** How much they have invested */
  mapping(address => uint) public balances;

  /** How many tokens investors have claimed */
  mapping(address => uint) public claimed;

  /** When our refund freeze is over (UNIT timestamp) */
  uint public freezeEndsAt;

  /** What is the minimum buy in */
  uint public weiMinimumLimit;

  /** What is the maximum buy in */
  uint public weiMaximumLimit;

  /** How many weis total we are allowed to collect. */
  uint public weiCap;

  /** How many tokens were bought */
  uint public tokensBought;

   /** How many investors have claimed their tokens */
  uint public claimCount;

  uint public totalClaimed;

  /** If timeLock > 0, claiming is possible only after the time has passed **/
  uint public timeLock;

  /** This is used to signal that we want the refund **/
  bool public forcedRefund;

  /** Our ICO 