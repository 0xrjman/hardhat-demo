// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Demo {
    // 1. Data types - values and references

    bool public boolValue = true;
    // uint = uint256 [0, 2**256 - 1]
    uint public uintValue = 123;
    // int = int256 [-2**255, 2**255 - 1]
    int public intValue = -123;
    int public minIntValue = type(int).min;
    int public maxIntValue = type(int).max;
    address public addressValue = 0x1234567890123456789012345678901234567890;
    bytes32 public bytes32Value = 0x1234567890123456789012345678901234567890123456789012345678901234;

    // `pure` cannot be used with storage variables
    // `external` can be called from outside the contract
    function add (uint x, uint y) external pure returns (uint) {
        return x + y;
    }

    // 2. State Variables
    // uint public myUint = 123;
    // uint addr; 
    // function foo() external view {
    //     addr = 1;
    // }

    // Global Variables
    function globalVars() external view returns (address, uint, uint) {
        address sender = msg.sender;
        uint timestamp = block.timestamp;
        uint blockNumber = block.number;
        return (sender, timestamp, blockNumber);
    }

    // 3. ViewAndPure Functions
    uint public num;
    function viewFunc(uint x) external view returns (uint) {
        return num + x;
    }

    function pureFunc(uint x) external pure returns (uint) {
        // cannot read num
        return 1 + x;
    }

    // 4. Default Values
    // false or zero
    // bool public defaultBool = false;;
    
    // 5. Constants
    // define it as constant can save gas
    address public constant MY_ADDRESS = 0x1234567890123456789012345678901234567890;
    uint public constant MY_UINT = 123;

    // 6. IfElse
    function ifelse(uint x) external pure returns (uint) {
        if (x < 10) {
            return 1;
        } else if (x < 20) {
            return 2;
        } else {
            return 3;
        }
    }
    function ternary(uint x) external pure returns (uint) {
        return x < 10 ? 1 : x < 20 ? 2 : 3;
    }

    // 7. Loop
    function loop(uint x) external pure returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < x; ++i) {
            if (i == 3) continue;
            sum += i;
            if (i == 5) break;
        }
        return sum;
    }

    // 8. Error
    // require revert assert
    function testRequire(uint _i) public pure {
        require(_i > 0, "i must be greater than 0");
    }

    function testRevert(uint _i) public pure {
        if (_i < 1) {
            revert("i must be greater than 0");
        }
    }

    uint public assertValue = 123;
    function testAssert() public view {
        assert(assertValue == 123);
    }

    error MyError(address caller, uint i);
    function testCustomError(uint _i) public view {
        if (_i > 10) {
            revert MyError(msg.sender, _i);
        }
    }

    // 9. Function Modifier
    // - basic
    // - input
    // - sandwich
    bool public paused;
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        // `_`: other code
        _;
    }

    function pause() public whenNotPaused {
        paused = true;
    }

    modifier cap(uint _x) {
        require(_x < 100, "x >= 100");
        _;
    }
    function incBy(uint _x) external whenNotPaused cap(_x) {
        num += _x;
    }

    modifier sandwich() {
        num += 1;
        _;
        num *=2;
    }
    function foo(uint _x) external whenNotPaused sandwich {
        num += _x;
    }

    // 10. Constructor
    address public owner;
    constructor(uint _x) {
        owner = msg.sender;
    }

    // 11. Function Output
    function returnMany() public pure returns (uint, bool) {
        return (1, true);
    }

    function named() public pure returns (uint x, bool b) {
        // implicit return
        x = 1;
        b = true;
    }

    function destructingAssignments() public pure {
        (uint x, bool b) = returnMany();
        assert(x == 1 && b == true);
        (, bool _b) = returnMany();
        assert(_b == true);
    }

    // 12. Array
    uint[] public nums = [1, 2, 3];
    uint[3] public numsFixed = [4, 5, 6];

    function setNumsFixed(uint _x, uint _y, uint _z) external {
        nums[0] = _x;
        nums[1] = _y;
        nums[2] = _z;
    }

    function arrayExample() external {
        nums.push(4); // [1, 2, 3, 4]
        // uint x = nums[1]; // 2
        delete nums[1]; // [1, 3, 4]
        nums.pop(); // [1, 3]
        // uint len = nums.length; // 2

        // create array in memory
        // uint[] memory nums2 = uint[](5);
        // cannot pop, push (change length)
        // nums2[1] = 123;
    }

    function returnArray() external view returns (uint[] memory) {
        return nums;
    }

    // 13. ArrayShift
    function exampleArrayShift() external {
        // uint[] memory nums = [1, 2, 3];
        // uint x = nums.shift(); // 1
        // assert(nums[0] == 2);
        // nums.unshift(0); // [0, 2, 3]
    }

    function example() public {
        nums = [1, 2, 3];
        // restore to default value
        delete nums[1]; // [1, 0, 3]
    }

    function removeArrayElem(uint _i) public {
        nums[_i] = nums[nums.length - 1];
        nums.pop();
    }

    // function removeArrayElem(uint _i) public {
    //     require(_i < nums.length, "index out of range");
    //     for (uint i = _i; i < nums.length - 1; ++i) {
    //         nums[i] = nums[i + 1];
    //     }
    //     nums.pop();
    // }
}