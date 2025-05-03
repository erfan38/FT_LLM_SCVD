contract EtherCityRank
{
    struct LINKNODE
    {
        uint256 count;
        uint256 leafLast;
    }

    struct LEAFNODE
    {
        address player;
        uint256 population;
        uint256 time;

        uint256 prev;
        uint256 next;
    }

    uint256 private constant LINK_NULL = uint256(-1);
    uint256 private constant LEAF_PER_LINK = 30;
    uint256 private constant LINK_COUNT = 10;
    uint256 private constant LINK_ENDIDX = LINK_COUNT - 1;

    mapping(uint256 => LINKNODE) private linkNodes;  
    mapping(uint256 => LEAFNODE) private leafNodes;
    uint256 private leafCount;

    address private owner;
    address private admin;
    address private city;
    
    constructor() public payable
    {
        owner = msg.sender;

        for(uint256 index = 1; index < LINK_COUNT; index++)
            linkNodes[index] = LINKNODE({count:0, leafLast:LINK_NULL});

         
        linkNodes[0] = LINKNODE({count:1, leafLast:0});
        leafNodes[0] = LEAFNODE({player:address(0), population:uint256(-1), time:0, prev:LINK_NULL, next:LINK_NULL});
        leafCount = 1;
    }

    function GetVersion() external pure returns(uint256)
    {
        return 1000;
    }

    function GetRank(uint16 rankidx) external view returns(address player, uint256 pop, uint256 time, uint256 nextidx)
    {
        uint256 leafidx;

        if (rankidx == 0)
            leafidx = leafNodes[0].next;
        else
            leafidx = rankidx;

        if (leafidx != LINK_NULL)
        {
            player = leafNodes[leafidx].player;
            pop = leafNodes[leafidx].population;
            time = leafNodes[leafidx].time;
            nextidx = leafNodes[leafidx].next;
        }
        else
        {
            player = address(0);
            pop = 0;
            time = 0;
            nextidx = 0;
        }
    }

    function UpdateRank(address player, uint256 pop_new, uint256 time_new) external
    {
        bool found;
        uint256 linkidx;
        uint256 leafidx;
        uint256 emptyidx;

        require(owner == msg.sender || admin == msg.sender || city == msg.sender);

        emptyidx = RemovePlayer(player);

        (found, linkidx, leafidx) = findIndex(pop_new, time_new);
        if (linkidx == LINK_NULL)
            return;

        if (linkNodes[LINK_ENDIDX].count == LEAF_PER_LINK)
        {    
            emptyidx = linkNodes[LINK_ENDIDX].leafLast;
            RemoveRank(LINK_ENDIDX, emptyidx);
        }
        else if (emptyidx == LINK_NULL)
        {
            emptyidx = leafCount;
            leafCount++;
        }

        leafNodes[emptyidx] = LEAFNODE({player:player, population:pop_new, time:time_new, prev:LINK_NULL, next:LINK_NULL});

         
        InsertRank(linkidx, leafidx, emptyidx);
    }

     
     
    function adminSetAdmin(address addr) external
    {
        require(owner == msg.sender);

        admin = addr;
    }

    function adminSetCity(address addr) external
    {
        require(owner == msg.sender || admin == msg.sender);

        city = addr;
    }

    function adminResetRank() external
    {
        require(owner == msg.sender || admin == msg.sender);

        for(uint256 index = 1; index < LINK_COUNT; index++)
            linkNodes[index] = LINKNODE({count:0, leafLast:LINK_NULL});

         
        linkNodes[0] = LINKNODE({count:1, leafLast:0});
        leafNodes[0] = LEAFNODE({player:address(0), population:uint256(-1), time:0, prev:LINK_NULL, next:LINK_NULL});
        leafCount = 1;
    }

     
     
    function findIndex(uint256 pop, uint256 time) private view returns(bool found, uint256 linkidx, uint256 leafidx)
    {
        uint256 comp;

        found = false;

        for(linkidx = 0; linkidx < LINK_COUNT; linkidx++)
        {
            LINKNODE storage lknode = linkNodes[linkidx];
            if (lknode.count < LEAF_PER_LINK)
                break;

            LEAFNODE storage lfnode = leafNodes[lknode.leafLast];
            if ((compareLeaf(pop, time, lfnode.population, lfnode.time) >= 1))
                break;
        }

        if (linkidx == LINK_COUNT)
        {
            linkidx = (linkNodes[LINK_ENDIDX].count < LEAF_PER_LINK) ? LINK_ENDIDX : LINK_NULL;
            leafidx = LINK_NULL;
            return;
        }
            
        leafidx = lknode.leafLast;
        for(uint256 index = 0; index < lknode.count; index++)
        {
            lfnode = leafNodes[leafidx];
            comp = compareLeaf(pop, time, lfnode.population, lfnode.time);
            if (comp == 0)   
            {
                leafidx = lfnode.next;
                break;
            }
            else if (comp == 1)  
            {
                found = true;
                break;
            }

            if (index + 1 < lknode.count)
                leafidx = lfnode.prev;
        }
    }
    
    function InsertRank(uint256 linkidx, uint256 leafidx_before, uint256 leafidx_new) private
    {
        uint256 leafOnLink;
        uint256 leafLast;

        if (leafidx_before == LINK_NULL)
        {    
            leafLast = linkNodes[linkidx].leafLast;
            if (leafLast != LINK_NULL)
                ConnectLeaf(leafidx_new, leafNodes[leafLast].next);
            else
                leafNodes[leafidx_new].next = LINK_NULL;

            ConnectLeaf(leafLast, leafidx_new);
            linkNodes[linkidx].leafLast = leafidx_new;
            linkNodes[linkidx].count++;
            return;
        }

        ConnectLeaf(leafNodes[leafidx_before].prev, leafidx_new);
        ConnectLeaf(leafidx_new, leafidx_before);

        leafLast = LINK_NULL;
        for(uint256 index = linkidx; index < LINK_COUNT; index++)
        {
            leafOnLink = linkNodes[index].count;
            if (leafOnLink < LEAF_PER_LINK)
            {
                if (leafOnLink == 0)  
                    linkNodes[index].leafLast = leafLast;

                linkNodes[index].count++;
                break;
            }

            leafLast = linkNodes[index].leafLast;
            linkNodes[index].leafLast = leafNodes[leafLast].prev;
        }
    }

    function RemoveRank(uint256 linkidx, uint256 leafidx) private
    {
        uint256 next;

        for(uint256 index = linkidx; index < LINK_COUNT; index++)
        {
            LINKNODE storage link = linkNodes[index];
            
            next = leafNodes[link.leafLast].next;
            if (next == LINK_NULL)
            {
                link.count--;
                if (link.count == 0)
                    link.leafLast = LINK_NULL;
                break;
            }
            else
                link.leafLast = next;
        }

        LEAFNODE storage leaf_cur = leafNodes[leafidx];
        if (linkNodes[linkidx].leafLast == leafidx)
            linkNodes[linkidx].leafLast = leaf_cur.prev;

        ConnectLeaf(leaf_cur.prev, leaf_cur.next);
    }

    function RemovePlayer(address player) private returns(uint256 leafidx)
    {
        for(uint256 linkidx = 0; linkidx < LINK_COUNT; linkidx++)
        {
            LINKNODE storage lknode = linkNodes[linkidx];

            leafidx = lknode.leafLast;
            for(uint256 index = 0; index < lknode.count; index++)
            {
                LEAFNODE storage lfnode = leafNodes[leafidx];

                if (lfnode.player == player)
                {
                    RemoveRank(linkidx, leafidx);
                    return;
                }

                leafidx = lfnode.prev;
            }
        }

        return LINK_NULL;
    }

    function ConnectLeaf(uint256 leafprev, uint256 leafnext) private
    {
        if (leafprev != LINK_NULL)
            leafNodes[leafprev].next = leafnext;

        if (leafnext != LINK_NULL)
            leafNodes[leafnext].prev = leafprev;
    }

    function compareLeaf(uint256 pop1, uint256 time1, uint256 pop2, uint256 time2) private pure returns(uint256)
    {
        if (pop1 > pop2)
            return 2;
        else if (pop1 < pop2)
            return 0;

        if (time1 > time2)
            return 2;
        else if (time1 < time2)
            return 0;

        return 1;
    }
}

