pragma solidity >=0.6.0 <0.9.0;

import "./Countdown.sol";

//The Escrow Smart Contract for PIK. An escrow is by definition a third party
//allowing two complete strangers to transact without the need for mutual trust.
//The Escrow contract will hold and later release the assets of both parties 
//provided they uphold their respective ends of the bargain.

contract Escrow is Countdown {

  // All the data we want to keep track of in our contract
  Data private _data;
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
  event Finalized();
  event Cancelled();
  event Ended();

  constructor(
    address admin,
    address buyer,
    address seller,
    uint256 paymentAmount,
    uint256 stakeAmount,
    uint256 countdownLength,
    bytes memory agreementParams
  ) public {
    // set participants if defined
    if (buyer != address(0)) {
      _data.buyer = buyer;
    }

    if (seller != address(0)) {
      _data.seller = seller;
    }

    if (admin != address(0)) {
      _data.admin = admin;
    } else {
      _data.admin = msg.sender;
    }

    // set countdown length
    Countdown._setLength(countdownLength);

    // set payment/stake amounts if defined
    if (paymentAmount != uint256(0)) {
      require(paymentAmount <= uint256(uint128(paymentAmount)), "paymentAmount is too large");
      _data.paymentAmount = uint128(paymentAmount);
    }

    if (stakeAmount != uint256(0)) {
      require(stakeAmount <= uint256(uint128(stakeAmount)), "stakeAmount is too large");
      _data.stakeAmount = uint128(stakeAmount);
    }

    // set agreementParams if defined
    if (agreementParams.length != 0) {
      (
        uint256 ratio,
        uint256 agreementCountdown
      ) = abi.decode(agreementParams, (uint256, uint256));
      require(ratio == uint256(uint120(ratio)), "ratio out of bounds");
      require(agreementCountdown == uint256(uint128(agreementCountdown)), "agreementCountdown out of bounds");
      _data.agreementParams = AgreementParams(uint120(ratio), uint128(agreementCountdown));
    }

    emit Initialized(admin, buyer, seller, paymentAmount, stakeAmount, countdownLength, agreementParams);
    
    // In Erasure, tokenID and metadata are also initialized
    // TODO: look into what needs to be done to enable token support

  }

  // TODO:
  // define a helper function that is going to take fees at some point and transfer those to admin 
  // make use of a timer (one timer when the tutor first stakes, another timer when the student first accepts)
  // define a function the student can trigger to confirm the tutoring session has taken place
  // define a punish function that the student can pay to to "destroy" part of or the entire stake of a bad tutor

  function depositPayment() public payable {
    _data.buyer = msg.sender;
    uint256 amount = msg.value;
    _data.paymentAmount = _data.paymentAmount + amount;
    deposits[_data.buyer] = deposits[_data.buyer] + amount;

    emit PaymentDeposited(_data.buyer, amount); 
  }

  function depositStake() public payable {
    _data.seller = msg.sender;
    uint256 stake = msg.value;
    stakes[_data.seller] = stakes[_data.seller] + stake;

    emit StakeDeposited(_data.seller, stake);
  }

  function releaseFunds(address payable seller) internal {
    require(seller == _data.seller);
    // add if statement for the escrow countdown or fulfilled function
    uint256 payout = deposits + stakes;
    seller.transfer(payout);
    deposits = 0;
    stakes = 0;
  } 
  // ADD ESCROW COUNTDOWN
  // ADD fee calculator and overall functionality

  // Finalize agreement, check that everything is set, and start countdown
  function finalize() internal {
    require(_data.admin != address(0) && _data.buyer != address(0) && _data.seller != address(0) && _data.paymentAmount != 0 && _data.stakeAmount != 0 && _data.agreementParams[0] != 0 && _data.agreementParams[1] != 0, "Contract not initialized, check if you deposited funds correctly.");
    Countdown._start();
    emit Finalized();
  }

  // End the contract
  function end() internal {
    require(Countdown.getCountdownStatus() == isOver);
    releaseFunds();
    emit Ended();
  }

  // Punish functio for the buyer to use if the service was dissatisfactory
  // Also ends the contract
  function punish() public payable {
    uint256 correctDeposit;
    require(Countdown.getCountdownStatus() == isActive); // can only be used before the countdown is over
    require(_data.buyer == msg.sender, "Only buyer can use this function");
    correctDeposit = _data.stakeAmount / _data.agreementParams.ratio;
    require(msg.value >= correctDeposit, "Insufficient funds provided");
    _data.admin.transfer(msg.value); //Transfer the fee to admin account 
    _data.admin.transfer(deposits + stakes); //ToDo: add separate function for releasing funds to admin
    emit Ended();
  }

}
