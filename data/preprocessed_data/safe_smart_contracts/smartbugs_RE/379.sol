pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IGST2 {

    function freeUpTo(uint256 value) external returns (uint256 freed);

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

    function balanceOf(address who) external view returns (uint256);
}


contract CompressedCaller {

    function compressedCall(
        address target,
        uint256 totalLength,
        bytes memory zipped
    )
        public
        payable
        returns (bytes memory result)
    {
        (bytes memory data, uint decompressedLength) = decompress(totalLength, zipped);
        require(decompressedLength == totalLength, "Uncompress error");

        bool success;
        (success, result) = target.call.value(msg.value)(data);
        require(success, "Decompressed call failed");
    }

    function decompress(
        uint256 totalLength,
        bytes memory zipped
    )
        public
        pure
        returns (
            bytes memory data,
            uint256 index
        )
    {
        data = new bytes(totalLength);

        for (uint i = 0; i < zipped.length; i++) {

            uint len = uint(uint8(zipped[i]) & 0x7F);

            if ((zipped[i] & 0x80) == 0) {
                memcpy(data, index, zipped, i + 1, len);
                i += len;
            }

            index += len;
        }
    }

    
    
    
    
    function memcpy(
        bytes memory destMem,
        uint dest,
        bytes memory srcMem,
        uint src,
        uint len
    )
        private
        pure
    {
        uint mask = 256 ** (32 - len % 32) - 1;

        assembly {
            dest := add(add(destMem, 32), dest)
            src := add(add(srcMem, 32), src)

            
            for { } gt(len, 31) { len := sub(len, 32) } { 
                mstore(dest, mload(src))
                dest := add(dest, 32)
                src := add(src, 32)
            }

            
            let srcPart := and(mload(src), not(mask))
            let destPart := and(mload(dest), mask)
            mstore(dest, or(destPart, srcPart))
        }
    }
}






interface IERC20 {
    


    function totalSupply() external view returns (uint256);

    


    function balanceOf(address account) external view returns (uint256);

    






    function transfer(address recipient, uint256 amount) external returns (bool);

    






    function allowance(address owner, address spender) external view returns (uint256);

    













    function approve(address spender, uint256 amount) external returns (bool);

    








    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    





    event Transfer(address indexed from, address indexed to, uint256 value);

    



    event Approval(address indexed owner, address indexed spender, uint256 value);
}















library SafeMath {
    








    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    








    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    








    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    










    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    










    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}





library Address {
    









    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}










