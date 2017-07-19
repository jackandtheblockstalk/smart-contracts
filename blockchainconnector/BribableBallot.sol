pragma solidity ^0.4.4;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        address delegate;
    }
    struct Proposal {
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    /// Create a new ballot with $(_numProposals) different proposals.
    function Ballot(uint8 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        proposals.length = _numProposals;
    }

    /// Give $(voter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function giveRightToVote(address voter) {
        if (msg.sender != chairperson || voters[voter].voted) return;
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address to) {
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (sender.voted) return;
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
            to = voters[to].delegate;
        if (to == msg.sender) return;
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        if (delegate.voted)
            proposals[delegate.vote].voteCount += sender.weight;
        else
            delegate.weight += sender.weight;
    }

    /// Give a single vote to proposal $(proposal).
    function vote(uint8 proposal) {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || proposal >= proposals.length) return;
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() constant returns (uint8 winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 proposal = 0; proposal < proposals.length; proposal++)
            if (proposals[proposal].voteCount > winningVoteCount) {
                winningVoteCount = proposals[proposal].voteCount;
                winningProposal = proposal;
            }
    }
}

contract BribableBallot is Ballot {
    mapping(address => mapping(uint8 => uint)) bribes;
    mapping(address => uint) withdrawableBribes;

    event BribeOffered(address _toBribe, uint8 _proposalNo, uint _amount);

    function BribableBallot(uint8 _numProposals) Ballot(_numProposals) {}

    function bribe(address _toBribe, uint8 _proposalNo) payable {
        assert(msg.value > 0);
        assert(_proposalNo < proposals.length);
        assert(!voters[_toBribe].voted);

        bribes[_toBribe][_proposalNo] += msg.value;
        BribeOffered(_toBribe, _proposalNo, msg.value);
    }

    function voteWithBribe(uint8 proposal) {
        vote(proposal);
        // if (bribes[msg.sender][proposal] > 0) {
        //     msg.sender.transfer(bribes[msg.sender][proposal]);
        // }
        withdrawableBribes[msg.sender] += bribes[msg.sender][proposal];
    }

    function getBribeAmount(address _toBribe, uint8 _proposalNo) constant returns (uint) {
        return bribes[_toBribe][_proposalNo];
    }

    function highestBribe() constant returns (int) {
        uint highestBribe = 0;
        int bestProposalBribe = -1;
        for (uint8 i = 0; i < proposals.length; i++) {
            if (getBribeAmount(msg.sender, i) > highestBribe) {
                highestBribe = getBribeAmount(msg.sender, i);
                bestProposalBribe = i;
            }
        }
        return bestProposalBribe;
    }

    function withdrawBribes() {
        uint amount = withdrawableBribes[msg.sender];
        withdrawableBribes[msg.sender] = 0;
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        msg.sender.transfer(amount);
    }
}
