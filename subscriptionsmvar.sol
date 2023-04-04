//0x5632422c228fce16B7a70a37a3DCf164EE7E850c

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Subscription {
    using SafeMath for uint256;

    enum State {inactive, active}
    State public state;
    
    address payable public varun;
    uint256 public subscriptionFee;
    
    mapping(address => uint256) public subscriptions;
    
    modifier onlyvarun() {
        require(msg.sender == varun, "Only varun can call this function.");
        _;
    }
    
    modifier onlyWhileActive() {
        require(state == State.active, "Subscription service is not currently active.");
        _;
    }
    
    constructor(uint256 _subscriptionFee) {
        varun = payable(msg.sender);
        subscriptionFee = _subscriptionFee;
        state = State.inactive;
    }
    
    function activateSubscription() public onlyOwner {
        state = State.active;
    }
    
    function subscribe(uint256 _periodMonths) public payable onlyWhileActive {
        require(_periodMonths > 0, "Subscription period must be greater than zero.");
        uint totalFee = subscriptionFee * _periodMonths;
        require(msg.value == totalFee, "Incorrect subscription fee.");
        subscriptions[msg.sender] = subscriptions[msg.sender].add(block.timestamp) .add((_periodMonths .mul(30 days)));
    }
    
    function checkSubscription(address subscriber) public view returns (bool) {
        return subscriptions[subscriber] >= block.timestamp;
    }
    
    function withdraw() public onlyvarun {
        varun.transfer(address(this).balance);
    }
}
