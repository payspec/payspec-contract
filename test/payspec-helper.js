
var web3utils = require('web3-utils')


module.exports =  {




     getExpectedInvoiceUUID( invoiceData )
   {
     var payspecContractAddress = invoiceData.payspecContractAddress;
     var description = invoiceData.description;
     var nonce =invoiceData.nonce;
     var token =invoiceData.token;
     var amountDue =invoiceData.amountDue;
     var payTo =invoiceData.payTo;

     var feeAddresses = {t: 'address[]' , v:invoiceData.feeAddresses}
     var feePercents = {t: 'uint256[]' , v:invoiceData.feePercents}
     var expiresAt =invoiceData.expiresAt;

   

     return web3utils.soliditySha3(
       payspecContractAddress,
       description,
       nonce,
       token,
       amountDue,
       payTo,
       feeAddresses,
       feePercents,
       expiresAt );
   }

 }
