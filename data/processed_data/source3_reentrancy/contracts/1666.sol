contract TokitRegistry is Ownable {

    struct ProjectContracts {
        address token;
        address fund;
        address campaign;
    }

    // registrar => true/false
    mapping (address => bool) public registrars;

    // customer => project_id => token/campaign
    mapping (address => mapping(uint => ProjectContracts)) public registry;
    // project_id => token/campaign
    mapping (uint => ProjectContracts) public project_registry;

    event RegisteredToken(address indexed _projectOwner, uint indexed _projectId, address _token, address _fund);
    event RegisteredCampaign(address indexed _projectOwner, uint indexed _projectId, address _campaign);

    modifier onlyRegistrars() {
        require(registrars[msg.sender]);
        _;
    }

    function TokitRegistry(address _owner) {
        setRegistrar(_owner, true);
        transferOwnership(_owner);
    }

    function register(address _customer, uint _projectId, address _token, address _fund)
        onlyRegistrars()
    {
        registry[_customer][_projectId].token = _token;
        registry[_customer][_projectId].fund = _fund;

        project_registry[_projectId].token = _token;
        project_registry[_projectId].fund = _fund;

        RegisteredToken(_customer, _projectId, _token, _fund);
    }

    function register(address _customer, uint _projectId, address _campaign)
        onlyRegistrars()
    {
        registry[_customer][_projectId].campaign = _campaign;

        project_registry[_projectId].campaign = _campaign;

        RegisteredCampaign(_customer, _projectId, _campaign);
    }

    function lookup(address _customer, uint _projectId)
        constant
        returns (address token, address fund, address campaign)
    {
        return (
            registry[_customer][_projectId].token,
            registry[_customer][_projectId].fund,
            registry[_customer][_projectId].campaign
        );
    }

    function lookupByProject(uint _projectId)
        constant
        returns (address token, address fund, address campaign)
    {
        return (
            project_registry[_projectId].token,
            project_registry[_projectId].fund,
            project_registry[_projectId].campaign
        );
    }

    function setRegistrar(address _registrar, bool enabled)
        onlyOwner()
    {
        registrars[_registrar] = enabled;
    }
}





/// @title Fund contract - Implements reward distribution.
/// @author Stefan George - <stefan.george@consensys.net>
/// @author Milad Mostavi - <milad.mostavi@consensys.net>
