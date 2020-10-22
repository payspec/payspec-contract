
 ## SendERC PaySpec

An Invoice System for ERC20 Tokens that helps merchants accept payment from users with a simple API.


#### How it works 

Imagine a situation where one party, the 'seller', wants to sell an asset 'X' for a predetermined amount of ERC20 tokens Y.   First, the seller constructs a JSON object offchain like this: 


    let newInvoiceData = {
      description: 'assetXname', //can be anything
      nonce: 2, //randomly generated number 
      token: fixedSupplyToken.options.address,  //contract address of token for payment 
      amountDue: 100,   //raw amount of token to pay this invoice 
      payTo: sellerAddress,   
      feeAddresses: [ feeAccount ],  //addresses of any third parties that should take a % fee for this transaction, like a website this invoice flows through  (optional) 
      feePercents: [ 2 ], //fee amounts of feeAddresses
      expiresAt: 0    //block number that this invoice will expire on (0 for never expire) 
    }
    
    
  Now, the seller will run this through the static method 
  
      getInvoiceUUID(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint expiresAt  ) public view returns (bytes32 uuid) 
  
  This will give the seller the universally unique ID (UUID) corresponding to this invoice.  No other invoice will ever have this particular UUID and the seller will use this UUID in order to track and trace whether or not this invoice is paid.
  
  
  Now, the seller gives this invoice data to potential buyers along with the UUID (or the buyer can compute the UUID.)  
  
  The buyer will approve tokens to the Payspec contract and then call this method: 

      createAndPayInvoice(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint256 ethBlockExpiresAt, bytes32 expecteduuid  ) public returns (bool)  
  
   
   This method will make the pre-approved ERC20 tokens in quantity 'AmountDue' flow from the buyer's account and into the sellers account and it will permanently mark this invoice as being 'paid' so that anyone can check the UUID and the contract will report that it has been 'paid'.  At that point, the seller (or a bot running by the seller) can check the 'paid' status of the corresponding UUID and deliver the sold asset to the buyer.  This does require that the buyer trust the seller to actually deliver the item.  
   
   
   Considerations:
   
     If the buyer tries to change any of the data, the UUID will change and the the order will not be considered paid. The UUID is the SHA3 hash of all of the invoice data, including the contract address. 
    
    
   
________

 
## HOW TO TEST

npm install -g ganache-cli  (https://github.com/trufflesuite/ganache-cli)
> npm run ganache

> npm run test


### Published contracts on ROPSTEN
https://ropsten.etherscan.io/address/0x8536d19aeeaadd64e9e7caf8681a45d38a5126ad#code
