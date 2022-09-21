const cnft = artifacts.require("cnft");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("cnft", function (/* accounts */) {
  it("should assert true", async function () {
    await cnft.deployed();
    return assert.isTrue(true);
  });
});
