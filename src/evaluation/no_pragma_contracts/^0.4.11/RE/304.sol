contract ERC827 {

    function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
    function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
    function transferFrom(
        address _from,
        address _to,
        uint256 _value,
        bytes _data
    ) public returns (bool);

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
