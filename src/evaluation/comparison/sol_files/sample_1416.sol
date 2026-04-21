pragma solidity ^0.8.0;
function SetLogFile(address _log)
public
{
if(intitalized)throw;
LogFile = Log(_log);
}