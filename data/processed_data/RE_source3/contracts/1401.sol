contract BaktFactory is Factory
{
    // Live: 0xc7c11eb6983787f7aa0c20abeeac8101cf621e47
    // https://etherscan.io/address/0xc7c11eb6983787f7aa0c20abeeac8101cf621e47
    // Ropsten: 0xda33129464688b7bd752ce64e9ed6bca65f44902 (could not verify),
    //          0x19124dbab3fcba78b8d240ed2f2eb87654e252d4
    // Rinkeby: 

/* Constants */

    bytes32 constant public regName = "Bakt";
    bytes32 constant public VERSION = "Bakt Factory v0.3.4-beta";

/* Constructor Destructor*/

    function BaktFactory(address _creator, bytes32 _regName, address _owner)
        Factory(_creator, _regName, _owner)
    {
        // nothing to construct
    }

/* Public Functions */

    function createNew(bytes32 _regName, address _owner)
        payable
        feePaid
        returns (address kAddr_)
    {
        require(_regName != 0x0);
        kAddr_ = new Bakt(owner, _regName, msg.sender);
        Created(msg.sender, _regName, kAddr_);
    }
}