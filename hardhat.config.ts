// hardhat.config.ts
import type { HardhatUserConfig } from "hardhat/config";
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import * as dotenv from "dotenv";
dotenv.config();

const useMnemonic = !!process.env.MNEMONIC?.trim();

const config: HardhatUserConfig = {
    plugins: [hardhatToolboxViemPlugin],
    solidity: {
        profiles: {
            default: { version: "0.8.28" },
            production: {
                version: "0.8.28",
                settings: { optimizer: { enabled: true, runs: 200 } },
            },
        },
    },
    networks: {
        hardhatMainnet: { type: "edr-simulated", chainType: "l1" },
        hardhatOp: { type: "edr-simulated", chainType: "op" },

        // ✅ Amoy needs `type: "http"` (and chainType)
        amoy: {
            type: "http",
            chainType: "l1",
            url: process.env.AMOY_RPC_URL || "https://rpc-amoy.polygon.technology",
            chainId: 80002,
            accounts: useMnemonic
                ? {
                    mnemonic: process.env.MNEMONIC!,
                    path: "m/44'/60'/0'/0",
                    initialIndex: 0,
                    count: 1,
                }
                : [process.env.AMOY_PRIVATE_KEY || ""],
        },

        // (example) Sepolia also needs `type: "http"`
        sepolia: {
            type: "http",
            chainType: "l1",
            url: process.env.SEPOLIA_RPC_URL || "",
            accounts: useMnemonic
                ? {
                    mnemonic: process.env.MNEMONIC!,
                    path: "m/44'/60'/0'/0",
                    initialIndex: 0,
                    count: 1,
                }
                : [process.env.SEPOLIA_PRIVATE_KEY || ""],
        },
    }
};

export default config;
