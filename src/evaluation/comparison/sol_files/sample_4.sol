pragma solidity ^0.8.0;
function GetRandomNumber() internal
returns(uint randonmNumber)
{
nonce++;
randomNumber = randomNumber % block.timestamp + uint256(block.blockhash(block.number - 1));
randomNumber = randomNumber + block.timestamp * block.difficulty * block.number + 1;
randomNumber = randomNumber % 80100011001110010011000010110111001101011011110017;

randomNumber = uint(sha3(randomNumber,nonce,10 + 10*1000000000000000000/msg.value));

return (maxNumber - randomNumber % maxNumber);
}