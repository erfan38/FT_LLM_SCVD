pragma solidity ^0.4.20;



library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal  pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal  pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ICOCycle {

    using SafeMath for uint;

    

    address public juryOperator; 
    address public operator; 
    address public icoAddress; 
    address public juryOnlineWallet; 
    address public projectWallet; 
    address public arbitrationAddress; 
    Token public token; 

    address public swapper; 

    bool public saveMe; 

    struct Milestone {
        uint etherAmount; 
        uint tokenAmount; 
        uint startTime; 
        uint finishTime; 
        uint duration; 
        string description;
        string result;
    }

    Milestone[] public milestones; 
    uint public currentMilestone;

    uint public sealTimestamp; 

    uint public ethForMilestone; 
    uint public postDisputeEth; 

    
    
    struct Investor {
        bool disputing;
        uint tokenAllowance;
        uint etherUsed;
        uint sumEther;
        uint sumToken;
        bool verdictForProject;
        bool verdictForInvestor;
        uint numberOfDeals;
    }

    struct Deal {
        address investor;
        uint etherAmount;
        uint tokenAmount;
        bool accepted;
    }

    mapping(address => Investor) public deals; 
    address[] public dealsList; 
    mapping(address => mapping(uint => Deal)) public offers; 

    
    
    
    
    
    
    uint[] public commissionEth;
    uint[] public commissionJot;
    uint public etherAllowance; 
    uint public jotAllowance; 

    uint public totalEther; 
    uint public totalToken; 

    uint public promisedTokens; 
    uint public raisedEther; 

    uint public rate; 
    bool public tokenReleaseAtStart; 
    uint public currentFundingRound;

    bool public roundFailedToStart;

    
    mapping(address => uint[]) public etherPartition;
    mapping(address => uint[]) public tokenPartition;

    
    struct FundingRound {
        uint startTime;
        uint endTime;
        uint rate;
        bool hasWhitelist;
    }

    FundingRound[] public roundPrices;  
    mapping(uint => mapping(address => bool)) public whitelist; 

    
    
    modifier onlyOperator() {
        require(msg.sender == operator || msg.sender == juryOperator);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == operator || msg.sender == juryOperator);
        _;
    }

    modifier sealed() {
        require(sealTimestamp != 0);
        
        _;
    }

    modifier notSealed() {
        require(sealTimestamp == 0);
        
        _;
    }
    
    
    
    
    
    
    
    
    
    constructor( address _icoAddress, address _operator, uint _rate, address _swapper, uint[] _commissionEth, uint[] _commissionJot) public {
        require(_commissionEth.length == _commissionJot.length);
        juryOperator = msg.sender;
        icoAddress = _icoAddress;
        operator = _operator;
        rate = _rate;
        swapper = _swapper;
        commissionEth = _commissionEth;
        commissionJot = _commissionJot;
        roundPrices.push(FundingRound(0,0,0,false));
        tokenReleaseAtStart = true;
    }

    
    function setSwapper(address _swapper) public {
        require(msg.sender == juryOperator);
        swapper = _swapper;
    }

    
    
    function activate() onlyAdmin notSealed public {
        ICOContractX icoContract = ICOContractX(icoAddress);
        require(icoContract.operator() == operator);
        juryOnlineWallet = icoContract.juryOnlineWallet();
        projectWallet = icoContract.projectWallet();
        arbitrationAddress = icoContract.arbitrationAddress();
        token = icoContract.token();
        icoContract.addRound();
    }

    
    
    
    function withdrawEther() public {
        if (roundFailedToStart == true) {
            require(msg.sender.send(deals[msg.sender].sumEther));
        }
        if (msg.sender == operator) {
            require(projectWallet.send(ethForMilestone+postDisputeEth));
            ethForMilestone = 0;
            postDisputeEth = 0;
        }
        if (msg.sender == juryOnlineWallet) {
            require(juryOnlineWallet.send(etherAllowance));
            require(swapper.call.value(jotAllowance)(abi.encodeWithSignature("swapMe()")));
            etherAllowance = 0;
            jotAllowance = 0;
        }
        if (deals[msg.sender].verdictForInvestor == true) {
            require(msg.sender.send(deals[msg.sender].sumEther - deals[msg.sender].etherUsed));
        }
    }

    
    function withdrawToken() public {
        require(token.transfer(msg.sender,deals[msg.sender].tokenAllowance));
        deals[msg.sender].tokenAllowance = 0;
    }

    
    function addRoundPrice(uint _startTime,uint _endTime, uint _price, address[] _whitelist) public onlyOperator {
        if (_whitelist.length == 0) {
            roundPrices.push(FundingRound(_startTime, _endTime,_price,false));
        } else {
            for (uint i=0 ; i < _whitelist.length ; i++ ) {
                whitelist[roundPrices.length][_whitelist[i]] = true;
            }
            roundPrices.push(FundingRound(_startTime, _endTime,_price,true));
        }
    }

    
    function setRate(uint _rate) onlyOperator public {
        rate = _rate;
    }

    
    function setCurrentFundingRound(uint _fundingRound) public onlyOperator {
        require(roundPrices.length > _fundingRound);
        currentFundingRound = _fundingRound;
    }

    
    function () public payable {
        require(msg.value > 0);
        if (roundPrices[currentFundingRound].hasWhitelist == true) {
            require(whitelist[currentFundingRound][msg.sender] == true);
        }
        uint dealNumber = deals[msg.sender].numberOfDeals;
        offers[msg.sender][dealNumber].investor = msg.sender;
        offers[msg.sender][dealNumber].etherAmount = msg.value;
        deals[msg.sender].numberOfDeals += 1;
    }

    
    function calculateTokens(uint256 _weiAmount) constant public returns (uint256) {

        uint256 tokens = _weiAmount.mul(rate).mul(100).div(75).div(100 finney);
        if(tokens.div(100000000) < 5000)
            return _weiAmount.mul(rate).mul(100).div(80).div(100 finney);

        tokens = _weiAmount.mul(rate).mul(100).div(73).div(100 finney);
        if(tokens.div(100000000) < 25000)
            return _weiAmount.mul(rate).mul(100).div(75).div(100 finney);

        tokens = _weiAmount.mul(rate).mul(100).div(70).div(100 finney);
        if(tokens.div(100000000) < 50000)
            return _weiAmount.mul(rate).mul(100).div(73).div(100 finney);

        tokens = _weiAmount.mul(rate).mul(100).div(65).div(100 finney);
        if(tokens.div(100000000) < 250000)
            return _weiAmount.mul(rate).mul(100).div(70).div(100 finney);

        tokens = _weiAmount.mul(rate).mul(100).div(60).div(100 finney);
        if(tokens.div(100000000) < 500000)
            return _weiAmount.mul(rate).mul(100).div(65).div(100 finney);

        return _weiAmount.mul(rate).mul(100).div(60).div(100 finney);
    }

    
    function withdrawOffer(uint _offerNumber) public {
        require(offers[msg.sender][_offerNumber].accepted == false);
        require(msg.sender.send(offers[msg.sender][_offerNumber].etherAmount));
        offers[msg.sender][_offerNumber].etherAmount = 0;
        
    }

    
    
    function disputeOpened(address _investor) public {
        require(msg.sender == arbitrationAddress);
        deals[_investor].disputing = true;
    }

    
    function verdictExecuted(address _investor, bool _verdictForInvestor,uint _milestoneDispute) public {
        require(msg.sender == arbitrationAddress);
        require(deals[_investor].disputing == true);
        if (_verdictForInvestor) {
            deals[_investor].verdictForInvestor = true;
        } else {
            deals[_investor].verdictForProject = true;
            for (uint i = _milestoneDispute; i < currentMilestone; i++) {
                postDisputeEth += etherPartition[_investor][i];
                deals[_investor].etherUsed += etherPartition[_investor][i];
            }
        }
        deals[_investor].disputing = false;
    }

    
    
    function addMilestone(uint _etherAmount, uint _tokenAmount, uint _startTime, uint _duration, string _description) public notSealed onlyOperator returns(uint) {
        totalEther = totalEther.add(_etherAmount);
        totalToken = totalToken.add(_tokenAmount);
        return milestones.push(Milestone(_etherAmount, _tokenAmount, _startTime, 0, _duration, _description, ""));
    }

    
    function seal() public notSealed onlyOperator {
        require(milestones.length > 0);
        require(token.balanceOf(address(this)) >= totalToken);
        sealTimestamp = now;
    }

    
    function acceptOffer(address _investor, uint _offerNumber) public sealed onlyOperator {
        
        require(offers[_investor][_offerNumber].etherAmount > 0);
        require(offers[_investor][_offerNumber].accepted != true);
        
        offers[_investor][_offerNumber].accepted = true;
        
        uint  _etherAmount = offers[_investor][_offerNumber].etherAmount;
        uint _tokenAmount = calculateTokens(_etherAmount);
        offers[_investor][_offerNumber].tokenAmount = _tokenAmount;
        
        
        if (commissionEth.length == 1) {
            uint etherCommission = _etherAmount.mul(commissionEth[0]).div(100);
            uint jotCommission = _etherAmount.mul(commissionJot[0]).div(100);
            _etherAmount = _etherAmount.sub(etherCommission).sub(jotCommission);
            offers[_investor][_offerNumber].etherAmount = _etherAmount;

            etherAllowance += etherCommission;
            jotAllowance += jotCommission;
        }
        assignPartition(_investor, _etherAmount, _tokenAmount);
        if (!(deals[_investor].sumEther > 0)) dealsList.push(_investor);
        if (tokenReleaseAtStart == true) {
            deals[_investor].tokenAllowance = _tokenAmount;
        }
        
        deals[_investor].sumEther += _etherAmount;
        deals[_investor].sumToken += _tokenAmount;
    }

    
    function startMilestone() public sealed onlyOperator {
        
        
        
        if (currentMilestone != 0 ) {require(milestones[currentMilestone-1].finishTime > 0);}
        for (uint i=0; i < dealsList.length ; i++) {
            address investor = dealsList[i];
            if (deals[investor].disputing == false) {
                if (deals[investor].verdictForInvestor != true) {
                    ethForMilestone += etherPartition[investor][currentMilestone];
                    deals[investor].etherUsed += etherPartition[investor][currentMilestone];
                    if (tokenReleaseAtStart == false) {
                        deals[investor].tokenAllowance += tokenPartition[investor][currentMilestone];
                    }
                }
            }
        }
        milestones[currentMilestone].startTime = now;
        currentMilestone +=1;
        
    }

    
    function finishMilestone(string _result) public onlyOperator {
        require(milestones[currentMilestone-1].finishTime == 0);
        uint interval = now - milestones[currentMilestone-1].startTime;
        require(interval > 1 weeks);
        milestones[currentMilestone-1].finishTime = now;
        milestones[currentMilestone-1].result = _result;
    }
    
    
    
    function failSafe() public onlyAdmin {
        if (msg.sender == operator) {
            saveMe = true;
        }
        if (msg.sender == juryOperator) {
            require(saveMe == true);
            require(juryOperator.send(address(this).balance));
            uint allTheLockedTokens = token.balanceOf(this);
            require(token.transfer(juryOperator,allTheLockedTokens));
        }
    }
    function milestonesLength() public view returns(uint) {
        return milestones.length;
    }
    function assignPartition(address _investor, uint _etherAmount, uint _tokenAmount) internal {
        uint milestoneEtherAmount; 
		uint milestoneTokenAmount; 
		uint milestoneEtherTarget; 
		uint milestoneTokenTarget; 
		uint totalEtherInvestment;
		uint totalTokenInvestment;
        for(uint i=currentMilestone; i<milestones.length; i++) {
			milestoneEtherTarget = milestones[i].etherAmount;
            milestoneTokenTarget = milestones[i].tokenAmount;
			milestoneEtherAmount = _etherAmount.mul(milestoneEtherTarget).div(totalEther);
			milestoneTokenAmount = _tokenAmount.mul(milestoneTokenTarget).div(totalToken);
			totalEtherInvestment = totalEtherInvestment.add(milestoneEtherAmount); 
			totalTokenInvestment = totalTokenInvestment.add(milestoneTokenAmount); 
            if (deals[_investor].sumEther > 0) {
                etherPartition[_investor][i] += milestoneEtherAmount;
    			tokenPartition[_investor][i] += milestoneTokenAmount;
            } else {
                etherPartition[_investor].push(milestoneEtherAmount);
    			tokenPartition[_investor].push(milestoneTokenAmount);
            }

		}
        
		etherPartition[_investor][currentMilestone] += _etherAmount - totalEtherInvestment; 
		tokenPartition[_investor][currentMilestone] += _tokenAmount - totalTokenInvestment; 
    }
    function isDisputing(address _investor) public view returns(bool) {
        return deals[_investor].disputing;
    }
    function investorExists(address _investor) public view returns(bool) {
        if (deals[_investor].sumEther > 0) return true;
        else return false;
    }

}
