var PayspecV2 = artifacts.require("./PayspecV2.sol");
var FixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");

module.exports = function(deployer) {
  deployer.deploy(FixedSupplyToken).then(function(){

            return deployer.deploy(PayspecV2)
       });

};
