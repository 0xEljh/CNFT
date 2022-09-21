const cnft = artifacts.require("cnft");

module.exports = function (deployer) {
  deployer.deploy(cnft);
};
