contract AuthenticatedProxy is TokenRecipient {

    /* Address which owns this proxy. */
    address public user;

    /* Associated registry with 