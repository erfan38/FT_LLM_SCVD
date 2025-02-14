pragma solidity ^0.4.16;

contract OasisDirectProxy is DSMath {
    function withdrawAndSend(TokenInterface wethToken, uint wethAmt) internal {
        wethToken.withdraw(wethAmt);
        require(msg.sender.call.value(wethAmt)());
    }

    function sellAllAmount(OtcInterface otc, TokenInterface payToken, uint payAmt, TokenInterface buyToken, uint minBuyAmt) public returns (uint buyAmt) {
        require(payToken.transferFrom(msg.sender, this, payAmt));
        if (payToken.allowance(this, otc) < payAmt) {
            payToken.approve(otc, uint(-1));
        }
        buyAmt = otc.sellAllAmount(payToken, payAmt, buyToken, minBuyAmt);
        require(buyToken.transfer(msg.sender, buyAmt));
    }

    function sellAllAmountPayEth(OtcInterface otc, TokenInterface wethToken, TokenInterface buyToken, uint minBuyAmt) public payable returns (uint buyAmt) {
        wethToken.deposit.value(msg.value)();
        if (wethToken.allowance(this, otc) < msg.value) {
            wethToken.approve(otc, uint(-1));
        }
        buyAmt = otc.sellAllAmount(wethToken, msg.value, buyToken, minBuyAmt);
        require(buyToken.transfer(msg.sender, buyAmt));
    }

    function sellAllAmountBuyEth(OtcInterface otc, TokenInterface payToken, uint payAmt, TokenInterface wethToken, uint minBuyAmt) public returns (uint wethAmt) {
        require(payToken.transferFrom(msg.sender, this, payAmt));
        if (payToken.allowance(this, otc) < payAmt) {
            payToken.approve(otc, uint(-1));
        }
        wethAmt = otc.sellAllAmount(payToken, payAmt, wethToken, minBuyAmt);
        withdrawAndSend(wethToken, wethAmt);
    }

    function buyAllAmount(OtcInterface otc, TokenInterface buyToken, uint buyAmt, TokenInterface payToken, uint maxPayAmt) public returns (uint payAmt) {
        uint payAmtNow = otc.getPayAmount(payToken, buyToken, buyAmt);
        require(payAmtNow <= maxPayAmt);
        require(payToken.transferFrom(msg.sender, this, payAmtNow));
        if (payToken.allowance(this, otc) < payAmtNow) {
            payToken.approve(otc, uint(-1));
        }
        payAmt = otc.buyAllAmount(buyToken, buyAmt, payToken, payAmtNow);
        require(buyToken.transfer(msg.sender, min(buyAmt, buyToken.balanceOf(this)))); 
    }

    function buyAllAmountPayEth(OtcInterface otc, TokenInterface buyToken, uint buyAmt, TokenInterface wethToken) public payable returns (uint wethAmt) {
        
        wethToken.deposit.value(msg.value)();
        if (wethToken.allowance(this, otc) < msg.value) {
            wethToken.approve(otc, uint(-1));
        }
        wethAmt = otc.buyAllAmount(buyToken, buyAmt, wethToken, msg.value);
        require(buyToken.transfer(msg.sender, min(buyAmt, buyToken.balanceOf(this)))); 
        withdrawAndSend(wethToken, sub(msg.value, wethAmt));
    }

    function buyAllAmountBuyEth(OtcInterface otc, TokenInterface wethToken, uint wethAmt, TokenInterface payToken, uint maxPayAmt) public returns (uint payAmt) {
        uint payAmtNow = otc.getPayAmount(payToken, wethToken, wethAmt);
        require(payAmtNow <= maxPayAmt);
        require(payToken.transferFrom(msg.sender, this, payAmtNow));
        if (payToken.allowance(this, otc) < payAmtNow) {
            payToken.approve(otc, uint(-1));
        }
        payAmt = otc.buyAllAmount(wethToken, wethAmt, payToken, payAmtNow);
        withdrawAndSend(wethToken, wethAmt);
    }

    function() public payable {}
}