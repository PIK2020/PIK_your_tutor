pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Countdown.sol";

//The Escrow Smart Contract for PIK. An escrow is by definition a third party
//allowing two complete strangers to transact without the need for mutual trust.
//The Escrow contract will hold and later release the assets of both parties 
//provided they uphold their respective ends of the bargain.

contract Escrow is Countdown {

  using SafeMath for uint256;

  // All the data we want to keep track of in our contract
  struct Data {
    address admin; //address of however first deploys the contract
    address buyer; //address of buyer (in this case the student)
    address seller; //address of seller (in this case the tutor)
    uint128 paymentAmount;
    uint128 stakeAmount;
    AgreementParams agreementParams; 
  }

  // Parameters of the agreement set from the frontEnd
  struct AgreementParams {
    uint120 griefingRatio;
    uint128 countdownLength;
  }

  /*
  The admin address will be PIK's address where all the intermediate charges
  from students & tutors will be withdrawn.
  */
  mapping(address => uint256) public deposits; // student deposits
  mapping(address => uint256) public stakes; // tutor stakes

  event Initialized(
    address admin,
    address buyer,
    address seller,
    uint256 paymentAmount,
    uint256 stakeAmount,
    uint256 countdownLength,
    bytes agreementParams
  );
  event StakeDeposited(address seller, uint256 amount);
  event PaymentDeposited(address buyer, uint256 amount);
  event Cancelled();

  constructor() {
    admin = msg.sender;
  }

  // TODO:
  // define a helper function that is going to take fees at some point and transfer those to admin 
  // make use of a timer (one timer when the tutor first stakes, another timer when the student first accepts)
  // define a function the student can trigger to confirm the tutoring session has taken place
  // define a punish function that the student can pay to to "destroy" part of or the entire stake of a bad tutor

  function depositPayment() payable {
    buyer = msg.sender;
    uint256 amount = msg.value;
    deposits[buyer] = add(deposits[buyer], amount);

    emit PaymentDeposited(buyer, amount); 
  }

  function depositStake() payable {
    seller = msg.sender;
    uint256 stake = msg.value;
    stakes[seller] = add(stakes[seller], stake);

    emit StakeDeposited(seller, stake);
  }

  function releaseFunds() internal {
    // add if statement for the escrow countdown or fulfilled function
    uint256 payout = add(deposits, stakes);
    seller.transfer(payout); 
    deposits = 0;
    stakes = 0;
  } 
  // ADD ESCROW COUNTDOWN
  // ADD fee calculator and overall functionality
}
