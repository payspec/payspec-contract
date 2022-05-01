import { Network } from 'hardhat/types'
import path from 'path'

import {
  AssetSettings,
  ATMs,
  Chainlink,
  Market,
  NetworkTokens,
  NFTMerkleTree,
  Nodes,
  PlatformSettings,
  Signers,
  TierInfo,
  Tokens,
} from '../types/custom/config-types'
 
 
import { nodes } from './nodes'
import { platformSettings } from './platform-settings'
import { signers } from './signers'
import { tokens } from './tokens'
 

/**
 * Checks if the network is Ethereum mainnet or one of its testnets
 * @param network HardhatRuntimeEnvironment Network object
 * @return boolean
 */
export const isEtheremNetwork = (network: Network): boolean =>
  ['mainnet', 'kovan', 'rinkeby', 'ropsten'].some(
    (n) => n === getNetworkName(network)
  )

export const getNetworkName = (network: Network): string =>
  process.env.FORKING_NETWORK ?? network.name

export const getNodes = (network: Network): Nodes =>
  nodes[getNetworkName(network)]

export const getPlatformSettings = (network: Network): PlatformSettings =>
  platformSettings[getNetworkName(network)]

export const getSigners = (network: Network): Signers => signers[network.name]

export const getTokens = (
  network: Network
): NetworkTokens & { all: Tokens } => {
  const networkTokens = tokens[getNetworkName(network)]
  const all: Tokens = Object.keys(networkTokens).reduce((map, type) => {
    // @ts-expect-error keys
    map = { ...map, ...networkTokens[type] }
    return map
  }, {})
  return {
    ...networkTokens,
    all,
  }
}

export const getNativeToken = (network: Network): string => {
  const tokens = getTokens(network)
  let wrappedNativeToken: string
  const networkName = getNetworkName(network)
  if (
    networkName === 'mainnet' ||
    networkName === 'kovan' ||
    networkName === 'rinkeby' ||
    networkName === 'ropsten'
  ) {
    wrappedNativeToken = tokens.erc20.WETH
  } else {
    wrappedNativeToken = tokens.erc20.WMATIC
  }
  return wrappedNativeToken
}
