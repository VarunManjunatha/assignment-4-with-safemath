//0x0Edb518535Be8f902a45DEc1A961a32Cf6Bc3b68

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Crowdfunding {
    using SafeMath for uint256;

    enum State {inactive, active, completed}
    State public state;
    
    address payable public varun;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public totalFundsRaised;
    
    mapping(address => uint256) public contributions;
    
    modifier onlyvarun() {
        require(msg.sender == varun, "Only varun can call this function.");
        _;
    }
    
    modifier inState(State _state) {
        require(state == _state, "Invalid state.");
        _;
    }
    
    constructor() {
        varun = payable(msg.sender);
        state = State.inactive;
    }
    
    function startFunding(uint256 _fundingGoal, uint256 _durationDays) public onlyvarun inState(State.inactive) {
        require(_fundingGoal > 0, "Funding goal must be greater than zero.");
        require(_durationDays > 0, "Funding duration must be greater than zero.");
        fundingGoal = _fundingGoal;
        deadline = block.timestamp .add((_durationDays .mul(1 days)));
        state = State.active;
    }
    
    function contribute() public payable inState(State.active) {
        require(msg.value > 0, "Contribution must be greater than zero.");
        require(block.timestamp < deadline, "Funding deadline has passed.");
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        totalFundsRaised = totalFundsRaised.add(msg.value);
    }
    
    function endFunding() public onlyvarun inState(State.active) {
        if (totalFundsRaised >= fundingGoal) {
            varun.transfer(address(this).balance);
            state = State.completed;
        } else {
            state = State.inactive;
        }
    }
    
    function withdraw() public inState(State.completed) {
        require(contributions[msg.sender] > 0, "You did not contribute to this campaign.");
        uint amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}