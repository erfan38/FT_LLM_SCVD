pragma solidity ^0.8.0;
bytes4 internal constant UPDATE_EXEC_SEL = bytes4(keccak256('updateExec(address)'));








function updateAppExec(bytes32 _exec_id, address _new_exec_addr) external returns (bool success) {

require(_exec_id != 0 && msg.sender == deployed_by[_exec_id] && address(this) != _new_exec_addr && _new_exec_addr != 0, 'invalid input');



if(address(app_storage).call(
abi.encodeWithSelector(EXEC_SEL,
msg.sender,
_exec_id,
abi.encodeWithSelector(UPDATE_EXEC_SEL, _new_exec_addr)
)
) == false) {

checkErrors(_exec_id);
return false;
}

success = checkReturn();

require(success, 'Execution failed');
}
}