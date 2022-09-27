const cnftRoyalty = artifacts.require("cnftRoyalty");

module.exports = function (deployer) {
  deployer.deploy(cnftRoyalty);
};
