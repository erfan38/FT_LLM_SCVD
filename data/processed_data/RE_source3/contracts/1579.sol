contract TriWallet {
  // Is set to true in the forked branch and to false in classic branch.
  bool public thisIsFork;

  // Address of ETC subwallet.
  address public etcWallet;

  // Address of ETH subwallet.
  address public ethWallet;

  // Log address of ETC subwallet
  event ETCWalletCreated(address etcWalletAddress);

  // Log address of ETH subwallet
  event ETHWalletCreated(address ethWalletAddress);

  // Instantiate the contract.
  function TriWallet () {
    // Check whether we are in fork branch or in classic one
    thisIsFork = BranchSender (0x23141df767233776f7cbbec497800ddedaa4c684).isRightBranch ();
    
    // Create ETC subwallet
    etcWallet = new BranchWallet (msg.sender, !thisIsFork);
    
    // Create ETH subwallet
    ethWallet = new BranchWallet (msg.sender, thisIsFork);
  
    // Log address of ETC subwallet
    ETCWalletCreated (etcWallet);

    // Log address of ETH subwallet
    ETHWalletCreated (ethWallet);
  }

  // Distribute pending balance between ETC and ETH subwallets.
  function distribute () {
    if (thisIsFork) {
      // Send all ETH to ETH subwallet
      if (!ethWallet.send (this.balance)) throw;
    } else {
      // Send all ETC to ETC subwallet
      if (!etcWallet.send (this.balance)) throw;
    }
  }
}

// Wallet 