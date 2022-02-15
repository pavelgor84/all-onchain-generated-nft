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
    }

}