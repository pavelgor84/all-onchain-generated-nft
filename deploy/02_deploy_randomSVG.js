const { ethers } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config")

module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, get, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()
    let linkTokenAddress
    let vrfCoordinatorAddress

    //Need Mocks for local chain
    if (chainId == 31337) {
        let linkToken = await get('LinkToken')
        linkTokenAddress = linkToken.address
        let vrfCoordinator = await get('VRFCoordinatorMock')
        vrfCoordinatorAddress = vrfCoordinator.address

    }
    else {
        linkTokenAddress = networkConfig[chainId]['linkTokenAddress']
        vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinatorAddress']
    }

    let keyHash = networkConfig[chainId]['keyHash']
    let fee = networkConfig[chainId]['fee']
    args = [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee]
    log("------------------------------------------")
    const RandomSVG = await deploy('RandomSVG', { from: deployer, args: args, log: true })
    log("You have deployed your NFT contract!")
    let networkName = networkConfig[chainId]['name']
    log(`Verify with: \n npx hardhat verify --network ${networkName} ${RandomSVG.address} ${args.toString().replace(/,/g, " ")}`)
    const randomSVGContract = await ethers.getContractFactory("RandomSVG")
    const accounts = await hre.ethers.getSigners()
    const signer = accounts[0]
    const randomSVG = new ethers.Contract(RandomSVG.address, randomSVGContract.interface, signer)


    //fund with LINK
    const linkTokenContract = await ethers.getContractFactory("LinkToken")
    const linkToken = new ethers.Contract(linkTokenAddress, linkTokenContract.interface, signer)
    let fund_tx = await linkToken.transfer(RandomSVG.address, fee)
    await fund_tx.wait(1)

    //create an NFT by calling a random number
    let creation_tx = await randomSVG.create({ gasLimit: 300000 })
    let receipt = await creation_tx.wait(1)
    //log(`LOG ${JSON.stringify(receipt.events)}`)
    let tokenId = receipt.events[3].topics[2]
    log(`You've made your NFT. Your token number is ${tokenId.toString()}`)
    log(`Let's wait for the Chainlink tode to respond.`)

    if (chainId != 31337) {

    }
    else {

        //const VRFCoordinatorMock = await deployments.get('VRFCoordinatorMock')
        let vrfCoordinator = await ethers.getContractAt('VRFCoordinatorMock', vrfCoordinatorAddress, signer)
        let vrf_tx = await vrfCoordinator.callBackWithRandomness(receipt.events[3].topics[1], 77777, randomSVG.address)
        vrf_tx.wait(1)
        log("Now let's finish the mint!")
        let finish_tx = await randomSVG.finishMint(tokenId, { gasLimit: 2000000 })
        let res = finish_tx.wait(1)
        //log(`LOG: ${JSON.stringify(res.events)}`)
        log(`You can view tokenURI here ${await randomSVG.tokenURI(tokenId)}`)

    }


}
module.exports.tags = ['all', 'rsvg']