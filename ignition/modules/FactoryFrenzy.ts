import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("FactoryFrenzyModule", (m) => {
    // Replace with your deployed FractonToken address
    const fractonTokenAddress = "0xYourFractonTokenAddressHere";

    // Deploy FactoryFrenzy with the existing token
    const factory = m.contract("FactoryFrenzy", [fractonTokenAddress]);

    return { factory };
});
