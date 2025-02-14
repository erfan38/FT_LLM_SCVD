pragma solidity 0.5.6;
















contract MetamorphicContractFactory {
  
  event Metamorphosed(address metamorphicContract, address newImplementation);
  
  
  event MetamorphosedWithConstructor(
    address metamorphicContract,
    address transientContract
  );

  
  bytes private _metamorphicContractInitializationCode;

  
  bytes32 private _metamorphicContractInitializationCodeHash;

  
  bytes private _transientContractInitializationCode;

  
  bytes32 private _transientContractInitializationCodeHash;

  
  mapping(address => address) private _implementations;

  
  mapping(address => bytes) private _initCodes;

  



















































































  constructor(bytes memory transientContractInitializationCode) public {
    
    _metamorphicContractInitializationCode = (
      hex"5860208158601c335a63aaf10f428752fa158151803b80938091923cf3"
    );

    
    _metamorphicContractInitializationCodeHash = keccak256(
      abi.encodePacked(
        _metamorphicContractInitializationCode
      )
    );

    
    _transientContractInitializationCode = transientContractInitializationCode;

    
    _transientContractInitializationCodeHash = keccak256(
      abi.encodePacked(
        _transientContractInitializationCode
      )
    );
  }

  
  



















  function deployMetamorphicContract(
    bytes32 salt,
    bytes calldata implementationContractInitializationCode,
    bytes calldata metamorphicContractInitializationCalldata
  ) external payable containsCaller(salt) returns (
    address metamorphicContractAddress
  ) {
    
    bytes memory implInitCode = implementationContractInitializationCode;
    bytes memory data = metamorphicContractInitializationCalldata;

    
    bytes memory initCode = _metamorphicContractInitializationCode;

    
    address deployedMetamorphicContract;

    
    metamorphicContractAddress = _getMetamorphicContractAddress(salt);

    
    address implementationContract;

    
    
    assembly {
      let encoded_data := add(0x20, implInitCode) 
      let encoded_size := mload(implInitCode)     
      implementationContract := create(       
        0,                                    
        encoded_data,                         
        encoded_size                          
      )
    } 

    require(
      implementationContract != address(0),
      "Could not deploy implementation."
    );

    
    _implementations[metamorphicContractAddress] = implementationContract;

    
    
    assembly {
      let encoded_data := add(0x20, initCode) 
      let encoded_size := mload(initCode)     
      deployedMetamorphicContract := create2( 
        0,                                    
        encoded_data,                         
        encoded_size,                         
        salt                                  
      )
    } 

    
    require(
      deployedMetamorphicContract == metamorphicContractAddress,
      "Failed to deploy the new metamorphic contract."
    );

    
    if (data.length > 0 || msg.value > 0) {
      
      (bool success,) = deployedMetamorphicContract.call.value(msg.value)(data);
      

      require(success, "Failed to initialize the new metamorphic contract.");
    }

    emit Metamorphosed(deployedMetamorphicContract, implementationContract);
  } 

  

















  function deployMetamorphicContractFromExistingImplementation(
    bytes32 salt,
    address implementationContract,
    bytes calldata metamorphicContractInitializationCalldata
  ) external payable containsCaller(salt) returns (
    address metamorphicContractAddress
  ) {
    
    bytes memory data = metamorphicContractInitializationCalldata;

    
    bytes memory initCode = _metamorphicContractInitializationCode;

    
    address deployedMetamorphicContract;

    
    metamorphicContractAddress = _getMetamorphicContractAddress(salt);

    
    _implementations[metamorphicContractAddress] = implementationContract;

    
    
    assembly {
      let encoded_data := add(0x20, initCode) 
      let encoded_size := mload(initCode)     
      deployedMetamorphicContract := create2( 
        0,                                    
        encoded_data,                         
        encoded_size,                         
        salt                                  
      )
    } 

    
    require(
      deployedMetamorphicContract == metamorphicContractAddress,
      "Failed to deploy the new metamorphic contract."
    );

    
    if (data.length > 0 || msg.value > 0) {
      
      (bool success,) = metamorphicContractAddress.call.value(msg.value)(data);
      

      require(success, "Failed to initialize the new metamorphic contract.");
    }

    emit Metamorphosed(deployedMetamorphicContract, implementationContract);
  }

  
  














  function deployMetamorphicContractWithConstructor(
    bytes32 salt,
    bytes calldata initializationCode
  ) external payable containsCaller(salt) returns (
    address metamorphicContractAddress
  ) {
    
    bytes memory initCode = _transientContractInitializationCode;

    
    address deployedTransientContract;

    
    address transientContractAddress = _getTransientContractAddress(salt);

    
    _initCodes[transientContractAddress] = initializationCode;

    
    
    assembly {
      let encoded_data := add(0x20, initCode) 
      let encoded_size := mload(initCode)     
      deployedTransientContract := create2(   
        callvalue,                            
        encoded_data,                         
        encoded_size,                         
        salt                                  
      )
    } 

    
    require(
      deployedTransientContract == transientContractAddress,
      "Failed to deploy metamorphic contract using given salt and init code."
    );

    metamorphicContractAddress = _getMetamorphicContractAddressWithConstructor(
      transientContractAddress
    );

    emit MetamorphosedWithConstructor(
      metamorphicContractAddress,
      transientContractAddress
    );
  } 

  



  function getImplementation() external view returns (address implementation) {
    return _implementations[msg.sender];
  }

  





  function getInitializationCode() external view returns (
    bytes memory initializationCode
  ) {
    return _initCodes[msg.sender];
  }

  









  function getImplementationContractAddress(
    address metamorphicContractAddress
  ) external view returns (address implementationContractAddress) {
    return _implementations[metamorphicContractAddress];
  }

  







  function getMetamorphicContractInstanceInitializationCode(
    address transientContractAddress
  ) external view returns (bytes memory initializationCode) {
    return _initCodes[transientContractAddress];
  }

  





  function findMetamorphicContractAddress(
    bytes32 salt
  ) external view returns (address metamorphicContractAddress) {
    
    metamorphicContractAddress = _getMetamorphicContractAddress(salt);
  }

  






  function findTransientContractAddress(
    bytes32 salt
  ) external view returns (address transientContractAddress) {
    
    transientContractAddress = _getTransientContractAddress(salt);
  }

  






  function findMetamorphicContractAddressWithConstructor(
    bytes32 salt
  ) external view returns (address metamorphicContractAddress) {
    
    metamorphicContractAddress = _getMetamorphicContractAddressWithConstructor(
      _getTransientContractAddress(salt)
    );
  }

  



  function getMetamorphicContractInitializationCode() external view returns (
    bytes memory metamorphicContractInitializationCode
  ) {
    return _metamorphicContractInitializationCode;
  }

  



  function getMetamorphicContractInitializationCodeHash() external view returns (
    bytes32 metamorphicContractInitializationCodeHash
  ) {
    return _metamorphicContractInitializationCodeHash;
  }

  



  function getTransientContractInitializationCode() external view returns (
    bytes memory transientContractInitializationCode
  ) {
    return _transientContractInitializationCode;
  }

  



  function getTransientContractInitializationCodeHash() external view returns (
    bytes32 transientContractInitializationCodeHash
  ) {
    return _transientContractInitializationCodeHash;
  }

  



  function _getMetamorphicContractAddress(
    bytes32 salt
  ) internal view returns (address) {
    
    return address(
      uint160(                      
        uint256(                    
          keccak256(                
            abi.encodePacked(       
              hex"ff",              
              address(this),        
              salt,                 
              _metamorphicContractInitializationCodeHash 
            )
          )
        )
      )
    );
  }

  



  function _getTransientContractAddress(
    bytes32 salt
  ) internal view returns (address) {
    
    return address(
      uint160(                      
        uint256(                    
          keccak256(                
            abi.encodePacked(       
              hex"ff",              
              address(this),        
              salt,                 
              _transientContractInitializationCodeHash 
            )
          )
        )
      )
    );
  }

  




  function _getMetamorphicContractAddressWithConstructor(
    address transientContractAddress
  ) internal pure returns (address) { 
    
    return address(
      uint160(                          
        uint256(                        
          keccak256(                    
            abi.encodePacked(           
              byte(0xd6),               
              byte(0x94),               
              transientContractAddress, 
              byte(0x01)                
            )
          )
        )
      )
    );
  }

  





  modifier containsCaller(bytes32 salt) {
    
    
    require(
      address(bytes20(salt)) == msg.sender,
      "Invalid salt - first 20 bytes of the salt must match calling address."
    );
    _;
  }
}