pragma solidity ^0.8.0;
bytes4 internal constant UPDATE_INST_SEL = bytes4(keccak256('updateInstance(bytes32,bytes32,bytes32)'));








function updateAppInstance(bytes32 _exec_id) external returns (bool success) {

require(_exec_id != 0 && msg.sender == deployed_by[_exec_id], 'invalid sender or input');


Instance memory inst = instance_info[_exec_id];



if(address(app_storage).call(
abi.encodeWithSelector(EXEC_SEL,
inst.current_provider,
_exec_id,
abi.encodeWithSelector(UPDATE_INST_SEL,
inst.app_name,
inst.version_name,
inst.current_registry_exec_id
)
)
) == false) {

checkErrors(_exec_id);
return false;
}

success = checkReturn();

require(success, 'Execution failed');



address registry_idx = StorageInterface(app_storage).getIndex(inst.current_registry_exec_id);
bytes32 latest_version  = RegistryInterface(registry_idx).getLatestVersion(
app_storage,
inst.current_registry_exec_id,
inst.current_provider,
inst.app_name
);

require(latest_version != 0, 'invalid latest version');

instance_info[_exec_id].version_name = latest_version;
}