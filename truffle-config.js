require("babel-register");
require("babel-polyfill");

const HDWalletProvider = require("truffle-hdwallet-provider");
require("dotenv").config();

const mnemonic = process.env.MNEMONIC || "onther tokyo onther tokyo onther tokyo onther tokyo onther tokyo onther tokyo";
const providerUrl = "https://ropsten.infura.io";

const providerRopsten = new HDWalletProvider(mnemonic, providerUrl, 0, 50);

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 4700000,
      gasPrice: 20e9,
    },
    ropsten: {
      network_id: 3,
      provider: providerRopsten,
      gas: 4700000,
      gasPrice: 100e9,
    },
    mainnet: {
      host: "onther.io",
      port: 60001,
      network_id: "1",
      from: "0x07bfd26f09a90564fbc72f77758b0259b65b783b",
      gas: 4700000,
      gasPrice: 25e9,
    },
    onther: {
      host: "onther.io",
      port: 60010,
      network_id: "777",
      from: "0x71283a1d35f63e35a34476f6ad0a85a49317181b", // accounts[0]
      gas: 4700000,
      gasPrice: 18e9,
    },
  },
};
