// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Token.sol";

// Demo: mint some token to account
// launch() campaign with CrowdFund deployer account (campaign creator)
// launch args: goal amount, 'new Date().getTime() / 1000 + 100', 'new Date().getTime() / 1000 + 200' , 
// approve Token contract -> approve(CrowdFounder contract, amount)
// pledge -> once pledged as much as goal -> claim()
// Value is transferred to campaign creator

contract CrowdFund {
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    Token public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = Token(_token);
    }

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address caller);


    function launch(
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAt >= block.timestamp, "startAt > now");
        require(_endAt >= _startAt, "endAt > startAt");
        require(_endAt <= block.timestamp + 90 days, "endAt > now + 90days");

        count++;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    // this modifer access to campaigns[_id]
    // will burn more gas, it is used for learning purposes
    modifier onlyCreator(uint _id) {
        require(msg.sender == campaigns[_id].creator, "not creator");
        _;
    }

    modifier started(uint _id) {
        require(block.timestamp >= campaigns[_id].startAt, "not started");
        _;
    }

    modifier notStarted(uint _id) {
        require(block.timestamp < campaigns[_id].startAt, "started");
        _;
    }

    modifier notEnded(uint _id) {
        require(block.timestamp <= campaigns[_id].endAt, "ended");
        _;
    }

    modifier ended(uint _id) {
        require(block.timestamp > campaigns[_id].endAt, "not ended");
        _;
    }

    function cancel(uint _id) external onlyCreator(_id) notStarted(_id) {
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external payable started(_id)  {
        Campaign storage campaign = campaigns[_id];
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external notEnded(_id) {
        Campaign storage campaign = campaigns[_id];
        campaign.pledged-= _amount;
        pledgedAmount[_id][msg.sender]-= _amount;

        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external onlyCreator(_id) ended(_id) {
        Campaign storage campaign = campaigns[_id];
        require(campaign.pledged >= campaign.goal, "Pledge less than goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external ended(_id) {
        Campaign storage campaign = campaigns[_id];
        require(campaign.pledged < campaign.goal, "pledge < goal");

        uint balance = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit Refund(_id, msg.sender);
    }

}
