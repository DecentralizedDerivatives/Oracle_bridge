var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "other tray hint valid buyer fiscal patch fly damp ocean produce wish";
//0xe5078b80b08bd7036fc0f7973f667b6aa9b4ddbe

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gasPrice: 1,
      network_id: "*" // Match any network id
    },
    dev2: {
      host: "localhost",
      port: 8546,
      network_id: "*" // Match any network id
    },
    // poa:  {
    //   provider: new HDWalletProvider(mnemonic, "http://54.174.159.43:8540"),
    //   network_id:"*",
    //   gas: 4612388
    // },
    // ropsten: {
    //   provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io"),
    //   network_id: 3,
    //   gas: 4612388
    // }
  }
};