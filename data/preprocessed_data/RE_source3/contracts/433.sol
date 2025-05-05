contract InkProtocolCore is InkProtocolInterface, StandardToken {
  string public constant name = "Ink Protocol";
  string public constant symbol = "XNK";
  uint8 public constant decimals = 18;

  uint256 private constant gasLimitForExpiryCall = 1000000;
  uint256 private constant gasLimitForMediatorCall = 4000000;

  enum Expiry {
    Transaction, // 0
    Fulfillment, // 1
    Escalation,  // 2
    Mediation    // 3
  }

  enum TransactionState {
    // This is an internal state to represent an uninitialized transaction.
    Null,                     // 0

    Initiated,                // 1
    Accepted,                 // 2
    Disputed,                 // 3
    Escalated,                // 4
    Revoked,                  // 5
    RefundedByMediator,       // 6
    SettledByMediator,        // 7
    ConfirmedByMediator,      // 8
    Confirmed,                // 9
    Refunded,                 // 10
    ConfirmedAfterExpiry,     // 11
    ConfirmedAfterDispute,    // 12
    RefundedAfterDispute,     // 13
    RefundedAfterExpiry,      // 14
    ConfirmedAfterEscalation, // 15
    RefundedAfterEscalation,  // 16
    Settled                   // 17
  }

  // The running ID counter for all Ink Transactions.
  uint256 private globalTransactionId = 0;

  // Mapping of all transactions by ID (globalTransactionId).
  mapping(uint256 => Transaction) internal transactions;

  // The struct definition for an Ink Transaction.
  struct Transaction {
    // The address of the buyer on the transaction.
    address buyer;
    // The address of the seller on the transaction.
    address seller;
    // The address of the policy 