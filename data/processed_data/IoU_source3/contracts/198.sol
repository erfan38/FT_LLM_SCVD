contract asset is owned {
    using strings for *;

    
    struct data {
        
        
        string link;
        
        string encryptionType;
        
        string hashValue;
    }

    data[] dataArray;
    uint dataNum;

    
    bool public isValid;
    
    
    bool public isInit;
    
    
    bool public isTradeable;
    uint public price;

    
    string public remark1;

    
    
    string public remark2;

    
    constructor() public {
        isValid = true;
        isInit = false;
        isTradeable = false;
        price = 0;
        dataNum = 0;
    }

    
    function initAsset(
        uint dataNumber,
        string linkSet,
        string encryptionTypeSet,
        string hashValueSet) public onlyHolder {
        
        var links = linkSet.toSlice();
        var encryptionTypes = encryptionTypeSet.toSlice();
        var hashValues = hashValueSet.toSlice();
        var delim = " ".toSlice();
        
        dataNum = dataNumber;
        
        
        require(isInit == false, "The 