module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    if (chainId == 31337) {
        log("Local blockhain detected. Deploying mocks...")
        const LinkToken = await deploy('LinkToken', { from: deployer, log: true })
        const VRFCoordinator = await deploy('VRFCoordinatorMock', { from: deployer, log: true, args: [LinkToken.address] })
        log("Mocks deployed")
    }

}
module.exports.tags = ['svg', 'rsvg', 'all']