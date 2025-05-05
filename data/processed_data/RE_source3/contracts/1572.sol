contract World is
  ReentryProtectorMixin,
  NameableMixin,
  MoneyRounderMixin,
  FundsHolderMixin,
  ThroneRulesMixin {

    // The topWizard runs the world. They charge for the creation of
    // kingdoms and become the topWizard in each kingdom created.
    address public topWizard;

    // How much one must pay to create a new kingdom (in wei).
    // Can be changed by the topWizard.
    uint public kingdomCreationFeeWei;

    struct KingdomListing {
        uint kingdomNumber;
        string kingdomName;
        address kingdomContract;
        address kingdomCreator;
        uint creationTimestamp;
        address kingdomFactoryUsed;
    }
    
    // The first kingdom is number 1; the zero-th entry is a dummy.
    KingdomListing[] public kingdomsByNumber;

    // For safety, we cap just how high the price can get.
    // Can be changed by the topWizard, though it will only affect
    // kingdoms created after that.
    uint public maximumClaimPriceWei;

    // Helper 