const { expect } = require("chai");
const { ethers } = require("hardhat");

// 1. fixturesを使うための関数import
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("mint関連機能のテスト", function () {

  // 2. セットアップ処理の内容を記載。デプロイやウォレット取得を行う
  async function deployNftFixture() {
    const nft = await ethers.getContractFactory("EibaKatsuSecondGenerative");

    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatToken = await nft.deploy(
      'NFT',
      'NF',
      'ipfs//metadataのCID/'
    );
    await hardhatToken.deployed();

    // 3. itから呼ばれた際に、返却する変数たちを定義
    return { nft, hardhatToken, owner, addr1, addr2 };
  }

  it("mint関数を叩いたら、ウォレットにNFTが紐つけられること", async function () {
    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { hardhatToken, addr1 } = await loadFixture(deployNftFixture);

    await hardhatToken.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.0005") });

    const tokenIds = await hardhatToken.walletOfOwner(addr1.address);

    expect(tokenIds).to.deep.equal([ ethers.BigNumber.from("1") ]);
  });

  it("Ownerは0ETHでmintできること", async function () {
    // 1. loadFixtureを通して、セットアップ済みのOwnerウォレットを取得しておく
    const { hardhatToken, owner } = await loadFixture(deployNftFixture);

    // 2. ownerのウォレットで接続して、0ETHでmint関数を叩く
    await hardhatToken.connect(owner).mint(1, { value: ethers.utils.parseEther("0") });

    // 3. ownerアドレスが持つNFTのIDを取得
    const tokenIds = await hardhatToken.walletOfOwner(owner.address);

    // 4. ID1がownerのウォレットに紐ついていること
    expect(tokenIds).to.deep.equal([ ethers.BigNumber.from("1") ]);
  });
});