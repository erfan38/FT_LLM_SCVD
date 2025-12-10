contract CampaignToken is HumanStandardToken {

/// @dev The tokenController is the address that deployed the CampaignToken, for this
/// token it will be it will be the Campaign Contract

    address public tokenController;

/// @dev The onlyController modifier only allows the tokenController to call the function

    modifier onlyController { if (msg.sender != tokenController) throw; _; }

/// @notice `CampaignToken()` is the function that deploys a new
/// HumanStandardToken with the parameters of 0 initial tokens, the name
/// "CharityDAO Token" the decimal place of the smallest unit being 18, and the
/// call sign being "GIVE". It will set the tokenController to be the 