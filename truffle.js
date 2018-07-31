var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "governments of the industrial world you weary giants of flesh and steel"
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
    poa: {
      provider: new HDWalletProvider(mnemonic, "http://54.174.159.43:8540"),
      network_id:"*",
      gas: 4700000,
      gasPrice: 5001
    },
    ropsten: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/zkGX3Vf8njIXiHEGRueB"),
      network_id: 3,
      gas: 4700000,
      gasPrice: 17e9
    },
     rinkeby: {
      provider: new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/zkGX3Vf8njIXiHEGRueB"),
      network_id: 4,
      gas: 4700000,
      gasPrice: 17e9
    }
  }
};