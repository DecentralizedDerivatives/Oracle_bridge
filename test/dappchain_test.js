var Bridge = artifacts.require("Bridge");
var PhotoCore = artifacts.require("PhotoCore");
var testAuction = artifacts.require("testAuction");

contract('Contracts', function(accounts) {
  let market;
  let core;
  let auction;


   beforeEach('Setup contract for each test', async function () {
      market = await PhotoMarket.new();
      core =await PhotoCore.new();
      auction = await testAuction.new();
        await market.setToken(core.address);
  		await core.setMarket(market.address);
  		await core.setAuction(auction.address);
  		await auction.setToken(core.address);
      await core.setWhitelist(market.address,true);
      await core.setWhitelist(auction.address,true);
      for(i=1;i<8;i++){
			await core.setWhitelist(accounts[i],true);
		}
   })