pragma solidity ^0.4.24;



















contract CDPCreator is DSMath {
    WETH9 public weth;
    ERC20 public peth;
    ERC20 public dai;
    SaiTub public tub;

    event CDPCreated(bytes32 id, address creator, uint256 dai);

    constructor(address _weth, address _peth, address _dai, address _tub) public {
        require(_weth != address(0) && _peth != address(0) && _tub != address(0) && _dai != address(0));
        weth = WETH9(_weth);
        peth = ERC20(_peth);
        dai = ERC20(_dai);
        tub = SaiTub(_tub);

        weth.approve(address(tub), uint(-1));
        peth.approve(address(tub), uint(-1));
    }

    function createCDP(uint256 amountDAI) payable external {
        require(msg.value >= 0.005 ether);
        require(address(weth).call.value(msg.value)());

        bytes32 cupID = tub.open();
        
        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);
        tub.lock(cupID, amountPETH);
        tub.draw(cupID, amountDAI);

        tub.give(cupID, msg.sender);
        dai.transfer(msg.sender, amountDAI);

        emit CDPCreated(cupID, msg.sender, amountDAI);
    }

    function lockETH(uint256 id) payable external {
        require(address(weth).call.value(msg.value)());

        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);

        tub.lock(bytes32(id), amountPETH);
    }

    function convertETHToPETH() payable external {
        require(address(weth).call.value(msg.value)());

        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);
        peth.transfer(msg.sender, amountPETH);
    }

    function convertPETHToETH(uint256 amountPETH) external {
        require(peth.transferFrom(msg.sender, address(this), amountPETH));
        
        uint256 bid = tub.bid(amountPETH);
        tub.exit(amountPETH);
        weth.withdraw(bid);
        msg.sender.transfer(bid);
    }

    function () payable external {
        
        require(msg.sender == address(weth));
    }
}