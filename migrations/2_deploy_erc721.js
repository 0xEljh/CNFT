const nft = artifacts.require("SimpleERC721");

module.exports = function (deployer) {
  deployer.deploy(nft);
};
