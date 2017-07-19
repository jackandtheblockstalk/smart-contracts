pragma solidity ^0.4.4;

contract JackCoin{
    uint supply;
    string symbol;

    mapping(address => uint) balance_map;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function JackCoin(uint _supply, string _symbol) {
        symbol = _symbol;
        supply = _supply;
        balance_map[msg.sender] = _supply;
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        return supply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        balance = balance_map[_owner];
    }

    /*
                        Transaction costs         Execution cost
                        Transfer    notTransfer   Transfer    notTransfer
    transfer            51055       23636         28183       700
    transferNoEvent     34271       23680         11399       744
    transferOrNothing   35901       23489         13029       553
    transferReturn      35955       23533         13083       597
    transferRevert      35868       --            12996       --
    transferThrow       36000       --            13128       --
    */

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferNoEvent(address _to, uint256 _value) returns (bool success) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            // Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferReturn(address _to, uint256 _value) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return;
        }
        return;
    }

    function transferOrNothing(address _to, uint256 _value) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            Transfer(msg.sender, _to, _value);
        }
    }

    function transferThrow(address _to, uint256 _value) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            Transfer(msg.sender, _to, _value);
        }
        else {
            throw;
        }
    }

    function transferRevert(address _to, uint256 _value) {
        if (balance_map[msg.sender] > _value) {
            balance_map[msg.sender] -= _value;
            balance_map[_to] += _value;
            Transfer(msg.sender, _to, _value);
        }
        else {
            revert();
        }
    }
}
