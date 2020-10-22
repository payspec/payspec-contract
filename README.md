
 ## SendERC PaySpec

An Invoice System for ERC20 Tokens that helps merchants accept payment from users with a simple API.

________

Potential Issues:

-Any tokens that get 'approved' to the contract can be spent by someone else on invoices.   
-overpaying on an invoice is allowed.  If this happens, more tokens will be approved than necessary.



## HOW TO TEST

npm install -g ganache-cli  (https://github.com/trufflesuite/ganache-cli)
> npm run ganache

> npm run test


### Published contracts on ROPSTEN
https://ropsten.etherscan.io/address/0x8536d19aeeaadd64e9e7caf8681a45d38a5126ad#code
