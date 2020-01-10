var SendERC = artifacts.require("./SendERC.sol");

module.exports = function(deployer) {
  deployer.deploy(SendERC);
};
