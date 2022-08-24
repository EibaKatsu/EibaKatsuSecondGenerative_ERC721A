const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("mint関連機能のテスト", function () {
  it("mint関数を叩いたら、ウォレットにNFTが紐つけられること", async function () {
    // 1. ソースコードからスマートコントラクトを生成する
    const nft = await ethers.getContractFactory("EibaKatsuSecondGenerative");

    // 2. テストに使うウォレットアドレスを作成する
    const [owner, addr1, addr2] = await ethers.getSigners();

    // 3. スマートコントラクトをローカルネットワークにデプロイする
    const hardhatToken = await nft.deploy(
      'NFT',
      'NF',
      'ipfs//metadataのCID/'
    );

    // 4. オーナー以外のウォレットを接続しスマートコントラクトのmint関数を叩く
    await hardhatToken.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.0005") });

    // 5. スマートコントラクトにウォレットアドレスを渡して、NFTのIDリストを取得
    const tokenIds = await hardhatToken.walletOfOwner(addr1.address);

    // 6. ID1 のNFTがウォレットと紐ついていること
    expect(tokenIds).to.deep.equal([ ethers.BigNumber.from("1") ]);
  });
});