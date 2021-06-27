import Web3 from "web3";
import Escrow from "./contracts/Escrow.json";

const options = {
  web3: {
    fallback: {
        type: "ws",
        url: "ws://127.0.0.1:9545",
    },
  },
  contracts: [Escrow],
  events: {
    Escrow: ["Initialized", "Finalized", "StakeDeposited", "PaymentDeposited", "Cancelled", "Ended"],
  },
};

export default options;
