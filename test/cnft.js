const cnft = artifacts.require("cnft");
const truffleAssert = require("truffle-assertions");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("cnft", function (accounts) {
  it("should assert true", async function () {
    await cnft.deployed();
    return assert.isTrue(true);
  });
  it("mint NFTs", async function () {
    const cnftInstance = await cnft.deployed();
    await cnftInstance.mint(accounts[0], 1);
    await cnftInstance.mint(accounts[0], 2);
    await cnftInstance.mint(accounts[0], 3);
    const mintBalance = await cnftInstance.balanceOf(accounts[0]);
    assert.equal(mintBalance, 3);
    assert.equal(await cnftInstance.ownerOf(1), accounts[0]);
  });
  it("transfer NFTs", async function () {
    const cnftInstance = await cnft.deployed();
    await cnftInstance.transferFrom(accounts[0], accounts[1], 1);
    const transferBalance = await cnftInstance.balanceOf(accounts[1]);
    assert.equal(transferBalance, 1);
    await truffleAssert.fails(
      cnftInstance.transferFrom(accounts[0], accounts[1], 2, {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT
    );
  });

  it("send NFTs to contract", async function () {
    const cnftInstance = await cnft.deployed();
    // must use safeTransferFrom to send to contract
    await cnftInstance.safeTransferFrom(accounts[0], cnftInstance.address, 2, {
      from: accounts[0],
    });
    const contractBalance = await cnftInstance.balanceOf(cnftInstance.address);
    assert.equal(contractBalance, 1);
    const sentNFTs = await cnftInstance.getReceivedNFTs(accounts[0]);
    assert(sentNFTs.length === 1);
    assert.equal(sentNFTs[0].tokenId, 2);
  });

  it("add childNFT to cnft", async function () {
    const cnftInstance = await cnft.deployed();
    // add childNFT(id: 2) to cnft(id: 3)
    await cnftInstance.addChildNFT(3, cnftInstance.address, 2, {
      from: accounts[0],
    });
    const childNFTs = await cnftInstance.getChildNFTs(3, {
      from: accounts[0],
    });
    assert.equal(childNFTs[0].tokenId, 2);
  });

  it("burn cnft", async function () {
    const cnftInstance = await cnft.deployed();

    truffleAssert.fails(
      cnftInstance.burn(3, { from: accounts[1] }),
      truffleAssert.ErrorType.REVERT
    );
    truffleAssert.fails(
      cnftInstance.burn(2, { from: accounts[0] }),
      truffleAssert.ErrorType.REVERT
    );

    await cnftInstance.burn(3, { from: accounts[0] });
    const burnBalance = await cnftInstance.balanceOf(accounts[0]);
    assert.equal(burnBalance, 1);
    assert.equal(await cnftInstance.ownerOf(2), accounts[0]);
  });
});
