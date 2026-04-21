























pragma solidity ^0.4.24;








contract SignatureChallenge is Ownable {

  bool public active = true;
  uint8 public challengeBytes = 2;

  function () external payable {
    require(msg.value == 0, "SC01");
    acceptCode(msg.data);
  }

  


  function updateChallenge(
    bool _active,
    uint8 _challengeBytes,
    bytes _testCode) public onlyOwner
  {
    if(!signChallengeWhenValid()) {
      active = _active;
      challengeBytes = _challengeBytes;
      emit ChallengeUpdated(_active, _challengeBytes);

      if (active) {
        acceptCode(_testCode);
      }
    }
  }

  


  function execute(address _target, bytes _data)
    public payable
  {
    if (!signChallengeWhenValid()) {
      executeOwnerRestricted(_target, _data);
    }
  }

  


  function signChallengeWhenValid() private returns (bool)
  {
    
    
    if (active && msg.data.length == challengeBytes) {
      require(msg.value == 0, "SC01");
      acceptCode(msg.data);
      return true;
    }
    return false;
  }

  


  function executeOwnerRestricted(address _target, bytes _data)
    private onlyOwner
  {
    require(_target != address(0), "SC02");
    
    require(_target.call.value(msg.value)(_data), "SC03");
  }

  


  function acceptCode(bytes _code) private {
    require(active, "SC04");
    require(_code.length == challengeBytes, "SC05");
    emit ChallengeSigned(msg.sender, _code);
  }

  event ChallengeUpdated(bool active, uint8 length);
  event ChallengeSigned(address indexed signer, bytes code);
}