contract AppCoinsIAB is AppCoinsIABInterface {

    uint public dev_share = 85;
    uint public appstore_share = 10;
    uint public oem_share = 5;

    mapping (address => bool) allowedAddresses;
    address owner;

    modifier onlyAllowedAddress(string _funcName) {
        if(!allowedAddresses[msg.sender]){
            emit Error(_funcName, "Operation can only be performed by allowed Addresses");
            return;
        }
        _;
    }

    modifier onlyOwner(string _funcName) {
        if(owner != msg.sender){
            emit Error(_funcName, "Operation can only be performed by 