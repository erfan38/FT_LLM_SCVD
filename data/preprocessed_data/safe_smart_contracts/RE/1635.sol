contract KlerosGovernor is Arbitrable {
    using CappedMath for uint;

    /* *** Contract variables *** */
    enum Status { NoDispute, DisputeCreated, Resolved }

    struct Session {
        Round[] rounds; // Tracks each appeal round of the dispute in the session in the form rounds[appeal].
        uint ruling; // The ruling that was given in this session, if any.
        uint disputeID; // ID given to the dispute of the session, if any.
        uint[] submittedLists; // Tracks all lists that were submitted in a session in the form submittedLists[submissionID].
        uint sumDeposit; // Sum of all submission deposits in a session (minus arbitration fees). This is used to calculate the reward.
        Status status; // Status of a session.
        mapping(bytes32 => bool) alreadySubmitted; // Indicates whether or not the transaction list was already submitted in order to catch duplicates in the form alreadySubmitted[listHash].
        uint durationOffset; // Time in seconds that prolongs the submission period after the first submission, to give other submitters time to react.
    }

    struct Transaction {
        address target; // The address to call.
        uint value; // Value paid by governor 