contract Kingdom is
  ReentryProtectorMixin,
  CarefulSenderMixin,
  FundsHolderMixin,
  MoneyRounderMixin,
  NameableMixin,
  ThroneRulesMixin {

    // e.g. "King of the Ether"
    string public kingdomName;

    // The World 