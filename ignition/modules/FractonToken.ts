import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

/**
 * FractonToken Ignition Module
 * - Deploys FractonToken with an initial supply (defaults to 1,000,000 tokens @ 18 decimals).
 * - You can override `initialSupply` via an Ignition parameters file or CLI.
 */
export default buildModule("FractonTokenModule", (m) => {
    // 1,000,000 * 10^18 (default)
    const defaultInitialSupply = 1_000_000n * (10n ** 18n);

    // Parameter is a bigint of the *raw* token units (wei-like, i.e., 18 decimals)
    const initialSupply = m.getParameter<bigint>("initialSupply", defaultInitialSupply);

    const fractonToken = m.contract("FractonToken", [initialSupply]);

    return { fractonToken };
});
