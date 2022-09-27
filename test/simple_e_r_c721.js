const SimpleERC721 = artifacts.require("SimpleERC721");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SimpleERC721", function (accounts) {
  it("should assert true", async function () {
    await SimpleERC721.deployed();
    return assert.isTrue(true);
  });

  it("mint NFTs", async function () {
    const simpleERC721Instance = await SimpleERC721.deployed();
    await simpleERC721Instance.mint(accounts[0], 1);
    await simpleERC721Instance.mint(accounts[0], 2);
    await simpleERC721Instance.mint(accounts[0], 3);
    const mintBalance = await simpleERC721Instance.balanceOf(accounts[0]);
    assert.equal(mintBalance, 3);
    assert.equal(await simpleERC721Instance.ownerOf(1), accounts[0]);
  });

  it("transfer NFTs to contract", async function () {
    const simpleERC721Instance = await SimpleERC721.deployed();
    await simpleERC721Instance.safeTransferFrom(
      accounts[0],
      simpleERC721Instance.address,
      1,
      { from: accounts[0] }
    );
    const transferBalance = await simpleERC721Instance.balanceOf(
      simpleERC721Instance.address
    );
    assert.equal(transferBalance, 1);

    const owner = await simpleERC721Instance.ownerOf(1);
    assert.equal(owner, simpleERC721Instance.address);

    // console.log(
    //   await simpleERC721Instance.checkSentNFTs({ from: accounts[0] })
    // );
  });

  it("return NFTs from contract to sender", async function () {
    const simpleERC721Instance = await SimpleERC721.deployed();
    // console.log(simpleERC721Instance.address);
    await simpleERC721Instance.returnNFT(simpleERC721Instance.address, 1, {
      from: accounts[0],
    });
    const finalOwner = await simpleERC721Instance.ownerOf(1);
    assert.equal(finalOwner, accounts[0]);
  });
});
