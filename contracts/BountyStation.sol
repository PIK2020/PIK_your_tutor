pragma solidity >=0.5.0 <0.8.0;

contract BountyStation {
    uint sessionPrice; // price in ETH for the tutor session (to be staked immediatelly upon deploying the bounty)
    uint sessionMinuteLength; // estimated length of the session in minutes
    address studentAddress; // student wallet address (public and to be obtained from Metamask or equivalent wallet)
    address tutorAddress; // to be added upon accepting the bounty

}

