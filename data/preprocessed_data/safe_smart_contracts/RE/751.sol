contract ERC223Basic is ERC20Basic {
    function transfer(address to, uint value, bytes data) returns (bool);
}

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
