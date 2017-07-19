pragma solidity ^0.4.4;

contract Owned {
    address public owner;

    modifier only_owner() {
        if (msg.sender == owner) {
            _;
        }
        else throw;
    }

   event OwnerChanged(address oldOwner,address newOwner);

    function Owned() {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external only_owner {
        address oldOwner = owner;
        owner = _newOwner;
        OwnerChanged(oldOwner,_newOwner);
    }
}

contract GreeterMap is Owned {
    string greeting;
    uint public greeting_count = 0;
    mapping (uint => string) greeting_history;

    event Change(uint change_no, string greeting);

    function Greeter() {
        greeting_history[0] = "Hello Workshop";
     }

    function greet(uint i) constant returns (string){
        return greeting_history[i];
    }

    function changeGreeting(string _newGreeting) only_owner returns (uint) {
        greeting_history[++greeting_count] = _newGreeting;
        Change(greeting_count-1, _newGreeting);
        return greeting_count-1;
    }
}

contract GreeterArray is Owned {
    string greeting;
    string[] greeting_history;

    function Greeter() {
        greeting_history.push("Hello Workshop");
     }

    function greet(uint i) constant returns (string){
        return greeting_history[i];
    }

    function changeGreeting(string _newGreeting) only_owner {
        greeting_history.push(_newGreeting);
    }
}
