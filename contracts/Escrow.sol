pragma solidity >=0.4.22 <0.9.0;

/*
The Escrow Smart Contract for PIK. An escrow is by definition a third party
allowing two complete strangers to transact without the need for mutual trust.
The Escrow contract will hold and later release the assets of both parties 
provided they uphold their respective ends of the bargain.
*/
contract Escrow {
  /*
  The admin address will be PIK's address where all the intermediate charges
  from students & tutors will be withdrawn.
  */
  address admin;
  mapping(address => uint256) public deposits; // student deposits
  mapping(address => uint256) public stakes; // tutor stakes

  constructor() {
    admin = msg.sender;
  }
  // TODO: define a stake function (used by the tutor)
  // define a deposit function (to be used by the student when they want to buy the tutoring session)
  // define a withdraw function (to be triggered once the student confirms the tutoring session has taken place OR timer has ended)
  // define a helper function that is going to take fees at some point and transfer those to admin 
  // make use of a timer (one timer when the tutor first stakes, another timer when the student first accepts)
  // define a function the student can trigger to confirm the tutoring session has taken place
  // define a punish function that the student can pay to to "destroy" part of or the entire stake of a bad tutor
  // ADD SafeMath from OpenZeppelin

}