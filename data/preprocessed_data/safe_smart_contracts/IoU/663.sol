contract CustomToken is BaseToken {
    function CustomToken() public {
        totalSupply = 260000000000000000;
        name = 'Wisdom Agriculture Chain (»ÛÅ©Á´)';
        symbol = 'WAC';
        decimals = 10;
        balanceOf[0x5ebc4B61A0E0187d9a72Da21bfb8b45F519cb530] = totalSupply;
        Transfer(address(0), 0x5ebc4B61A0E0187d9a72Da21bfb8b45F519cb530, totalSupply);
    }
}