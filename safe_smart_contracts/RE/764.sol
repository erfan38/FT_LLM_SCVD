contract UpgradeEventCompact {
  using SafeMath for uint;

  // states
  //  - verifying, initial state
  //  - controlling, after verifying, before complete
  //  - complete, after controlling
  enum EventState { Verifying, Complete }
  EventState public state;

  // Terms
  address public nextController;
  address public oldController;
  address public council;

  // Params
  address nextPullPayment;
  address storageAddr;
  address nutzAddr;
  address powerAddr;
  uint256 maxPower;
  uint256 downtime;
  uint256 purchasePrice;
  uint256 salePrice;

  function UpgradeEventCompact(address _oldController, address _nextController, address _nextPullPayment) {
    state = EventState.Verifying;
    nextController = _nextController;
    oldController = _oldController;
    nextPullPayment = _nextPullPayment; //the ownership of this satellite should be with oldController
    council = msg.sender;
  }

  modifier isState(EventState _state) {
    require(state == _state);
    _;
  }

  function upgrade() isState(EventState.Verifying) {
    // check old controller
    var old = Controller(oldController);
    old.pause();
    require(old.admins(1) == address(this));
    require(old.paused() == true);
    // check next controller
    var next = Controller(nextController);
    require(next.admins(1) == address(this));
    require(next.paused() == true);
    // kill old one, and transfer ownership
    // transfer ownership of payments and storage to here
    storageAddr = old.storageAddr();
    nutzAddr = old.nutzAddr();
    powerAddr = old.powerAddr();
    maxPower = old.maxPower();
    downtime = old.downtime();
    purchasePrice = old.ceiling();
    salePrice = old.floor();
    uint newPowerPool = (old.outstandingPower()).mul(old.activeSupply().add(old.burnPool())).div(old.authorizedPower().sub(old.outstandingPower()));
    //set pull payment 