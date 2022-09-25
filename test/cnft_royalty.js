const cnftRoyalty = artifacts.require("cnftRoyalty");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("cnftRoyalty", function (accounts) {
  it("mint NFTs", async function () {
    const cnftInstance = await cnftRoyalty.deployed();
    await cnftInstance.mint(accounts[0], 1);
    await cnftInstance.mint(accounts[0], 2);
    await cnftInstance.mint(accounts[0], 3);
    const mintBalance = await cnftInstance.balanceOf(accounts[0]);
    assert.equal(mintBalance, 3);
    assert.equal(await cnftInstance.ownerOf(1), accounts[0]);
  });
  it("Royalty transfer", async function () {
    const cnftRoyaltyInstance = await cnftRoyalty.deployed();
    const transactionAmount = web3.utils.toWei("0.001", "ether");

    const royaltyInfo = await cnftRoyaltyInstance.royaltyInfo(
      1,
      transactionAmount
    );
    assert(royaltyInfo[0] !== accounts[0]);
    assert(royaltyInfo[0] !== cnftRoyaltyInstance.address);
    assert.equal(royaltyInfo[1], transactionAmount / 10);
    // console.log((await cnftRoyaltyInstance.getBalance()).toNumber());

    // make payment to the contract with a royalty amount
    await cnftRoyaltyInstance.sendTransaction({
      from: accounts[1],
      to: royaltyInfo[0],
      value: royaltyInfo[1],
    });
    // console.log(royaltyInfo[1].toNumber());
    const contractBalance = await cnftRoyaltyInstance.getBalance();
    // console.log(contractBalance.toNumber());
    assert.equal(
      contractBalance.toNumber(),
      transactionAmount / 10 / 100 // royalty = 10%, tax = 1%
    );
  });
});
