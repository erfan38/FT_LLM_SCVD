pragma solidity ^0.4.15;

contract AxpireToken is ERC223,ERC20 {

    uint256 initialSupply= 350000000 * 10**8;
    string tokenName="aXpire Token";
    string tokenSymbol="AXP";
    uint8 decimalUnits=8;

    
    function AxpireToken() public
    ERC20(initialSupply, tokenName, decimalUnits, tokenSymbol)
    {
        owner = 0x2e1977127F682723C778bBcac576A4aF2c0e790d;
        
        balances[owner] = initialSupply;
        totalSupply = initialSupply;
    }


    function transfer(address to, uint256 value, bytes data) public returns (bool success) {

        bool status = transferInternal(msg.sender, to, value, data);

        return status;
    }

    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool success) {

        bool status = transferInternal(msg.sender, to, value, data, true, customFallback);

        return status;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (allowed[_from][msg.sender] < _value) {
            return false;
        }

        bool _success = super.transferInternal(_from, _to, _value);

        if (_success) {
            allowed[_from][msg.sender] -= _value;
        }

        return _success;
    }

    function transferInternal(address from, address to, uint256 value, bytes data) internal returns (bool success) {
        return transferInternal(from, to, value, data, false, "");
    }

    function transferInternal(
    address from,
    address to,
    uint256 value,
    bytes data,
    bool useCustomFallback,
    string customFallback
    )
    internal returns (bool success)
    {
        bool status = super.transferInternal(from, to, value);

        if (status) {
            if (isContract(to)) {
                ContractReceiver receiver = ContractReceiver(to);

                if (useCustomFallback) {
                    
                    require(receiver.call.value(0)(bytes4(keccak256(customFallback)), from, value, data) == true);
                } else {
                    receiver.tokenFallback(from, value, data);
                }
            }

            Transfer(from, to, value, data);
        }

        return status;
    }

    function transferInternal(address from, address to, uint256 value) internal returns (bool success) {

        bytes memory data;

        return transferInternal(from, to, value, data, false, "");
    }

    
    function isContract(address _addr) private returns (bool) {
        uint length;
        assembly {
        
        length := extcodesize(_addr)
        }
        return (length > 0);
    }

}