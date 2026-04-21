contract ScriptExec {

  /// DEFAULT VALUES ///

  address public app_storage;
  address public provider;
  bytes32 public registry_exec_id;
  address public exec_admin;

  /// APPLICATION INSTANCE METADATA ///

  struct Instance {
    address current_provider;
    bytes32 current_registry_exec_id;
    bytes32 app_exec_id;
    bytes32 app_name;
    bytes32 version_name;
  }

  // Maps the execution ids of deployed instances to the address that deployed them -
  mapping (bytes32 => address) public deployed_by;
  // Maps the execution ids of deployed instances to a struct containing their metadata -
  mapping (bytes32 => Instance) public instance_info;
  // Maps an address that deployed app instances to metadata about the deployed instance -
  mapping (address => Instance[]) public deployed_instances;
  // Maps an application name to the exec ids under which it is deployed -
  mapping (bytes32 => bytes32[]) public app_instances;

  /// EVENTS ///

  event AppInstanceCreated(address indexed creator, bytes32 indexed execution_id, bytes32 app_name, bytes32 version_name);
  event StorageException(bytes32 indexed execution_id, string message);

  // Modifier - The sender must be the 