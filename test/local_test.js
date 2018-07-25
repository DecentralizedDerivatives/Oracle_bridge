//Note this test just runs everything 8545
//First start ganache-cli
//Then run ethereum-bridge
//Then run truffle test

function promisifyLogWatch(_event) {
  return new Promise((resolve, reject) => {
    _event.watch((error, log) => {
      _event.stopWatching();
      if (error !== null)
        reject(error);

      resolve(log);
    });
  });
}

var DappBridge = artifacts.require("./DappBridge.sol");
var Bridge = artifacts.require("./Bridge.sol");
var OAR = "0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475";
var local_url = "json(https://purple-dingo-83.localtunnel.me).result"
contract('Contracts', function(accounts) {
  let dappBridge;
  let bridge;
  let logNewPriceWatcher_d;
  let logNewPriceWatcher_b;

   beforeEach('Setup contract for each test', async function () {
      dappBridge = await DappBridge.new();
      bridge =await Bridge.new();
      logNewPriceWatcher_d = promisifyLogWatch(dappBridge.LogUpdated({ fromBlock: 'latest' }));
      logNewPriceWatcher_b = promisifyLogWatch(bridge.LogUpdated({ fromBlock: 'latest' }));
      await dappBridge.setOAR(OAR);
      await bridge.setOAR(OAR);
      await dappBridge.setAPI(local_url);
      await bridge.setAPI(local_url);
      await dappBridge.setPartnerBridge(bridge.address);
      await bridge.setPartnerBridge(dappBridge.address);
		});
    it('Main to sidechain', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      assert.equal(myId,1,"myId should be 1")
      var res = await bridge.getTransfer(1);
      assert.equal(res[0]-web3.toWei(1,'ether'),0,"Correct 0 field")
      assert.equal(accounts[0],res[1],"Correct 1 field")
      assert.equal(res[2]-1,0,"Correct 2 field")
      await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
      log = await logNewPriceWatcher_d;
      assert.equal(log.event, 'LogUpdated', 'LogCallback not emitted.');
      bal =await dappBridge.balanceOf(accounts[0]);
      assert.equal(web3.toWei(1,'ether')-bal,0,"Account 0 should have dapptokens")
    });
    it('Back from sidechain', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
      log = await logNewPriceWatcher_d;
      receipt = await dappBridge.lockForTransfer(web3.toWei(1,'ether'),{from:accounts[0]});
      assert.equal(0,await dappBridge.balanceOf(accounts[0]),"Account 0 should have no dapptokens")
      myId = receipt.logs[0].args._id;
      assert.equal(myId,1,"myId should be 1")
       var res = await dappBridge.getTransfer(1);
      assert.equal(res[0]-web3.toWei(1,'ether'),0,"Correct 0 field")
      assert.equal(accounts[0],res[1],"Correct 1 field")
      assert.equal(res[2]-1,0,"Correct 2 field")
      await bridge.checkChild(myId,{value:web3.toWei(.1,'ether')});
      log = await logNewPriceWatcher_b;
      assert.equal(web3.toWei(1,'ether'),await bridge.depositedBalanceOf(accounts[0]),"Account 0 should have a deposited Balance")
      var balance = await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0));
      await bridge.withdraw({from:accounts[0]});
      assert.equal(await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0)),parseInt(balance) + 1,"Balances should be the same");
    });
    it('Multiple withdraws', async function () {
      var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
      var myId = receipt.logs[0].args._id;
      await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
      log = await logNewPriceWatcher_d;
      await dappBridge.transfer(accounts[1],web3.toWei(.4,'ether'),{from:accounts[0]})
        assert.equal(web3.toWei(.6,'ether'),await dappBridge.balanceOf(accounts[0]),"Account 0 should have .6e18 dapptokens")
        assert.equal(web3.toWei(.4,'ether'),await dappBridge.balanceOf(accounts[1]),"Account 1 should have .4e18 dapptokens")
      receipt = await dappBridge.lockForTransfer(web3.toWei(.6,'ether'),{from:accounts[0]});
      myId = receipt.logs[0].args._id;
      await bridge.checkChild(myId,{value:web3.toWei(.1,'ether')});
      log = await logNewPriceWatcher_b;
      receipt = await dappBridge.lockForTransfer(web3.toWei(.4,'ether'),{from:accounts[1]});
      myId = receipt.logs[0].args._id;
      var res = await dappBridge.getTransfer(myId);
      assert.equal(res[0]-web3.toWei(.4,'ether'),0,"Correct 0 field")
      assert.equal(accounts[1],res[1],"Correct 1 field")
      assert.equal(res[2]-myId,0,"Correct 2 field")
      await bridge.checkChild(myId,{from:accounts[1],value:web3.toWei(.1,'ether')});
      logNewPriceWatcher_b = promisifyLogWatch(bridge.LogUpdated({ fromBlock: 'latest' }));
      log = await logNewPriceWatcher_b;
      var bal1 = await bridge.depositedBalanceOf(accounts[1]);
      var bal0 = await bridge.depositedBalanceOf(accounts[0]);
      assert.equal(web3.toWei(.4,'ether'),parseInt(bal1),"Account 1 should have a deposited Balance")
      assert.equal(web3.toWei(.6,'ether'),parseInt(bal0),"Account 0 should have a deposited Balance")
      var balance = await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1));
      await bridge.withdraw({from:accounts[1]});
      assert(await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1)) >= parseInt(balance) + .3);
    });
   })