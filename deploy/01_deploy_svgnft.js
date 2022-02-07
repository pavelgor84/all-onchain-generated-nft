module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const deployer = await getNamedAccounts()
    const chainId = getChainId()

    log("----------------------------------------------")
    
}