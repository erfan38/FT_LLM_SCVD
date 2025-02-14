contract OrganizeFunds {

  struct ActivityAccount {
    uint credited;   // total funds credited to this account
    uint balance;    // current balance = credited - amount withdrawn
    uint pctx10;     // percent allocation times ten
    address addr;    // payout addr of this acct
  }

  uint constant TENHUNDWEI = 1000;                     // need gt. 1000 wei to distribute
  uint constant MAX_ACCOUNTS = 10;                     // max accounts this 