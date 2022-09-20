const test_royalties = artifacts.require("test_royalties");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("test_royalties", function (/* accounts */) {
  it("should assert true", async function () {
    await test_royalties.deployed();
    return assert.isTrue(true);
  });
});
