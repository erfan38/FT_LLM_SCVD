pragma solidity ^0.4.23;

interface StorageInterface {
function getTarget(bytes32 exec_id, bytes4 selector)
external view returns (address implementation);
function getIndex(bytes32 exec_id) external view returns (address index);
function createInstance(address sender, bytes32 app_name, address provider, bytes32 registry_exec_id, bytes calldata)
external payable returns (bytes32 instance_exec_id, bytes32 version);
function createRegistry(address index, address implementation) external returns (bytes32 exec_id);
function exec(address sender, bytes32 exec_id, bytes calldata)
external payable returns (uint emitted, uint paid, uint stored);
}

interface RegistryInterface {
function getLatestVersion(address stor_addr, bytes32 exec_id, address provider, bytes32 app_name)
external view returns (bytes32 latest_name);
function getVersionImplementation(address stor_addr, bytes32 exec_id, address provider, bytes32 app_name, bytes32 version_name)
external view returns (address index, bytes4[] selectors, address[] implementations);
}