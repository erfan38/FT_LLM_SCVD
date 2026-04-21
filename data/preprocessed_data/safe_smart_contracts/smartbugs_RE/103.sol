pragma solidity ^0.4.24;









library ECRecovery {

  




  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (sig.length != 65) {
      return (address(0));
    }

    
    
    
    
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    
    if (v < 27) {
      v += 27;
    }

    
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      
      return ecrecover(hash, v, r, s);
    }
  }

  




  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    
    
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}


library OrderStatisticTree {

    struct Node {
        mapping (bool => uint) children; 
        uint parent; 
        bool side;   
        uint height; 
        uint count; 
        uint dupes; 
    }

    struct Tree {
        
        
        
        
        mapping(uint => Node) nodes;
    }
    







    function rank(Tree storage _tree,uint _value) internal view returns (uint smaller) {
        if (_value != 0) {
            smaller = _tree.nodes[0].dupes;

            uint cur = _tree.nodes[0].children[true];
            Node storage currentNode = _tree.nodes[cur];

            while (true) {
                if (cur <= _value) {
                    if (cur<_value) {
                        smaller = smaller + 1+currentNode.dupes;
                    }
                    uint leftChild = currentNode.children[false];
                    if (leftChild!=0) {
                        smaller = smaller + _tree.nodes[leftChild].count;
                    }
                }
                if (cur == _value) {
                    break;
                }
                cur = currentNode.children[cur<_value];
                if (cur == 0) {
                    break;
                }
                currentNode = _tree.nodes[cur];
            }
        }
    }

    function count(Tree storage _tree) internal view returns (uint) {
        Node storage root = _tree.nodes[0];
        Node memory child = _tree.nodes[root.children[true]];
        return root.dupes+child.count;
    }

    function updateCount(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        n.count = 1+_tree.nodes[n.children[false]].count+_tree.nodes[n.children[true]].count+n.dupes;
    }

    function updateCounts(Tree storage _tree,uint _value) private {
        uint parent = _tree.nodes[_value].parent;
        while (parent!=0) {
            updateCount(_tree,parent);
            parent = _tree.nodes[parent].parent;
        }
    }

    function updateHeight(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        uint heightLeft = _tree.nodes[n.children[false]].height;
        uint heightRight = _tree.nodes[n.children[true]].height;
        if (heightLeft > heightRight)
            n.height = heightLeft+1;
        else
            n.height = heightRight+1;
    }

    function balanceFactor(Tree storage _tree,uint _value) private view returns (int bf) {
        Node storage n = _tree.nodes[_value];
        return int(_tree.nodes[n.children[false]].height)-int(_tree.nodes[n.children[true]].height);
    }

    function rotate(Tree storage _tree,uint _value,bool dir) private {
        bool otherDir = !dir;
        Node storage n = _tree.nodes[_value];
        bool side = n.side;
        uint parent = n.parent;
        uint valueNew = n.children[otherDir];
        Node storage nNew = _tree.nodes[valueNew];
        uint orphan = nNew.children[dir];
        Node storage p = _tree.nodes[parent];
        Node storage o = _tree.nodes[orphan];
        p.children[side] = valueNew;
        nNew.side = side;
        nNew.parent = parent;
        nNew.children[dir] = _value;
        n.parent = valueNew;
        n.side = dir;
        n.children[otherDir] = orphan;
        o.parent = _value;
        o.side = otherDir;
        updateHeight(_tree,_value);
        updateHeight(_tree,valueNew);
        updateCount(_tree,_value);
        updateCount(_tree,valueNew);
    }

    function rebalanceInsert(Tree storage _tree,uint _nValue) private {
        updateHeight(_tree,_nValue);
        Node storage n = _tree.nodes[_nValue];
        uint pValue = n.parent;
        if (pValue!=0) {
            int pBf = balanceFactor(_tree,pValue);
            bool side = n.side;
            int sign;
            if (side)
                sign = -1;
            else
                sign = 1;
            if (pBf == sign*2) {
                if (balanceFactor(_tree,_nValue) == (-1 * sign)) {
                    rotate(_tree,_nValue,side);
                }
                rotate(_tree,pValue,!side);
            } else if (pBf != 0) {
                rebalanceInsert(_tree,pValue);
            }
        }
    }

    function rebalanceDelete(Tree storage _tree,uint _pValue,bool side) private {
        if (_pValue!=0) {
            updateHeight(_tree,_pValue);
            int pBf = balanceFactor(_tree,_pValue);
            int sign;
            if (side)
                sign = 1;
            else
                sign = -1;
            int bf = balanceFactor(_tree,_pValue);
            if (bf==(2*sign)) {
                Node storage p = _tree.nodes[_pValue];
                uint sValue = p.children[!side];
                int sBf = balanceFactor(_tree,sValue);
                if (sBf == (-1 * sign)) {
                    rotate(_tree,sValue,!side);
                }
                rotate(_tree,_pValue,side);
                if (sBf!=0) {
                    p = _tree.nodes[_pValue];
                    rebalanceDelete(_tree,p.parent,p.side);
                }
            } else if (pBf != sign) {
                p = _tree.nodes[_pValue];
                rebalanceDelete(_tree,p.parent,p.side);
            }
        }
    }

    function fixParents(Tree storage _tree,uint parent,bool side) private {
        if (parent!=0) {
            updateCount(_tree,parent);
            updateCounts(_tree,parent);
            rebalanceDelete(_tree,parent,side);
        }
    }

    function insertHelper(Tree storage _tree,uint _pValue,bool _side,uint _value) private {
        Node storage root = _tree.nodes[_pValue];
        uint cValue = root.children[_side];
        if (cValue==0) {
            root.children[_side] = _value;
            Node storage child = _tree.nodes[_value];
            child.parent = _pValue;
            child.side = _side;
            child.height = 1;
            child.count = 1;
            updateCounts(_tree,_value);
            rebalanceInsert(_tree,_value);
        } else if (cValue==_value) {
            _tree.nodes[cValue].dupes++;
            updateCount(_tree,_value);
            updateCounts(_tree,_value);
        } else {
            insertHelper(_tree,cValue,(_value >= cValue),_value);
        }
    }

    function insert(Tree storage _tree,uint _value) internal {
        if (_value==0) {
            _tree.nodes[_value].dupes++;
        } else {
            insertHelper(_tree,0,true,_value);
        }
    }

    function rightmostLeaf(Tree storage _tree,uint _value) private view returns (uint leaf) {
        uint child = _tree.nodes[_value].children[true];
        if (child!=0) {
            return rightmostLeaf(_tree,child);
        } else {
            return _value;
        }
    }

    function zeroOut(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        n.parent = 0;
        n.side = false;
        n.children[false] = 0;
        n.children[true] = 0;
        n.count = 0;
        n.height = 0;
        n.dupes = 0;
    }

    function removeBranch(Tree storage _tree,uint _value,uint _left) private {
        uint ipn = rightmostLeaf(_tree,_left);
        Node storage i = _tree.nodes[ipn];
        uint dupes = i.dupes;
        removeHelper(_tree,ipn);
        Node storage n = _tree.nodes[_value];
        uint parent = n.parent;
        Node storage p = _tree.nodes[parent];
        uint height = n.height;
        bool side = n.side;
        uint ncount = n.count;
        uint right = n.children[true];
        uint left = n.children[false];
        p.children[side] = ipn;
        i.parent = parent;
        i.side = side;
        i.count = ncount+dupes-n.dupes;
        i.height = height;
        i.dupes = dupes;
        if (left!=0) {
            i.children[false] = left;
            _tree.nodes[left].parent = ipn;
        }
        if (right!=0) {
            i.children[true] = right;
            _tree.nodes[right].parent = ipn;
        }
        zeroOut(_tree,_value);
        updateCounts(_tree,ipn);
    }

    function removeHelper(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        uint parent = n.parent;
        bool side = n.side;
        Node storage p = _tree.nodes[parent];
        uint left = n.children[false];
        uint right = n.children[true];
        if ((left == 0) && (right == 0)) {
            p.children[side] = 0;
            zeroOut(_tree,_value);
            fixParents(_tree,parent,side);
        } else if ((left != 0) && (right != 0)) {
            removeBranch(_tree,_value,left);
        } else {
            uint child = left+right;
            Node storage c = _tree.nodes[child];
            p.children[side] = child;
            c.parent = parent;
            c.side = side;
            zeroOut(_tree,_value);
            fixParents(_tree,parent,side);
        }
    }

    function remove(Tree storage _tree,uint _value) internal {
        Node storage n = _tree.nodes[_value];
        if (_value==0) {
            if (n.dupes==0) {
                return;
            }
        } else {
            if (n.count==0) {
                return;
            }
        }
        if (n.dupes>0) {
            n.dupes--;
            if (_value!=0) {
                n.count--;
            }
            fixParents(_tree,n.parent,n.side);
        } else {
            removeHelper(_tree,_value);
        }
    }

}


















library RealMath {

    


    int256 constant REAL_BITS = 256;

    


    int256 constant REAL_FBITS = 40;

    


    int256 constant REAL_IBITS = REAL_BITS - REAL_FBITS;

    


    int256 constant REAL_ONE = int256(1) << REAL_FBITS;

    


    int256 constant REAL_HALF = REAL_ONE >> 1;

    


    int256 constant REAL_TWO = REAL_ONE << 1;

    


    int256 constant REAL_LN_TWO = 762123384786;

    


    int256 constant REAL_PI = 3454217652358;

    



    int256 constant REAL_HALF_PI = 1727108826179;

    


    int256 constant REAL_TWO_PI = 6908435304715;

    


    int256 constant SIGN_MASK = int256(1) << 255;


    


    function toReal(int216 ipart) internal pure returns (int256) {
        return int256(ipart) * REAL_ONE;
    }

    


    function fromReal(int256 realValue) internal pure returns (int216) {
        return int216(realValue / REAL_ONE);
    }

    


    function round(int256 realValue) internal pure returns (int256) {
        
        int216 ipart = fromReal(realValue);
        if ((fractionalBits(realValue) & (uint40(1) << (REAL_FBITS - 1))) > 0) {
            
            if (realValue < int256(0)) {
                
                ipart -= 1;
            } else {
                ipart += 1;
            }
        }
        return toReal(ipart);
    }

    


    function abs(int256 realValue) internal pure returns (int256) {
        if (realValue > 0) {
            return realValue;
        } else {
            return -realValue;
        }
    }

    


    function fractionalBits(int256 realValue) internal pure returns (uint40) {
        return uint40(abs(realValue) % REAL_ONE);
    }

    


    function fpart(int256 realValue) internal pure returns (int256) {
        
        return abs(realValue) % REAL_ONE;
    }

    


    function fpartSigned(int256 realValue) internal pure returns (int256) {
        
        int256 fractional = fpart(realValue);
        if (realValue < 0) {
            
            return -fractional;
        } else {
            return fractional;
        }
    }

    


    function ipart(int256 realValue) internal pure returns (int256) {
        
        return realValue - fpartSigned(realValue);
    }

    


    function mul(int256 realA, int256 realB) internal pure returns (int256) {
        
        
        return int256((int256(realA) * int256(realB)) >> REAL_FBITS);
    }

    


    function div(int256 realNumerator, int256 realDenominator) internal pure returns (int256) {
        
        
        return int256((int256(realNumerator) * REAL_ONE) / int256(realDenominator));
    }

    


    function fraction(int216 numerator, int216 denominator) internal pure returns (int256) {
        return div(toReal(numerator), toReal(denominator));
    }

    
    
    

    



    function ipow(int256 realBase, int216 exponent) internal pure returns (int256) {
        if (exponent < 0) {
            
            revert();
        }

        int256 tempRealBase = realBase;
        int256 tempExponent = exponent;

        
        int256 realResult = REAL_ONE;
        while (tempExponent != 0) {
            
            if ((tempExponent & 0x1) == 0x1) {
                
                realResult = mul(realResult, tempRealBase);
            }
            
            tempExponent = tempExponent >> 1;
            
            tempRealBase = mul(tempRealBase, tempRealBase);
        }

        
        return realResult;
    }

    



    function hibit(uint256 _val) internal pure returns (uint256) {
        
        uint256 val = _val;
        val |= (val >> 1);
        val |= (val >> 2);
        val |= (val >> 4);
        val |= (val >> 8);
        val |= (val >> 16);
        val |= (val >> 32);
        val |= (val >> 64);
        val |= (val >> 128);
        return val ^ (val >> 1);
    }

    


    function findbit(uint256 val) internal pure returns (uint8 index) {
        index = 0;
        
        if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
            
            index |= 1;
        }
        if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
            
            index |= 2;
        }
        if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
            
            index |= 4;
        }
        if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
            
            index |= 8;
        }
        if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
            
            index |= 16;
        }
        if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
            
            index |= 32;
        }
        if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
            
            index |= 64;
        }
        if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
            
            index |= 128;
        }
    }

    







    function rescale(int256 realArg) internal pure returns (int256 realScaled, int216 shift) {
        if (realArg <= 0) {
            
            revert();
        }

        
        int216 highBit = findbit(hibit(uint256(realArg)));

        
        shift = highBit - int216(REAL_FBITS);

        if (shift < 0) {
            
            realScaled = realArg << -shift;
        } else if (shift >= 0) {
            
            realScaled = realArg >> shift;
        }
    }

    









    function lnLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
        if (realArg <= 0) {
            
            revert();
        }

        if (realArg == REAL_ONE) {
            
            
            return 0;
        }

        
        int256 realRescaled;
        int216 shift;
        (realRescaled, shift) = rescale(realArg);

        
        int256 realSeriesArg = div(realRescaled - REAL_ONE, realRescaled + REAL_ONE);

        
        int256 realSeriesResult = 0;

        for (int216 n = 0; n < maxIterations; n++) {
            
            int256 realTerm = div(ipow(realSeriesArg, 2 * n + 1), toReal(2 * n + 1));
            
            realSeriesResult += realTerm;
            if (realTerm == 0) {
                
                break;
            }
            
        }

        
        realSeriesResult = mul(realSeriesResult, REAL_TWO);

        
        return mul(toReal(shift), REAL_LN_TWO) + realSeriesResult;

    }

    




    function ln(int256 realArg) internal pure returns (int256) {
        return lnLimited(realArg, 100);
    }

    








    function expLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
        
        int256 realResult = 0;

        
        int256 realTerm = REAL_ONE;

        for (int216 n = 0; n < maxIterations; n++) {
            
            realResult += realTerm;

            
            realTerm = mul(realTerm, div(realArg, toReal(n + 1)));

            if (realTerm == 0) {
                
                break;
            }
            
        }

        
        return realResult;

    }

    




    function exp(int256 realArg) internal pure returns (int256) {
        return expLimited(realArg, 100);
    }

    


    function pow(int256 realBase, int256 realExponent) internal pure returns (int256) {
        if (realExponent == 0) {
            
            return REAL_ONE;
        }

        if (realBase == 0) {
            if (realExponent < 0) {
                
                revert();
            }
            
            return 0;
        }

        if (fpart(realExponent) == 0) {
            

            if (realExponent > 0) {
                
                return ipow(realBase, fromReal(realExponent));
            } else {
                
                return div(REAL_ONE, ipow(realBase, fromReal(-realExponent)));
            }
        }

        if (realBase < 0) {
            
            
            
            revert();
        }

        
        return exp(mul(realExponent, ln(realBase)));
    }

    


    function sqrt(int256 realArg) internal pure returns (int256) {
        return pow(realArg, REAL_HALF);
    }

    


    function sinLimited(int256 _realArg, int216 maxIterations) internal pure returns (int256) {
        
        
        
        int256 realArg = _realArg;
        realArg = realArg % REAL_TWO_PI;

        int256 accumulator = REAL_ONE;

        
        for (int216 iteration = maxIterations - 1; iteration >= 0; iteration--) {
            accumulator = REAL_ONE - mul(div(mul(realArg, realArg), toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
            
        }

        return mul(realArg, accumulator);
    }

    



    function sin(int256 realArg) internal pure returns (int256) {
        return sinLimited(realArg, 15);
    }

    


    function cos(int256 realArg) internal pure returns (int256) {
        return sin(realArg + REAL_HALF_PI);
    }

    



    function tan(int256 realArg) internal pure returns (int256) {
        return div(sin(realArg), cos(realArg));
    }
}





contract ERC827Token is ERC827, StandardToken {

  













    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.approve(_spender, _value);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

  







    function transferAndCall(
        address _to,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_to != address(this));

        super.transfer(_to, _value);

        
        require(_to.call.value(msg.value)(_data));
        return true;
    }

  








    function transferFromAndCall(
        address _from,
        address _to,
        uint256 _value,
        bytes _data
    )
    public payable returns (bool)
    {
        require(_to != address(this));

        super.transferFrom(_from, _to, _value);

        
        require(_to.call.value(msg.value)(_data));
        return true;
    }

  










    function increaseApprovalAndCall(
        address _spender,
        uint _addedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.increaseApproval(_spender, _addedValue);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

  










    function decreaseApprovalAndCall(
        address _spender,
        uint _subtractedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {
        require(_spender != address(this));

        super.decreaseApproval(_spender, _subtractedValue);

        
        require(_spender.call.value(msg.value)(_data));

        return true;
    }

}





