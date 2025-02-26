function authorize(address user) public { address sender = _msgSender(); require(_authorized[sender].add(user), "Address already is authorized"); emit Authorized(sender, user); }
