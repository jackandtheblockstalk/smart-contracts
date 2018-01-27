pragma solidity ^0.4.4;

contract JackCoin {
    uint public supply;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;

    function JackCoin(uint _supply) {
        balances[msg.sender] = _supply;
        supply = _supply;
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        return supply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value
            && _value > 0
            && balances[msg.sender] + _value > _value) {
            balances[msg.sender] -= _value;
            balances[_to] -= _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value
            && allowances[msg.sender][_from] >= _value
            && _value > 0
            && balances[_to] + _value > _value) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowances[msg.sender][_from] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowances[_spender][msg.sender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowances[_spender][_owner];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
