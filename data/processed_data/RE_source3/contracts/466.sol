contract ZipperMultisigFactory
{
    address zipper;
    
    function ZipperMultisigFactory(address _zipper) public
    {
        zipper = _zipper;
    }

    function createMultisig() public returns (address _multisig)
    {
        address[] memory addys = new address[](2);
        addys[0] = zipper;
        addys[1] = msg.sender;
        
        MultiSigWallet a = new MultiSigWallet(addys, 2);
        
        MultisigCreated(address(a), msg.sender, zipper);
        
        return address(a);
    }
    
    function changeZipper(address _newZipper) public
    {
        require(msg.sender == zipper);
        zipper = _newZipper;
    }

    event MultisigCreated(address _multisig, address indexed _sender, address indexed _zipper);
}


    // b7f01af8bd882501f6801eb1eea8b22aa2a4979e from https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    
    /// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
    /// @author Stefan George - <[email protected]>
    