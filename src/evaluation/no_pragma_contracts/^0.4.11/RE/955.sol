contract MilestoneTracker {
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;

    struct Milestone {
        string description;     // Description of this milestone
        string url;             // A link to more information (swarm gateway)
        uint minCompletionDate; // Earliest UNIX time the milestone can be paid
        uint maxCompletionDate; // Latest UNIX time the milestone can be paid
        address milestoneLeadLink;
                                // Similar to `recipient`but for this milestone
        address reviewer;       // Can reject the completion of this milestone
        uint reviewTime;        // How many seconds the reviewer has to review
        address paymentSource;  // Where the milestone payment is sent from
        bytes payData;          // Data defining how much ether is sent where

        MilestoneStatus status; // Current status of the milestone
                                // (Completed, AuthorizedForPayment...)
        uint doneTime;          // UNIX time when the milestone was marked DONE
    }

    // The list of all the milestones.
    Milestone[] public milestones;

    address public recipient;   // Calls functions in the name of the recipient
    address public donor;       // Calls functions in the name of the donor
    address public arbitrator;  // Calls functions in the name of the arbitrator

    enum MilestoneStatus {
        AcceptedAndInProgress,
        Completed,
        AuthorizedForPayment,
        Canceled
    }

    // True if the campaign has been canceled
    bool public campaignCanceled;

    // True if an approval on a change to `milestones` is a pending
    bool public changingMilestones;

    // The pending change to `milestones` encoded in RLP
    bytes public proposedMilestones;


    /// @dev The following modifiers only allow specific roles to call functions
    /// with these modifiers
    modifier onlyRecipient { if (msg.sender !=  recipient) throw; _; }
    modifier onlyArbitrator { if (msg.sender != arbitrator) throw; _; }
    modifier onlyDonor { if (msg.sender != donor) throw; _; }

    /// @dev The following modifiers prevent functions from being called if the
    /// campaign has been canceled or if new milestones are being proposed
    modifier campaignNotCanceled { if (campaignCanceled) throw; _; }
    modifier notChanging { if (changingMilestones) throw; _; }

 // @dev Events to make the payment movements easy to find on the blockchain
    event NewMilestoneListProposed();
    event NewMilestoneListUnproposed();
    event NewMilestoneListAccepted();
    event ProposalStatusChanged(uint idProposal, MilestoneStatus newProposal);
    event CampaignCanceled();


///////////
// Constructor
///////////

    /// @notice The Constructor creates the Milestone 