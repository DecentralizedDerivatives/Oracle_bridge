//Note this test just runs everything 8545
//First start ganache-cli
//Then run ethereum-bridge
//Then run truffle test

var DappBridge = artifacts.require("./DappBridge.sol");
var Bridge = artifacts.require("./Bridge.sol");
var OAR = "";
contract('Contracts', function(accounts) {
  let dappBridge;
  let bridge;

   beforeEach('Setup contract for each test', async function () {
      dappBridge = await DappBridge.new();
      bridge =await Bridge.new();
      await dappBridge.setOAR(OAR);
      await bridge.setOAR(OAR):
      await dappBridge.setAPI("json(https://localhost:8545).result")
      await bridge.setAPI("json(https://localhost:8545).result")
      await dappBridge.setPartnerBridge(bridge.address);
      await bridge.setPartnerBridge(dappBridge.address);
		}
    it('Main to sidechain', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      assert.equal(myId,1,"myId should be 1")
      assert.equal([web3.toWei(1,'ether'),accounts[0],1],await bridge.getTransfer(1), "Transfer details should be correct");
      await dappBridge.checkMain(myId);
      assert.equal(web3.toWei(1,'ether'),await dappBridge.balanceOf(accounts[0]),"Account 0 should have dapptokens")
    }
    it('Back from sidechain', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      await dappBridge.checkMain(myId);
      receipt = await dappBridge.lockForTransfer(web3.toWei(1,'ether'),{from:accounts[0]});
      assert.equal(0,await dappBridge.balanceOf(accounts[0]),"Account 0 should have no dapptokens")
      myId = receipt.logs[0].args._id;
      assert.equal(myId,1,"myId should be 1")
      assert.equal([web3.toWei(1,'ether'),accounts[0],1],await dappBridge.getTransfer(myId), "Transfer details should be correct");
      await bridge.checkChild(myId);
      assert.equal(web3.toWei(1,'ether'),await bridge.depositedBalanceOf(accounts[0]),"Account 0 should have a deposited Balance")
      balance = await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0));
      await bridge.withdraw({from:accounts[0]});
      assert.equal(await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0)),balance + 1);
    }
    it('Multiple withdraws', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      await dappBridge.checkMain(myId);
      await dappBridge.transfer(accounts[1],web3.toWei(.4,'ether'),{from:accounts[0]}
        assert.equal(web3.toWei(.6,'ether'),await dappBridge.balanceOf(accounts[0]),"Account 0 should have .6e18 dapptokens")
        assert.equal(web3.toWei(.4,'ether'),await dappBridge.balanceOf(accounts[1]),"Account 0 should have .4e18 dapptokens")
      receipt = await dappBridge.lockForTransfer(web3.toWei(.6,'ether'),{from:accounts[0]});
      myId = receipt.logs[0].args._id;
      await bridge.checkChild(myId);
      receipt = await dappBridge.lockForTransfer(web3.toWei(.4,'ether'),{from:accounts[1]});
      myId = receipt.logs[0].args._id;
      assert.equal([web3.toWei(1,'ether'),accounts[0],1],await dappBridge.getTransfer(myId), "Transfer details should be correct");
      await bridge.checkChild(myId,{from:accounts[1]});
      
      assert.equal(web3.toWei(.4,'ether'),await bridge.depositedBalanceOf(accounts[1]),"Account 1 should have a deposited Balance")
      assert.equal(web3.toWei(.6,'ether'),await bridge.depositedBalanceOf(accounts[0]),"Account 0 should have a deposited Balance")
      balance = await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1));
      await bridge.withdraw({from:accounts[1]});
      assert.equal(await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1)),balance + .4);
    }
   })