/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

const HDWalletProvider = require('@truffle/hdwallet-provider');
const privKeys = [
   '0x99B3C12287537E38C90A9219D4CB074A89A16E9CDB20BF85728EBD97C343E342',
   '0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133',
   '0x8075991ce870b93a8870eca0c0f91913d12f47948ca0fd25b49c6fa7cdbeee8b',
   '0x0b6e18cafb6ed99687ec547bd28139cafdd2bffe70e6b688025de6b445aa5c5b',
   '0x39539ab1876910bbf3a223d84a29e28f1cb4e2e456503e7e91ed39b2e7223d68',
   '0x7dce9bc8babb68fec1409be38c8e1a52650206a7ed90ff956ae8a6d15eeaaef4',
   '0xb9d2ea9a615f3165812e8d44de0d24da9bbd164b65c4f0573e1ce2c8dbd9c8df',
   '0x0d6dcaaef49272a5411896be8ad16c01c35d6f8c18873387b71fbc734759b0ab',
   '0x4c42532034540267bf568198ccec4cb822a025da542861fcb146a5fab6433ff8',
   '0x94c49300a58d576011096bcb006aa06f5a91b34b4383891e8029c21dc39fbb8b'
]; 
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();

const localProvider = () => new HDWalletProvider({
  privateKeys: [privKey],
  providerOrUrl: "http://localhost:9933",
});

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  
  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    ganache: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none) 
     gas: 12000000
    },
    development: {
      provider: () => {
         return new HDWalletProvider(privKeys, 'http://localhost:9933/')
      },
      network_id: 1281
   },
   edgewarelocal: {
    provider: localProvider,
    network_id: 2021,
    websocket: true
  },
  beresheet: {
    provider: () => new HDWalletProvider({
      privateKeys: [privKey],
      providerOrUrl: "https://beresheet7.edgewa.re",
      websocket: true
    }),
    confirmations: 3,
    network_id: 2021,
    production: true
  },
  moonbeamlocal: {
    provider: localProvider,
    network_id: 1287,
    websocket: true
  },
  moonbase: {
    provider: () => new HDWalletProvider({
      privateKeys: [privKey],
      providerOrUrl: "https://rpc.testnet.moonbeam.network",
    }),
    confirmations: 3,
    network_id: 1287,
    production: true
  },
    // Another network with more advanced options...
    //  advanced: {
	  //    host: "127.0.0.1",
    // 	 port: 7545,             // Custom port
    // 	 network_id: "*",       // Custom network
    // 	 gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    //    gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    // from: <address>,        // Account to send txs from (default: accounts[0])
    // websocket: true        // Enable EventEmitter interface for web3 (default: false)
    //  },
    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.
    // ropsten: {
    // provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/YOUR-PROJECT-ID`),
    // network_id: 3,       // Ropsten's id
    // gas: 5500000,        // Ropsten has a lower block limit than mainnet
    // confirmations: 2,    // # of confs to wait between deployments. (default: 0)
    // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    // },
    // Useful for private networks
    // private: {
    // provider: () => new HDWalletProvider(mnemonic, `https://network.io`),
    // network_id: 2111,   // This network is yours, in the cloud.
    // production: true    // Treats this network as if it was a public net. (default: false)
    // }
  },
//   plugins: ['moonbeam-truffle-plugin'],

  // Set default mocha options here, use special reporters etc.
    mocha: {
   //  timeout: 100000
    },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.7.6",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
       settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "petersburg"
      }
    }
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false
  }
};
