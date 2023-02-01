const { ethers } = require("hardhat");
const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

/**
A new cool lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

What could go wrong, right ?

You start with no DVT tokens in balance, and the pool has 1.5 million. Your goal is to take them all.
 */
describe("[Challenge] Selfie", function () {
  let deployer, player;
  let token, governance, pool, selfieHack;

  const TOKEN_INITIAL_SUPPLY = 2000000n * 10n ** 18n;
  const TOKENS_IN_POOL = 1500000n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, player] = await ethers.getSigners();

    // Deploy Damn Valuable Token Snapshot
    token = await (
      await ethers.getContractFactory("DamnValuableTokenSnapshot", deployer)
    ).deploy(TOKEN_INITIAL_SUPPLY);

    // Deploy governance contract
    governance = await (
      await ethers.getContractFactory("SimpleGovernance", deployer)
    ).deploy(token.address);
    expect(await governance.getActionCounter()).to.eq(1);

    // Deploy the pool
    pool = await (
      await ethers.getContractFactory("SelfiePool", deployer)
    ).deploy(token.address, governance.address);
    expect(await pool.token()).to.eq(token.address);
    expect(await pool.governance()).to.eq(governance.address);

    // Fund the pool
    await token.transfer(pool.address, TOKENS_IN_POOL);
    await token.snapshot();
    expect(await token.balanceOf(pool.address)).to.be.equal(TOKENS_IN_POOL);
    expect(await pool.maxFlashLoan(token.address)).to.eq(TOKENS_IN_POOL);
    expect(await pool.flashFee(token.address, 0)).to.eq(0);
  });

  it("Execution", async function () {
    /** CODE YOUR SOLUTION HERE */
    hack = await (
      await ethers.getContractFactory("SelfieHack", player)
    ).deploy(token.address, pool.address, governance.address);
    await hack.attack();
    await time.increase(time.duration.days(3));
    await hack.attack2();
  });

  after(async function () {
    /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

    // Player has taken all tokens from the pool
    expect(await token.balanceOf(player.address)).to.be.equal(TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.be.equal(0);
  });
});
