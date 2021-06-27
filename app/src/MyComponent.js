import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import logo from "./logo.png";

const { AccountData, ContractData, ContractForm } = newContextComponents;

export default ({ drizzle, drizzleState }) => {
  // destructure drizzle and drizzleState from props
  return (
      <div>
      <h1>PIK Your Tutor</h1>
      <ContractForm contract="Escrow" method="depositPayment"></ContractForm>
      </div>
  );
};
