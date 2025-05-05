pragma solidity ^0.4.24;




contract OasisMonetizedProxy is Mortal, DSMath {
    uint feePercentageWad;
    FeeInterface fees;
    constructor(FeeInterface _fees) public {
        fees = _fees;
    }
    
    function setFeeAuthority (FeeInterface newSource) public auth {
        fees = newSource;
    }
    
    function withdrawAndSend(TokenInterface wethToken, uint wethAmt) internal {
        wethToken.withdraw(wethAmt);
        require(msg.sender.call.value(wethAmt)());
    }

    
    
    function sellAllAmount(
        OtcInterface otc,
        TokenInterface payToken, 
        uint payAmt, 
        TokenInterface buyToken, 
        uint minBuyAmt
    ) public returns (uint) {
        require(payToken.transferFrom(msg.sender, this, payAmt));
        if (payToken.allowance(this, otc) < payAmt) {
            payToken.approve(otc, uint(-1));
        }
        uint buyAmt = otc.sellAllAmount(payToken, payAmt, buyToken, minBuyAmt);
        buyToken.balanceOf(this);
        (uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken);
        require(buyToken.transfer(owner, feeAmt)); 
        require(buyToken.transfer(msg.sender, buyAmtRemainder));
        return buyAmtRemainder;
    }

    function sellAllAmountPayEth(
        OtcInterface otc,
        TokenInterface wethToken,
        TokenInterface buyToken,
        uint minBuyAmt
    ) public payable returns (uint) {
        wethToken.deposit.value(msg.value)();
        if (wethToken.allowance(this, otc) < msg.value) {
            wethToken.approve(otc, uint(-1));
        }
        uint buyAmt = otc.sellAllAmount(wethToken, msg.value, buyToken, minBuyAmt); 
        (uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken);
        require(buyToken.transfer(owner, feeAmt)); 
        require(buyToken.transfer(msg.sender, buyAmtRemainder));
        return buyAmtRemainder;
    }

    function sellAllAmountBuyEth(
        OtcInterface otc,
        TokenInterface payToken, 
        uint payAmt, 
        TokenInterface wethToken, 
        uint minBuyAmt
    ) public returns (uint) {
        require(payToken.transferFrom(msg.sender, this, payAmt));
        if (payToken.allowance(this, otc) < payAmt) {
            payToken.approve(otc, uint(-1));
        }
        uint wethAmt = otc.sellAllAmount(payToken, payAmt, wethToken, minBuyAmt);
        (uint feeAmt, uint wethAmtRemainder) = fees.takeFee(wethAmt, wethToken);
        require(wethToken.transfer(owner, feeAmt));  
        withdrawAndSend(wethToken, wethAmtRemainder);
        return wethAmtRemainder;
    }

    function buyAllAmount(
        OtcInterface otc, 
        TokenInterface buyToken, 
        uint buyAmt, 
        TokenInterface payToken, 
        uint maxPayAmt
    ) public returns (uint payAmt) {
        uint payAmtNow = otc.getPayAmount(payToken, buyToken, buyAmt);
        require(payAmtNow <= maxPayAmt);
        require(payToken.transferFrom(msg.sender, this, payAmtNow));
        if (payToken.allowance(this, otc) < payAmtNow) {
            payToken.approve(otc, uint(-1));
        } 
        payAmt = otc.buyAllAmount(buyToken, buyAmt, payToken, payAmtNow);
        min(buyAmt, buyToken.balanceOf(this)); 
        (uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken);
        require(buyToken.transfer(owner, feeAmt)); 
        require(buyToken.transfer(msg.sender, buyAmtRemainder)); 
    }

    function buyAllAmountPayEth(
        OtcInterface otc, 
        TokenInterface buyToken, 
        uint buyAmt, 
        TokenInterface wethToken
    ) public payable returns (uint wethAmt) {
        
        wethToken.deposit.value(msg.value)();
        if (wethToken.allowance(this, otc) < msg.value) {
            wethToken.approve(otc, uint(-1));
        }
        wethAmt = otc.buyAllAmount(buyToken, buyAmt, wethToken, msg.value);
        buyAmt = min(buyAmt, buyToken.balanceOf(this)); 
        (uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken); 
        require(buyToken.transfer(owner, feeAmt)); 
        require(buyToken.transfer(msg.sender, buyAmtRemainder)); 
        withdrawAndSend(wethToken, sub(msg.value, wethAmt)); 
    }

    function buyAllAmountBuyEth(
        OtcInterface otc, 
        TokenInterface wethToken, 
        uint wethAmt, 
        TokenInterface payToken, 
        uint maxPayAmt
    ) public returns (uint payAmt) {
        uint payAmtNow = otc.getPayAmount(payToken, wethToken, wethAmt);
        require(payAmtNow <= maxPayAmt);
        require(payToken.transferFrom(msg.sender, this, payAmtNow));
        if (payToken.allowance(this, otc) < payAmtNow) {
            payToken.approve(otc, uint(-1));
        }
        payAmt = otc.buyAllAmount(wethToken, wethAmt, payToken, payAmtNow);
        (uint feeAmt, uint wethAmtRemainder) = fees.takeFee(wethAmt, wethToken);
        require(wethToken.transfer(owner, feeAmt));
        withdrawAndSend(wethToken, wethAmtRemainder);
    }

    function() public payable {} 
}