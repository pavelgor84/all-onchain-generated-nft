const fs = require("fs")
const { networkConfig } = require("../helper-hardhat-config")
const { ethers } = require("hardhat")

module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    log("----------------------------------------------")
    const SVGNFT = await deploy("SVGNFT", { from: deployer, log: true })
    log(`You have deployed an NFT contract at ${SVGNFT.address}`)
    let filePath = "./img/triangle.svg"
    let svg = fs.readFileSync(filePath, { encoding: "utf8" })
    const svgNFTContract = await ethers.getContractFactory("SVGNFT")
    const account = await hre.ethers.getSigners()
    const signer = account[0]
    const svgNFT = new ethers.Contract(SVGNFT.address, svgNFTContract.interface, signer)
    //const network = await ethers.getDefaultProvider().getNetwork();
    const networkName = networkConfig[chainId]['name']
    log(`Verify with: \n npx hardhat verify --network ${networkName} ${svgNFT.address} `)

    let transactinResponse = await svgNFT.create(svg)
    let receip = await transactinResponse.wait(1)
    log(`You have made an NFT`)
    log(`You can view the NFT here: ${await svgNFT.tokenURI(0)}`)
}

module.exports.tags = ['all', 'svg']
