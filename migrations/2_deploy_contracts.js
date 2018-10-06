var NametagToken = artifacts.require("./NametagToken.sol");

module.exports = function(deployer) {
  deployer.deploy(NametagToken,'Nametag Token','NTT');
};
