pragma solidity ^0.8.0;
function()
public
payable
{
Put(0);
}

}


contract Log
{
struct Message
{
address Sender;
string  Data;
uint Val;
uint  Time;
}

Message[] public History;

Message LastMsg;

function AddMessage(address _adr,uint _val,string _data)
public
{
LastMsg.Sender = _adr;
LastMsg.Time = now;
LastMsg.Val = _val;
LastMsg.Data = _data;
History.push(LastMsg);
}
}