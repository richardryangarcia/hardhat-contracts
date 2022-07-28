import { expect } from "chai";
import { ethers } from "hardhat";
const { MerkleTree } = require("merkletreejs");
import keccak256 from "keccak256";

describe("Edition", function () {
  it("Should allow mint while passing proof", async function () {
    const Edition = await ethers.getContractFactory("Edition");
    const edition = await Edition.deploy("Hello", "World");
    await edition.deployed();

    const address = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    const leaves = [
      address,
      "0xEF8ee5e8074B83473bD6Fd11902D75285FE61964",
      "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199",
    ];

    const tree = new MerkleTree(leaves, keccak256, {
      hashLeaves: true,
      sortPairs: true,
    });

    const root = tree.getRoot();
    const leaf = keccak256(address);
    const proof = tree.getHexProof(leaf);
    await edition.setMerkleRoot(root);

    const signers = await ethers.getSigners();

    await edition.connect(signers[0]).presaleMint(proof);
    const tokenId = await edition.getCurrentCounter();
    expect(tokenId).to.equal(1);
  });
});
