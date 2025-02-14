
























pragma solidity ^0.4.24;

















contract MultiSig {
  address[]  signers_;
  uint8 public threshold;

  bytes32 public replayProtection;
  uint256 public nonce;

  


  constructor(address[] _signers, uint8 _threshold) public {
    signers_ = _signers;
    threshold = _threshold;

    
    
    updateReplayProtection();
  }

  


  function () public payable { }

  



  function readSelector(bytes _data) public pure returns (bytes4) {
    bytes4 selector;
    
    assembly {
      selector := mload(add(_data, 0x20))
    }
    return selector;
  }

  



  function readERC20Destination(bytes _data) public pure returns (address) {
    address destination;
    
    assembly {
      destination := mload(add(_data, 0x24))
    }
    return destination;
  }

  



  function readERC20Value(bytes _data) public pure returns (uint256) {
    uint256 value;
    
    assembly {
      value := mload(add(_data, 0x44))
    }
    return value;
  }

  


  modifier thresholdRequired(
    address _destination, uint256 _value, bytes _data,
    uint256 _validity, uint256 _threshold,
    bytes32[] _sigR, bytes32[] _sigS, uint8[] _sigV)
  {
    require(
      reviewSignatures(
        _destination, _value, _data, _validity, _sigR, _sigS, _sigV
      ) >= _threshold,
      "MS01"
    );
    _;
  }

  








  modifier stillValid(uint256 _validity)
  {
    if (_validity != 0) {
      require(_validity >= block.number, "MS02");
    }
    _;
  }

  


  modifier onlySigners() {
    bool found = false;
    for (uint256 i = 0; i < signers_.length && !found; i++) {
      found = (msg.sender == signers_[i]);
    }
    require(found, "MS03");
    _;
  }

  


  function signers() public view returns (address[]) {
    return signers_;
  }

  


  function threshold() public view returns (uint8) {
    return threshold;
  }

  


  function replayProtection() public view returns (bytes32) {
    return replayProtection;
  }

  


  function nonce() public view returns (uint256) {
    return nonce;
  }

  


  function reviewSignatures(
    address _destination, uint256 _value, bytes _data,
    uint256 _validity,
    bytes32[] _sigR, bytes32[] _sigS, uint8[] _sigV)
    public view returns (uint256)
  {
    return reviewSignaturesInternal(
      _destination,
      _value,
      _data,
      _validity,
      signers_,
      _sigR,
      _sigS,
      _sigV
    );
  }

  


  function buildHash(
    address _destination, uint256 _value,
    bytes _data, uint256 _validity)
    public view returns (bytes32)
  {
    
    if (_data.length == 0) {
      return keccak256(
        abi.encode(
          _destination, _value, _validity, replayProtection
        )
      );
    } else {
      return keccak256(
        abi.encode(
          _destination, _value, _data, _validity, replayProtection
        )
      );
    }
  }

  


  function recoverAddress(
    address _destination, uint256 _value,
    bytes _data, uint256 _validity,
    bytes32 _r, bytes32 _s, uint8 _v)
    public view returns (address)
  {
    
    bytes32 hash = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32",
        buildHash(
          _destination,
          _value,
          _data,
          _validity
        )
      )
    );

    
    uint8 v = (_v < 27) ? _v += 27: _v;

    
    if (v != 27 && v != 28) {
      return address(0);
    } else {
      return ecrecover(
        hash,
        v,
        _r,
        _s
      );
    }
  }

  


  function execute(
    bytes32[] _sigR,
    bytes32[] _sigS,
    uint8[] _sigV,
    address _destination, uint256 _value, bytes _data, uint256 _validity)
    public
    stillValid(_validity)
    thresholdRequired(_destination, _value, _data, _validity, threshold, _sigR, _sigS, _sigV)
    returns (bool)
  {
    executeInternal(_destination, _value, _data);
    return true;
  }

  






  function reviewSignaturesInternal(
    address _destination, uint256 _value, bytes _data, uint256 _validity,
    address[] _signers,
    bytes32[] _sigR, bytes32[] _sigS, uint8[] _sigV)
    internal view returns (uint256)
  {
    uint256 length = _sigR.length;
    if (length == 0 || length > _signers.length || (
      _sigS.length != length || _sigV.length != length
    ))
    {
      return 0;
    }

    uint256 validSigs = 0;
    address recovered = recoverAddress(
      _destination, _value, _data, _validity, 
      _sigR[0], _sigS[0], _sigV[0]);
    for (uint256 i = 0; i < _signers.length; i++) {
      if (_signers[i] == recovered) {
        validSigs++;
        if (validSigs < length) {
          recovered = recoverAddress(
            _destination,
            _value,
            _data,
            _validity,
            _sigR[validSigs],
            _sigS[validSigs],
            _sigV[validSigs]
          );
        } else {
          break;
        }
      }
    }

    if (validSigs != length) {
      return 0;
    }

    return validSigs;
  }

  


  function executeInternal(address _destination, uint256 _value, bytes _data)
    internal
  {
    updateReplayProtection();
    if (_data.length == 0) {
      _destination.transfer(_value);
    } else {
      
      require(_destination.call.value(_value)(_data), "MS04");
    }
    emit Execution(_destination, _value, _data);
  }

  





  function updateReplayProtection() internal {
    replayProtection = keccak256(
      abi.encodePacked(address(this), blockhash(block.number-1), nonce));
    nonce++;
  }

  event Execution(address to, uint256 value, bytes data);
}







