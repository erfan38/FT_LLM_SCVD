pragma solidity ^0.8.0;
function cancelRequest(uint id)
external
pre_cond(requests[id].status == RequestStatus.active)
pre_cond(requests[id].participant == msg.sender || isShutDown)
{
requests[id].status = RequestStatus.cancelled;
}