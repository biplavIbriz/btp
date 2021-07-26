const BMV = artifacts.require("BMV");
const SUB_BMV = artifacts.require("DataValidator");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const fs = require('fs')

module.exports = async function (deployer, network) {
  if (network !== "development") {
    await deployProxy(SUB_BMV, { deployer });
    await deployProxy(
      BMV,
      [
        process.env.BMC_CONTRACT_ADDRESS,
        SUB_BMV.address,
        process.env.BMV_ICON_NET,
        process.env.BMV_ICON_ENCODED_VALIDATORS,
        parseInt(process.env.BMV_ICON_INIT_OFFSET),
        parseInt(process.env.BMV_ICON_INIT_ROOTSSIZE),
        parseInt(process.env.BMV_ICON_INIT_CACHESIZE),
        process.env.BMV_ICON_LASTBLOCK_HASH,
      ],
      { deployer }
    );


    let filename = process.env.CONFIG_DIR + "/bmv.moonbeam"
    fs.writeFileSync(filename, BMV.address, function (err, data) {
      if (err) {
        return console.log(err);
      }
    });
  }
};