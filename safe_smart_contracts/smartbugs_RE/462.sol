contract RegistryExec is ScriptExec {

  struct Registry {
    address index;
    address implementation;
  }

  // Maps execution ids to its registry app metadata
  mapping (bytes32 => Registry) public registry_instance_info;
  // Maps address to list of deployed Registry instances
  mapping (address => Registry[]) public deployed_registry_instances;

  /// EVENTS ///

  event RegistryInstanceCreated(address indexed creator, bytes32 indexed execution_id, address index, address implementation);

  /// APPLICATION EXECUTION ///

  bytes4 internal constant EXEC_SEL = bytes4(keccak256('exec(address,bytes32,bytes)'));

  /*
  Executes an application using its execution id and storage address.

  @param _exec_id: The instance exec id, which will route the calldata to the appropriate destination
  @param _calldata: The calldata to forward to the application
  @return success: Whether execution succeeded or not
  */
  function exec(bytes32 _exec_id, bytes _calldata) external payable returns (bool success) {
    // Get function selector from calldata -
    bytes4 sel = getSelector(_calldata);
    // Ensure no registry functions are being called -
    require(
      sel != this.registerApp.selector &&
      sel != this.registerAppVersion.selector &&
      sel != UPDATE_INST_SEL &&
      sel != UPDATE_EXEC_SEL
    );

    // Call 'exec' in AbstractStorage, passing in the sender's address, the app exec id, and the calldata to forward -
    if (address(app_storage).call.value(msg.value)(abi.encodeWithSelector(
      EXEC_SEL, msg.sender, _exec_id, _calldata
    )) == false) {
      // Call failed - emit error message from storage and return 'false'
      checkErrors(_exec_id);
      // Return unspent wei to sender
      address(msg.sender).transfer(address(this).balance);
      return false;
    }

    // Get returned data
    success = checkReturn();
    // If execution failed,
    require(success, 'Execution failed');

    // Transfer any returned wei back to the sender
    address(msg.sender).transfer(address(this).balance);
  }

  // Returns the first 4 bytes of calldata
  function getSelector(bytes memory _calldata) internal pure returns (bytes4 selector) {
    assembly {
      selector := and(
        mload(add(0x20, _calldata)),
        0xffffffff00000000000000000000000000000000000000000000000000000000
      )
    }
  }

  /// REGISTRY FUNCTIONS ///

  /*
  Creates an instance of a registry application and returns its execution id
  @param _index: The index file of the registry app (holds getters and init functions)
  @param _implementation: The file implementing the registry's functionality
  @return exec_id: The execution id under which the registry will store data
  */
  function createRegistryInstance(address _index, address _implementation) external onlyAdmin() returns (bytes32 exec_id) {
    // Validate input -
    require(_index != 0 && _implementation != 0, 'Invalid input');

    // Creates a registry from storage and returns the registry exec id -
    exec_id = StorageInterface(app_storage).createRegistry(_index, _implementation);

    // Ensure a valid execution id returned from storage -
    require(exec_id != 0, 'Invalid response from storage');

    // If there is not already a default registry exec id set, set it
    if (registry_exec_id == 0)
      registry_exec_id = exec_id;

    // Create Registry struct in memory -
    Registry memory reg = Registry(_index, _implementation);

    // Set various app metadata values -
    deployed_by[exec_id] = msg.sender;
    registry_instance_info[exec_id] = reg;
    deployed_registry_instances[msg.sender].push(reg);
    // Emit event -
    emit RegistryInstanceCreated(msg.sender, exec_id, _index, _implementation);
  }

  /*
  Registers an application as the admin under the provider and registry exec id
  @param _app_name: The name of the application to register
  @param _index: The index file of the application - holds the getters and init functions
  @param _selectors: The selectors of the functions which the app implements
  @param _implementations: The addresses at which each function is located
  */
  function registerApp(bytes32 _app_name, address _index, bytes4[] _selectors, address[] _implementations) external onlyAdmin() {
    // Validate input
    require(_app_name != 0 && _index != 0, 'Invalid input');
    require(_selectors.length == _implementations.length && _selectors.length != 0, 'Invalid input');
    // Check 