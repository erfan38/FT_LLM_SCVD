pragma solidity ^0.8.0;
contract RegistryExec is ScriptExec {

struct Registry {
address index;
address implementation;
}


mapping (bytes32 => Registry) public registry_instance_info;

mapping (address => Registry[]) public deployed_registry_instances;



event RegistryInstanceCreated(address indexed creator, bytes32 indexed execution_id, address index, address implementation);



bytes4 internal constant EXEC_SEL = bytes4(keccak256('exec(address,bytes32,bytes)'));








function exec(bytes32 _exec_id, bytes _calldata) external payable returns (bool success) {

bytes4 sel = getSelector(_calldata);

require(
sel != this.registerApp.selector &&
sel != this.registerAppVersion.selector &&
sel != UPDATE_INST_SEL &&
sel != UPDATE_EXEC_SEL
);


if (address(app_storage).call.value(msg.value)(abi.encodeWithSelector(
EXEC_SEL, msg.sender, _exec_id, _calldata
)) == false) {

checkErrors(_exec_id);

address(msg.sender).transfer(address(this).balance);
return false;
}


success = checkReturn();

require(success, 'Execution failed');


address(msg.sender).transfer(address(this).balance);
}