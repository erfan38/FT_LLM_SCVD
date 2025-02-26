function revokeVotesFrom(address wallet_, uint256 amount_) external onlyRole("voter_admin") { VOTES.burnFrom(wallet_, amount_); }
