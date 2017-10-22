var GroupBuyContract = artifacts.require("./GroupBuyContract.sol");

module.exports = function(deployer) {
  deployer.deploy(GroupBuyContract);
};
