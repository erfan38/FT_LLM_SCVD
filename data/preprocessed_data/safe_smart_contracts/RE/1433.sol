contract PresaleToken {

    enum Phase {
        Created,
        Running,
        Paused,
        Migrating,
        Migrated
    }
}


// This extends MultiSigWallet with proxy functions to control PresaleToken
// contract.

