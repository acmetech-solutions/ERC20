// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AuctionFSM {
    enum State {
        Created,
        Started,
        Ended,
        Claimed
    }
    State public currentState;

    address public owner;
    address public highestBidder;
    uint256 public highestBid;

    constructor() {
        owner = msg.sender;
        currentState = State.Created;
    }

    function startAuction() external {
        require(msg.sender == owner, "Not owner");
        require(currentState == State.Created, "Already started");
        currentState = State.Started;
    }

    function bid() external payable {
        require(currentState == State.Started, "Auction not started");
        require(msg.value > highestBid, "Bid too low");

        // Reembolso al postor anterior
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function endAuction() external {
        require(msg.sender == owner, "Not owner");
        require(currentState == State.Started, "Not active");
        currentState = State.Ended;
    }

    function claimPrize() external {
        require(currentState == State.Ended, "Auction not ended");
        require(msg.sender == highestBidder, "Not winner");

        currentState = State.Claimed;
        payable(msg.sender).transfer(address(this).balance);
    }
}
