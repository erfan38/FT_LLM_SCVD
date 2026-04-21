pragma solidity ^0.8.0;
function getConfirmationCount(uint transactionId)
public
constant
returns (uint count)
{
for (uint i=0; i<owners.length; i++)
if (confirmations[transactionId][owners[i]])
count += 1;
}