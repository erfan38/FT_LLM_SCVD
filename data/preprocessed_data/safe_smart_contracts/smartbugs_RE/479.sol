contract BalanceCheckerN {

    address public admin;

    constructor() {
        admin = 0x96670A91E1A0dbAde97fCDC0ABdDEe769C21fc8e;
    }

    //default function, don't accept any ETH
    function() public payable {
        revert();
    }

    //limit address to the creating address
    modifier isAdmin() {
        require(msg.sender == admin);
         _;
    }

    // selfdestruct for cleanup
    function destruct() public isAdmin {
        selfdestruct(admin);
    }

    // backup withdraw, if somehow ETH gets in here
    function withdraw() public isAdmin {
        admin.transfer(address(this).balance);
    }

    // backup withdraw, if somehow ERC20 tokens get in here
    function withdrawToken(address token, uint amount) public isAdmin {
        require(token != address(0x0)); //use withdraw for ETH
        require(Token(token).transfer(msg.sender, amount));
    }

  /* Check the token allowance of a wallet in a token 