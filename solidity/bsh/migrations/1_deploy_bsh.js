const BSHPeriphery = artifacts.require("BSHPeriphery");
const BSHCore = artifacts.require("BSHCore");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const fs = require('fs')

module.exports = async function (deployer, network) {
  if (network !== "development") {
    await deployProxy(BSHCore, [process.env.BSH_COIN_URL, process.env.BSH_COIN_NAME, parseInt(process.env.BSH_COIN_FEE)], { deployer });
    await deployProxy(BSHPeriphery, [process.env.BMC_PERIPHERY_ADDRESS, BSHCore.address, process.env.BSH_SERVICE], { deployer });
    const bshCore = await BSHCore.deployed();
    await bshCore.updateBSHPeriphery(BSHPeriphery.address);


    let filename = process.env.CONFIG_DIR + "/bsh.moonbeam"
    fs.writeFileSync(filename, BSHPeriphery.address, function (err, data) {
      if (err) {
        return console.log(err);
      }
    });
  }
};
