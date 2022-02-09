const fs = require("fs")
const { ethers } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config")

module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = getChainId()

    log("----------------------------------------------")
    const SVGNFT = await deploy("SVGNFT", { from: deployer, log: true })
    log(`You have deployed an NFT contract at ${SVGNFT.address}`)
    let filePath = "./img/triangle.svg"
    let svg = fs.readFileSync(filePath, { encoding: "utf8" })
    const svgNFTContract = await ethers.getContractFactory("SVGNFT")
    const account = await hre.ethers.getSigners()
    const signer = account[0]
    const svgNFT = new ethers.Contract(SVGNFT.address, svgNFTContract.interface, signer)
    const networkName = networkConfig[chainId]['name']
    log(`Verify with: \n npx hardhat verify --network ${networkName} ${svgNFT.address} `)

    let transactinResponse = await svgNFT.create(svg)
    let receip = await transactinResponse.wait(1)
}

