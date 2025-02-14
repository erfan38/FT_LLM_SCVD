



library StringLib {
    



    
    
    function uintToBytes(uint v) constant returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    
    
    function bytesToUInt(bytes32 v) constant returns (uint ret) {
        if (v == 0x0) {
            throw;
        }

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            }
            else if (digit < 48 || digit > 57) {
                throw;
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
    }
}






library AccountingLib {
        


        struct Bank {
            mapping (address => uint) accountBalances;
        }

        
        
        
        
        function addFunds(Bank storage self, address accountAddress, uint value) public {
                if (self.accountBalances[accountAddress] + value < self.accountBalances[accountAddress]) {
                        
                        throw;
                }
                self.accountBalances[accountAddress] += value;
        }

        event _Deposit(address indexed _from, address indexed accountAddress, uint value);
        
        
        
        
        function Deposit(address _from, address accountAddress, uint value) public {
            _Deposit(_from, accountAddress, value);
        }


        
        
        
        
        function deposit(Bank storage self, address accountAddress, uint value) public returns (bool) {
                addFunds(self, accountAddress, value);
                return true;
        }

        event _Withdrawal(address indexed accountAddress, uint value);

        
        
        
        function Withdrawal(address accountAddress, uint value) public {
            _Withdrawal(accountAddress, value);
        }

        event _InsufficientFunds(address indexed accountAddress, uint value, uint balance);

        
        
        
        
        function InsufficientFunds(address accountAddress, uint value, uint balance) public {
            _InsufficientFunds(accountAddress, value, balance);
        }

        
        
        
        
        function deductFunds(Bank storage self, address accountAddress, uint value) public {
                




                if (value > self.accountBalances[accountAddress]) {
                        
                        throw;
                }
                self.accountBalances[accountAddress] -= value;
        }

        
        
        
        
        function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
                


                if (self.accountBalances[accountAddress] >= value) {
                        deductFunds(self, accountAddress, value);
                        if (!accountAddress.send(value)) {
                                
                                
                                
                                if (!accountAddress.call.value(value)()) {
                                        
                                        
                                        throw;
                                }
                        }
                        return true;
                }
                return false;
        }
}






library GroveLib {
        




        struct Index {
                bytes32 root;
                mapping (bytes32 => Node) nodes;
        }

        struct Node {
                bytes32 id;
                int value;
                bytes32 parent;
                bytes32 left;
                bytes32 right;
                uint height;
        }

        function max(uint a, uint b) internal returns (uint) {
            if (a >= b) {
                return a;
            }
            return b;
        }

        


        
        
        
        function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].id;
        }

        
        
        
        function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
            return index.nodes[id].value;
        }

        
        
        
        function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
            return index.nodes[id].height;
        }

        
        
        
        function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].parent;
        }

        
        
        
        function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].left;
        }

        
        
        
        function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].right;
        }

        
        
        
        function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                
                return 0x0;
            }

            Node memory child;

            if (currentNode.left != 0x0) {
                
                child = index.nodes[currentNode.left];

                while (child.right != 0) {
                    child = index.nodes[child.right];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                
                
                
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.right == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }
            }

            
            return 0x0;
        }

        
        
        
        function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                
                return 0x0;
            }

            Node memory child;

            if (currentNode.right != 0x0) {
                
                child = index.nodes[currentNode.right];

                while (child.left != 0) {
                    child = index.nodes[child.left];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                
                
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.left == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }

                
            }

            
            return 0x0;
        }


        
        
        
        
        function insert(Index storage index, bytes32 id, int value) public {
                if (index.nodes[id].id == id) {
                    
                    
                    
                    if (index.nodes[id].value == value) {
                        return;
                    }
                    remove(index, id);
                }

                uint leftHeight;
                uint rightHeight;

                bytes32 previousNodeId = 0x0;

                if (index.root == 0x0) {
                    index.root = id;
                }
                Node storage currentNode = index.nodes[index.root];

                
                while (true) {
                    if (currentNode.id == 0x0) {
                        
                        currentNode.id = id;
                        currentNode.parent = previousNodeId;
                        currentNode.value = value;
                        break;
                    }

                    
                    previousNodeId = currentNode.id;

                    
                    if (value >= currentNode.value) {
                        if (currentNode.right == 0x0) {
                            currentNode.right = id;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    
                    if (currentNode.left == 0x0) {
                        currentNode.left = id;
                    }
                    currentNode = index.nodes[currentNode.left];
                }

                
                _rebalanceTree(index, currentNode.id);
        }

        
        
        
        function exists(Index storage index, bytes32 id) constant returns (bool) {
            return (index.nodes[id].id == id);
        }

        
        
        
        function remove(Index storage index, bytes32 id) public {
            Node storage replacementNode;
            Node storage parent;
            Node storage child;
            bytes32 rebalanceOrigin;

            Node storage nodeToDelete = index.nodes[id];

            if (nodeToDelete.id != id) {
                
                return;
            }

            if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
                
                
                if (nodeToDelete.left != 0x0) {
                    
                    replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
                }
                else {
                    
                    replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
                }
                
                parent = index.nodes[replacementNode.parent];

                
                
                rebalanceOrigin = replacementNode.id;

                
                
                
                
                if (parent.left == replacementNode.id) {
                    parent.left = replacementNode.right;
                    if (replacementNode.right != 0x0) {
                        child = index.nodes[replacementNode.right];
                        child.parent = parent.id;
                    }
                }
                if (parent.right == replacementNode.id) {
                    parent.right = replacementNode.left;
                    if (replacementNode.left != 0x0) {
                        child = index.nodes[replacementNode.left];
                        child.parent = parent.id;
                    }
                }

                
                
                
                replacementNode.parent = nodeToDelete.parent;
                if (nodeToDelete.parent != 0x0) {
                    parent = index.nodes[nodeToDelete.parent];
                    if (parent.left == nodeToDelete.id) {
                        parent.left = replacementNode.id;
                    }
                    if (parent.right == nodeToDelete.id) {
                        parent.right = replacementNode.id;
                    }
                }
                else {
                    
                    
                    index.root = replacementNode.id;
                }

                replacementNode.left = nodeToDelete.left;
                if (nodeToDelete.left != 0x0) {
                    child = index.nodes[nodeToDelete.left];
                    child.parent = replacementNode.id;
                }

                replacementNode.right = nodeToDelete.right;
                if (nodeToDelete.right != 0x0) {
                    child = index.nodes[nodeToDelete.right];
                    child.parent = replacementNode.id;
                }
            }
            else if (nodeToDelete.parent != 0x0) {
                
                
                parent = index.nodes[nodeToDelete.parent];

                if (parent.left == nodeToDelete.id) {
                    parent.left = 0x0;
                }
                if (parent.right == nodeToDelete.id) {
                    parent.right = 0x0;
                }

                
                rebalanceOrigin = parent.id;
            }
            else {
                
                
                index.root = 0x0;
            }

            
            nodeToDelete.id = 0x0;
            nodeToDelete.value = 0;
            nodeToDelete.parent = 0x0;
            nodeToDelete.left = 0x0;
            nodeToDelete.right = 0x0;

            
            if (rebalanceOrigin != 0x0) {
                _rebalanceTree(index, rebalanceOrigin);
            }
        }

        bytes2 constant GT = ">";
        bytes2 constant LT = "<";
        bytes2 constant GTE = ">=";
        bytes2 constant LTE = "<=";
        bytes2 constant EQ = "==";

        function _compare(int left, bytes2 operator, int right) internal returns (bool) {
            if (operator == GT) {
                return (left > right);
            }
            if (operator == LT) {
                return (left < right);
            }
            if (operator == GTE) {
                return (left >= right);
            }
            if (operator == LTE) {
                return (left <= right);
            }
            if (operator == EQ) {
                return (left == right);
            }

            
            throw;
        }

        function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.right == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.right];
                }
        }

        function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.left == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.left];
                }
        }


        




        
        


        function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
                bytes32 rootNodeId = index.root;
                
                if (rootNodeId == 0x0) {
                    
                    return 0x0;
                }

                Node storage currentNode = index.nodes[rootNodeId];

                while (true) {
                    if (_compare(currentNode.value, operator, value)) {
                        
                        
                        if ((operator == LT) || (operator == LTE)) {
                            
                            
                            if (currentNode.right == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
                                
                                
                                currentNode = index.nodes[currentNode.right];
                                continue;
                            }
                            return currentNode.id;
                        }

                        if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
                            
                            
                            if (currentNode.left == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
                                currentNode = index.nodes[currentNode.left];
                                continue;
                            }
                            return currentNode.id;
                        }
                    }

                    if ((operator == LT) || (operator == LTE)) {
                        if (currentNode.left == 0x0) {
                            
                            
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.left];
                        continue;
                    }

                    if ((operator == GT) || (operator == GTE)) {
                        if (currentNode.right == 0x0) {
                            
                            
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    if (operator == EQ) {
                        if (currentNode.value < value) {
                            if (currentNode.right == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.right];
                            continue;
                        }

                        if (currentNode.value > value) {
                            if (currentNode.left == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.left];
                            continue;
                        }
                    }
                }
        }

        function _rebalanceTree(Index storage index, bytes32 id) internal {
            
            
            Node storage currentNode = index.nodes[id];

            while (true) {
                int balanceFactor = _getBalanceFactor(index, currentNode.id);

                if (balanceFactor == 2) {
                    
                    if (_getBalanceFactor(index, currentNode.left) == -1) {
                        
                        
                        
                        _rotateLeft(index, currentNode.left);
                    }
                    _rotateRight(index, currentNode.id);
                }

                if (balanceFactor == -2) {
                    
                    if (_getBalanceFactor(index, currentNode.right) == 1) {
                        
                        
                        
                        _rotateRight(index, currentNode.right);
                    }
                    _rotateLeft(index, currentNode.id);
                }

                if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
                    _updateNodeHeight(index, currentNode.id);
                }

                if (currentNode.parent == 0x0) {
                    
                    
                    break;
                }

                currentNode = index.nodes[currentNode.parent];
            }
        }

        function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
                Node storage node = index.nodes[id];

                return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
        }

        function _updateNodeHeight(Index storage index, bytes32 id) internal {
                Node storage node = index.nodes[id];

                node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
        }

        function _rotateLeft(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            if (originalRoot.right == 0x0) {
                
                
                throw;
            }

            
            
            Node storage newRoot = index.nodes[originalRoot.right];
            newRoot.parent = originalRoot.parent;

            
            originalRoot.right = 0x0;

            if (originalRoot.parent != 0x0) {
                
                
                Node storage parent = index.nodes[originalRoot.parent];

                
                
                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }


            if (newRoot.left != 0) {
                
                
                Node storage leftChild = index.nodes[newRoot.left];
                originalRoot.right = leftChild.id;
                leftChild.parent = originalRoot.id;
            }

            
            originalRoot.parent = newRoot.id;
            newRoot.left = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }

        function _rotateRight(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            if (originalRoot.left == 0x0) {
                
                
                throw;
            }

            
            
            Node storage newRoot = index.nodes[originalRoot.left];
            newRoot.parent = originalRoot.parent;

            
            originalRoot.left = 0x0;

            if (originalRoot.parent != 0x0) {
                
                
                Node storage parent = index.nodes[originalRoot.parent];

                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }

            if (newRoot.right != 0x0) {
                Node storage rightChild = index.nodes[newRoot.right];
                originalRoot.left = newRoot.right;
                rightChild.parent = originalRoot.id;
            }

            
            originalRoot.parent = newRoot.id;
            newRoot.right = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }
}







library ResourcePoolLib {
        


        struct Pool {
                uint rotationDelay;
                uint overlapSize;
                uint freezePeriod;

                uint _id;

                GroveLib.Index generationStart;
                GroveLib.Index generationEnd;

                mapping (uint => Generation) generations;
                mapping (address => uint) bonds;
        }

        








        struct Generation {
                uint id;
                uint startAt;
                uint endAt;
                address[] members;
        }

        
        
        function createNextGeneration(Pool storage self) public returns (uint) {
                



                Generation storage previousGeneration = self.generations[self._id];

                self._id += 1;
                Generation storage nextGeneration = self.generations[self._id];
                nextGeneration.id = self._id;
                nextGeneration.startAt = block.number + self.freezePeriod + self.rotationDelay;
                GroveLib.insert(self.generationStart, StringLib.uintToBytes(nextGeneration.id), int(nextGeneration.startAt));

                if (previousGeneration.id == 0) {
                        
                        
                        return nextGeneration.id;
                }

                
                previousGeneration.endAt = block.number + self.freezePeriod + self.rotationDelay + self.overlapSize;
                GroveLib.insert(self.generationEnd, StringLib.uintToBytes(previousGeneration.id), int(previousGeneration.endAt));

                
                
                address[] memory members = previousGeneration.members;

                for (uint i = 0; i < members.length; i++) {
                    
                    
                    uint index = uint(sha3(block.blockhash(block.number))) % (members.length - nextGeneration.members.length);
                    nextGeneration.members.length += 1;
                    nextGeneration.members[nextGeneration.members.length - 1] = members[index];

                    
                    
                    members[index] = members[members.length - 1];
                }

                return nextGeneration.id;
        }

        
        
        
        
        function getGenerationForWindow(Pool storage self, uint leftBound, uint rightBound) constant returns (uint) {
            
                var left = GroveLib.query(self.generationStart, "<=", int(leftBound));

                if (left != 0x0) {
                    Generation memory leftCandidate = self.generations[StringLib.bytesToUInt(left)];
                    if (leftCandidate.startAt <= leftBound && (leftCandidate.endAt >= rightBound || leftCandidate.endAt == 0)) {
                        return leftCandidate.id;
                    }
                }

                var right = GroveLib.query(self.generationEnd, ">=", int(rightBound));
                if (right != 0x0) {
                    Generation memory rightCandidate = self.generations[StringLib.bytesToUInt(right)];
                    if (rightCandidate.startAt <= leftBound && (rightCandidate.endAt >= rightBound || rightCandidate.endAt == 0)) {
                        return rightCandidate.id;
                    }
                }

                return 0;
        }

        
        
        function getNextGenerationId(Pool storage self) constant returns (uint) {
            
                var next = GroveLib.query(self.generationStart, ">", int(block.number));
                if (next == 0x0) {
                    return 0;
                }
                return StringLib.bytesToUInt(next);
        }

        
        
        function getCurrentGenerationId(Pool storage self) constant returns (uint) {
            
                var next = GroveLib.query(self.generationEnd, ">", int(block.number));
                if (next != 0x0) {
                    return StringLib.bytesToUInt(next);
                }

                next = GroveLib.query(self.generationStart, "<=", int(block.number));
                if (next != 0x0) {
                    return StringLib.bytesToUInt(next);
                }
                return 0;
        }

        


        
        
        
        
        function isInGeneration(Pool storage self, address resourceAddress, uint generationId) constant returns (bool) {
            
            if (generationId == 0) {
                return false;
            }
            Generation memory generation = self.generations[generationId];
            for (uint i = 0; i < generation.members.length; i++) {
                if (generation.members[i] == resourceAddress) {
                    return true;
                }
            }
            return false;
        }

        
        
        
        function isInCurrentGeneration(Pool storage self, address resourceAddress) constant returns (bool) {
            
            return isInGeneration(self, resourceAddress, getCurrentGenerationId(self));
        }

        
        
        
        function isInNextGeneration(Pool storage self, address resourceAddress) constant returns (bool) {
            
            return isInGeneration(self, resourceAddress, getNextGenerationId(self));
        }

        
        
        
        function isInPool(Pool storage self, address resourceAddress) constant returns (bool) {
            
            return (isInCurrentGeneration(self, resourceAddress) || isInNextGeneration(self, resourceAddress));
        }

        event _AddedToGeneration(address indexed resourceAddress, uint indexed generationId);
        
        
        
        function AddedToGeneration(address resourceAddress, uint generationId) public {
                _AddedToGeneration(resourceAddress, generationId);
        }

        event _RemovedFromGeneration(address indexed resourceAddress, uint indexed generationId);
        
        
        
        function RemovedFromGeneration(address resourceAddress, uint generationId) public {
                _RemovedFromGeneration(resourceAddress, generationId);
        }

        
        
        
        
        function canEnterPool(Pool storage self, address resourceAddress, uint minimumBond) constant returns (bool) {
            





            
            if (self.bonds[resourceAddress] < minimumBond) {
                
                return false;
            }

            if (isInPool(self, resourceAddress)) {
                
                
                return false;
            }

            var nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId != 0) {
                var nextGeneration = self.generations[nextGenerationId];
                if (block.number + self.freezePeriod >= nextGeneration.startAt) {
                    
                    return false;
                }
            }

            return true;
        }

        
        
        
        
        function enterPool(Pool storage self, address resourceAddress, uint minimumBond) public returns (uint) {
            if (!canEnterPool(self, resourceAddress, minimumBond)) {
                throw;
            }
            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                
                nextGenerationId = createNextGeneration(self);
            }
            Generation storage nextGeneration = self.generations[nextGenerationId];
            
            nextGeneration.members.length += 1;
            nextGeneration.members[nextGeneration.members.length - 1] = resourceAddress;
            return nextGenerationId;
        }

        
        
        
        function canExitPool(Pool storage self, address resourceAddress) constant returns (bool) {
            if (!isInCurrentGeneration(self, resourceAddress)) {
                
                return false;
            }

            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                
                return true;
            }

            if (self.generations[nextGenerationId].startAt - self.freezePeriod <= block.number) {
                
                return false;
            }

            
            
            return isInNextGeneration(self, resourceAddress);
        }


        
        
        
        function exitPool(Pool storage self, address resourceAddress) public returns (uint) {
            if (!canExitPool(self, resourceAddress)) {
                throw;
            }
            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                
                nextGenerationId = createNextGeneration(self);
            }
            
            removeFromGeneration(self, nextGenerationId, resourceAddress);
            return nextGenerationId;
        }

        
        
        
        
        function removeFromGeneration(Pool storage self, uint generationId, address resourceAddress) public returns (bool){
            Generation storage generation = self.generations[generationId];
            
            for (uint i = 0; i < generation.members.length; i++) {
                if (generation.members[i] == resourceAddress) {
                    generation.members[i] = generation.members[generation.members.length - 1];
                    generation.members.length -= 1;
                    return true;
                }
            }
            return false;
        }

        



        
        
        
        
        function deductFromBond(Pool storage self, address resourceAddress, uint value) public {
                



                if (value > self.bonds[resourceAddress]) {
                        
                        throw;
                }
                self.bonds[resourceAddress] -= value;
        }

        
        
        
        
        function addToBond(Pool storage self, address resourceAddress, uint value) public {
                



                if (self.bonds[resourceAddress] + value < self.bonds[resourceAddress]) {
                        
                        throw;
                }
                self.bonds[resourceAddress] += value;
        }

        
        
        
        
        function withdrawBond(Pool storage self, address resourceAddress, uint value, uint minimumBond) public {
                


                
                if (value > self.bonds[resourceAddress]) {
                        throw;
                }

                
                
                if (isInPool(self, resourceAddress)) {
                        if (self.bonds[resourceAddress] - value < minimumBond) {
                            return;
                        }
                }

                deductFromBond(self, resourceAddress, value);
                if (!resourceAddress.send(value)) {
                        
                        
                        
                        if (!resourceAddress.call.gas(msg.gas).value(value)()) {
                                
                                
                                throw;
                        }
                }
        }
}


contract Alarm {
        





        function Alarm() {
                callDatabase.unauthorizedRelay = new Relay();
                callDatabase.authorizedRelay = new Relay();

                callDatabase.callerPool.freezePeriod = 80;
                callDatabase.callerPool.rotationDelay = 80;
                callDatabase.callerPool.overlapSize = 256;
        }

        ScheduledCallLib.CallDatabase callDatabase;

        
        address constant owner = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

        


        function getAccountBalance(address accountAddress) constant public returns (uint) {
                return callDatabase.gasBank.accountBalances[accountAddress];
        }

        function deposit() public {
                deposit(msg.sender);
        }

        function deposit(address accountAddress) public {
                


                AccountingLib.deposit(callDatabase.gasBank, accountAddress, msg.value);
                AccountingLib.Deposit(msg.sender, accountAddress, msg.value);
        }

        function withdraw(uint value) public {
                


                if (AccountingLib.withdraw(callDatabase.gasBank, msg.sender, value)) {
                        AccountingLib.Withdrawal(msg.sender, value);
                }
                else {
                        AccountingLib.InsufficientFunds(msg.sender, value, callDatabase.gasBank.accountBalances[msg.sender]);
                }
        }

        function() {
                



                deposit(msg.sender);
        }

        


        function unauthorizedAddress() constant returns (address) {
                return address(callDatabase.unauthorizedRelay);
        }

        function authorizedAddress() constant returns (address) {
                return address(callDatabase.authorizedRelay);
        }

        function addAuthorization(address schedulerAddress) public {
                ScheduledCallLib.addAuthorization(callDatabase, schedulerAddress, msg.sender);
        }

        function removeAuthorization(address schedulerAddress) public {
                callDatabase.accountAuthorizations[sha3(schedulerAddress, msg.sender)] = false;
        }

        function checkAuthorization(address schedulerAddress, address contractAddress) constant returns (bool) {
                return callDatabase.accountAuthorizations[sha3(schedulerAddress, contractAddress)];
        }

        


        function getMinimumBond() constant returns (uint) {
                return ScheduledCallLib.getMinimumBond();
        }

        function depositBond() public {
                ResourcePoolLib.addToBond(callDatabase.callerPool, msg.sender, msg.value);
        }

        function withdrawBond(uint value) public {
                ResourcePoolLib.withdrawBond(callDatabase.callerPool, msg.sender, value, getMinimumBond());
        }

        function getBondBalance() constant returns (uint) {
                return getBondBalance(msg.sender);
        }

        function getBondBalance(address callerAddress) constant returns (uint) {
                return callDatabase.callerPool.bonds[callerAddress];
        }


        


        function getGenerationForCall(bytes32 callKey) constant returns (uint) {
                var call = callDatabase.calls[callKey];
                return ResourcePoolLib.getGenerationForWindow(callDatabase.callerPool, call.targetBlock, call.targetBlock + call.gracePeriod);
        }

        function getGenerationSize(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].members.length;
        }

        function getGenerationStartAt(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].startAt;
        }

        function getGenerationEndAt(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].endAt;
        }

        function getCurrentGenerationId() constant returns (uint) {
                return ResourcePoolLib.getCurrentGenerationId(callDatabase.callerPool);
        }

        function getNextGenerationId() constant returns (uint) {
                return ResourcePoolLib.getNextGenerationId(callDatabase.callerPool);
        }

        function isInPool() constant returns (bool) {
                return ResourcePoolLib.isInPool(callDatabase.callerPool, msg.sender);
        }

        function isInPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.isInPool(callDatabase.callerPool, callerAddress);
        }

        function isInGeneration(uint generationId) constant returns (bool) {
                return isInGeneration(msg.sender, generationId);
        }

        function isInGeneration(address callerAddress, uint generationId) constant returns (bool) {
                return ResourcePoolLib.isInGeneration(callDatabase.callerPool, callerAddress, generationId);
        }

        


        function getPoolFreezePeriod() constant returns (uint) {
                return callDatabase.callerPool.freezePeriod;
        }

        function getPoolOverlapSize() constant returns (uint) {
                return callDatabase.callerPool.overlapSize;
        }

        function getPoolRotationDelay() constant returns (uint) {
                return callDatabase.callerPool.rotationDelay;
        }

        


        function canEnterPool() constant returns (bool) {
                return ResourcePoolLib.canEnterPool(callDatabase.callerPool, msg.sender, getMinimumBond());
        }

        function canEnterPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.canEnterPool(callDatabase.callerPool, callerAddress, getMinimumBond());
        }

        function canExitPool() constant returns (bool) {
                return ResourcePoolLib.canExitPool(callDatabase.callerPool, msg.sender);
        }

        function canExitPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.canExitPool(callDatabase.callerPool, callerAddress);
        }

        function enterPool() public {
                uint generationId = ResourcePoolLib.enterPool(callDatabase.callerPool, msg.sender, getMinimumBond());
                ResourcePoolLib.AddedToGeneration(msg.sender, generationId);
        }

        function exitPool() public {
                uint generationId = ResourcePoolLib.exitPool(callDatabase.callerPool, msg.sender);
                ResourcePoolLib.RemovedFromGeneration(msg.sender, generationId);
        }

        



        function getLastCallKey() constant returns (bytes32) {
                return callDatabase.lastCallKey;
        }

        


        function getCallContractAddress(bytes32 callKey) constant returns (address) {
                return ScheduledCallLib.getCallContractAddress(callDatabase, callKey);
        }

        function getCallScheduledBy(bytes32 callKey) constant returns (address) {
                return ScheduledCallLib.getCallScheduledBy(callDatabase, callKey);
        }

        function getCallCalledAtBlock(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallCalledAtBlock(callDatabase, callKey);
        }

        function getCallGracePeriod(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGracePeriod(callDatabase, callKey);
        }

        function getCallTargetBlock(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallTargetBlock(callDatabase, callKey);
        }

        function getCallBaseGasPrice(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallBaseGasPrice(callDatabase, callKey);
        }

        function getCallGasPrice(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGasPrice(callDatabase, callKey);
        }

        function getCallGasUsed(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGasUsed(callDatabase, callKey);
        }

        function getCallABISignature(bytes32 callKey) constant returns (bytes4) {
                return ScheduledCallLib.getCallABISignature(callDatabase, callKey);
        }

        function checkIfCalled(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfCalled(callDatabase, callKey);
        }

        function checkIfSuccess(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfSuccess(callDatabase, callKey);
        }

        function checkIfCancelled(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfCancelled(callDatabase, callKey);
        }

        function getCallDataHash(bytes32 callKey) constant returns (bytes32) {
                return ScheduledCallLib.getCallDataHash(callDatabase, callKey);
        }

        function getCallPayout(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallPayout(callDatabase, callKey);
        }

        function getCallFee(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallFee(callDatabase, callKey);
        }

        function getCallMaxCost(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallMaxCost(callDatabase, callKey);
        }

        function getCallData(bytes32 callKey) constant returns (bytes) {
                return callDatabase.data_registry[callDatabase.calls[callKey].dataHash];
        }

        


        function registerData() public {
                ScheduledCallLib.registerData(callDatabase, msg.data);
                ScheduledCallLib.DataRegistered(callDatabase.lastDataHash);
        }

        function getLastDataHash() constant returns (bytes32) {
                return callDatabase.lastDataHash;
        }

        function getLastDataLength() constant returns (uint) {
                return callDatabase.lastDataLength;
        }

        function getLastData() constant returns (bytes) {
                return callDatabase.lastData;
        }

        


        function doCall(bytes32 callKey) public {
                ScheduledCallLib.doCall(callDatabase, callKey, msg.sender);
        }

        


        function getMinimumGracePeriod() constant returns (uint) {
                return ScheduledCallLib.getMinimumGracePeriod();
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock) public {
                



                scheduleCall(contractAddress, abiSignature, dataHash, targetBlock, 255, 0);
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod) public {
                


                scheduleCall(contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, 0);
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod, uint nonce) public {
                




                bytes15 reason = ScheduledCallLib.scheduleCall(callDatabase, msg.sender, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);
                bytes32 callKey = ScheduledCallLib.computeCallKey(msg.sender, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);

                if (reason != 0x0) {
                        ScheduledCallLib.CallRejected(callKey, reason);
                }
                else {
                        ScheduledCallLib.CallScheduled(callKey);
                }
        }

        function cancelCall(bytes32 callKey) public {
                if (ScheduledCallLib.cancelCall(callDatabase, callKey, address(msg.sender))) {
                        ScheduledCallLib.CallCancelled(callKey);
                }
        }

        


        function getCallWindowSize() constant returns (uint) {
                return ScheduledCallLib.getCallWindowSize();
        }

        function getGenerationIdForCall(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getGenerationIdForCall(callDatabase, callKey);
        }

        function getDesignatedCaller(bytes32 callKey, uint blockNumber) constant returns (address) {
                return ScheduledCallLib.getDesignatedCaller(callDatabase, callKey, blockNumber);
        }

        function getNextCall(uint blockNumber) constant returns (bytes32) {
                return GroveLib.query(callDatabase.callIndex, ">=", int(blockNumber));
        }

        function getNextCallSibling(bytes32 callKey) constant returns (bytes32) {
                return GroveLib.getNextNode(callDatabase.callIndex, callKey);
        }
}