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
    let networkAddress = networkConfig[chainId]['name']
    log(`Verify with: \n npx hardhat verify --network ${networkAddress} ${RandomSVG.address} ${args.toString().replace(/,/g, " ")}`)

}
module.exports.tags = ['all', 'rsvg']