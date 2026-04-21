pragma solidity ^0.4.19;

contract RipioOracle is Oracle, Delegable {
    uint256 public expiration = 15 minutes;

    uint constant private INDEX_TIMESTAMP = 0;
    uint constant private INDEX_RATE = 1;
    uint constant private INDEX_DECIMALS = 2;
    uint constant private INDEX_V = 3;
    uint constant private INDEX_R = 4;
    uint constant private INDEX_S = 5;

    string private infoUrl;

    mapping(bytes32 => RateCache) private cache;

    address public fallback;

    struct RateCache {
        uint256 timestamp;
        uint256 rate;
        uint256 decimals;
    }

    function url() public view returns (string) {
        return infoUrl;
    }

    






    function setExpirationTime(uint256 time) public onlyOwner returns (bool) {
        expiration = time;
        return true;
    }

    






    function setUrl(string _url) public onlyOwner returns (bool) {
        infoUrl = _url;
        return true;
    }

    









    function setFallback(address _fallback) public onlyOwner returns (bool) {
        fallback = _fallback;
        return true;
    }

    







    function readBytes32(bytes data, uint256 index) internal pure returns (bytes32 o) {
        if(data.length / 32 > index) {
            assembly {
                o := mload(add(data, add(32, mul(32, index))))
            }
        }
    }

    










    function sendTransaction(address to, uint256 value, bytes data) public onlyOwner returns (bool) {
        return to.call.value(value)(data);
    }


    










    function getRate(bytes32 currency, bytes data) public returns (uint256, uint256) {
        if (fallback != address(0)) {
            return Oracle(fallback).getRate(currency, data);
        }

        uint256 timestamp = uint256(readBytes32(data, INDEX_TIMESTAMP));
        require(timestamp <= block.timestamp);

        uint256 expirationTime = block.timestamp - expiration;

        if (cache[currency].timestamp >= timestamp && cache[currency].timestamp >= expirationTime) {
            return (cache[currency].rate, cache[currency].decimals);
        } else {
            require(timestamp >= expirationTime);
            uint256 rate = uint256(readBytes32(data, INDEX_RATE));
            uint256 decimals = uint256(readBytes32(data, INDEX_DECIMALS));
            uint8 v = uint8(readBytes32(data, INDEX_V));
            bytes32 r = readBytes32(data, INDEX_R);
            bytes32 s = readBytes32(data, INDEX_S);
            
            bytes32 _hash = keccak256(this, currency, rate, decimals, timestamp);
            address signer = ecrecover(keccak256("\x19Ethereum Signed Message:\n32", _hash),v,r,s);

            require(isDelegate(signer));

            cache[currency] = RateCache(timestamp, rate, decimals);

            return (rate, decimals);
        }
    }
}