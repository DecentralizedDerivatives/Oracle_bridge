//Note this test just runs everything 8545
//First start ganache-cli
//Then run ethereum-bridge
//Then run truffle test

function wait(ms){
   var start = new Date().getTime();
   var end = start;
   while(end < start + ms) {
     end = new Date().getTime();
  }
}

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
contract('Contracts', function(accounts) {
  let dappBridge;
  let bridge;

   beforeEach('Setup contract for each test', async function () {
    console.log('Account 0',accounts[0])
      dappBridge = await DappBridge.new();
      bridge =await Bridge.new();
      await dappBridge.setOAR(OAR);
      await bridge.setOAR(OAR);
      await dappBridge.setAPI("json(https://brown-chicken-27.localtunnel.me).result");
      await bridge.setAPI("json(https://brown-chicken-27.localtunnel.me).result");
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
      console.log('await bridge.getTransfer(1)',res)
      await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
     const logNewPriceWatcher = promisifyLogWatch(dappBridge.Print({ fromBlock: 'latest' }));
      log = await logNewPriceWatcher;
      assert.equal(log.event, 'Print', 'LogCallback not emitted.')
      console.log('Args',log.args);
        bal =await dappBridge.balanceOf(accounts[0]);
        console.log('Bal',bal);

      assert.equal(web3.toWei(1,'ether')-bal,0,"Account 0 should have dapptokens")
    });
    // it('Back from sidechain', async function () {
    //   var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
    //   var myId = receipt.logs[0].args._id;
    //   await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
    //   receipt = await dappBridge.lockForTransfer(web3.toWei(1,'ether'),{from:accounts[0]});
    //   assert.equal(0,await dappBridge.balanceOf(accounts[0]),"Account 0 should have no dapptokens")
    //   myId = receipt.logs[0].args._id;
    //   assert.equal(myId,1,"myId should be 1")
    //   assert.equal([web3.toWei(1,'ether'),accounts[0],1],await dappBridge.getTransfer(myId), "Transfer details should be correct");
    //   await bridge.checkChild(myId,{value:web3.toWei(.1,'ether')});
    //   assert.equal(web3.toWei(1,'ether'),await bridge.depositedBalanceOf(accounts[0]),"Account 0 should have a deposited Balance")
    //   balance = await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0));
    //   await bridge.withdraw({from:accounts[0]});
    //   assert.equal(await (web3.fromWei(web3.eth.getBalance(accounts[0]), 'ether').toFixed(0)),balance + 1);
    // });
    // it('Multiple withdraws', async function () {
    //   var receipt = await bridge.lockForTransfer({from:accounts[0],value:web3.toWei(1,'ether')})
    //   var myId = receipt.logs[0].args._id;
    //   await dappBridge.checkMain(myId,{value:web3.toWei(.1,'ether')});
    //   await dappBridge.transfer(accounts[1],web3.toWei(.4,'ether'),{from:accounts[0]})
    //     assert.equal(web3.toWei(.6,'ether'),await dappBridge.balanceOf(accounts[0]),"Account 0 should have .6e18 dapptokens")
    //     assert.equal(web3.toWei(.4,'ether'),await dappBridge.balanceOf(accounts[1]),"Account 0 should have .4e18 dapptokens")
    //   receipt = await dappBridge.lockForTransfer(web3.toWei(.6,'ether'),{from:accounts[0]});
    //   myId = receipt.logs[0].args._id;
    //   await bridge.checkChild(myId,{value:web3.toWei(.1,'ether')});
    //   receipt = await dappBridge.lockForTransfer(web3.toWei(.4,'ether'),{from:accounts[1]});
    //   myId = receipt.logs[0].args._id;
    //   assert.equal([web3.toWei(1,'ether'),accounts[0],1],await dappBridge.getTransfer(myId), "Transfer details should be correct");
    //   await bridge.checkChild(myId,{from:accounts[1],value:web3.toWei(.1,'ether')});
      
    //   assert.equal(web3.toWei(.4,'ether'),await bridge.depositedBalanceOf(accounts[1]),"Account 1 should have a deposited Balance")
    //   assert.equal(web3.toWei(.6,'ether'),await bridge.depositedBalanceOf(accounts[0]),"Account 0 should have a deposited Balance")
    //   balance = await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1));
    //   await bridge.withdraw({from:accounts[1]});
    //   assert.equal(await (web3.fromWei(web3.eth.getBalance(accounts[1]), 'ether').toFixed(1)),balance + .4);
    // });
   })