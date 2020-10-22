
// old
//const NametagToken = artifacts.require("NametagToken");
//const OpenNFTExchange = artifacts.require("OpenNFTExchange");

//https://medium.com/@adrianmcli/migrating-your-truffle-project-to-web3-v1-0-ed3a56f11a4



var EthUtil = require('ethereumjs-util')

// v1.0
const { getWeb3, getContractInstance } = require("./web3helpers")
const web3 = getWeb3()
const getInstance = getContractInstance(web3)

const PayspecHelper = require('./payspec-helper')

var web3utils = web3.utils;



var myAccount;
var counterpartyAccount;
var feeAccount;


contract('payspecV2',(accounts) => {

  var fixedSupplyToken;
  var payspecV2;


  it(" can deploy ", async () => {
    fixedSupplyToken = getInstance("FixedSupplyToken");
    payspecV2 = getInstance("PayspecV2");


    console.log('payspec is ',payspecV2.options.address)


    myAccount = accounts[0];
    counterpartyAccount = accounts[1];
    feeAccount = accounts[2];

      console.log('my acct ', myAccount )
      console.log('counterparty acct ', counterpartyAccount )



    await fixedSupplyToken.methods.transfer(counterpartyAccount, 1000000 ).send({from:myAccount})


    assert.ok(fixedSupplyToken);
    assert.ok(payspecV2);
  }),




  it("invoice can be created with proper uuid ", async function () {



  balance = await web3.eth.getBalance(myAccount);
  console.log('eth balance is ', balance)


  let newInvoiceData = {
    description: 'testtx',
    nonce: 1,
    token: fixedSupplyToken.options.address,
    amountDue: 100,
    payTo: myAccount,
    feeAddresses: [ feeAccount ],
    feePercents: [ 2 ],
    expiresAt: 0
  }



  let getInvoiceUUIDArgsArray = Object.values(newInvoiceData)
  let actualInvoiceUUID;

  try {
     actualInvoiceUUID=  await payspecV2.methods.getInvoiceUUID.apply(this,getInvoiceUUIDArgsArray).call({ from: myAccount }) ;
  } catch (error) {
   console.trace(error)
  }


    console.log('actualInvoiceUUID',actualInvoiceUUID)
    assert.ok(actualInvoiceUUID);


    newInvoiceData.payspecContractAddress = payspecV2.options.address

    let expecteduuid = PayspecHelper.getExpectedInvoiceUUID( newInvoiceData )


    assert.equal(expecteduuid, actualInvoiceUUID);



  try {
    await payspecV2.methods.createAndPayInvoice.apply(argsArray).send({ from: myAccount, gas:3000000 }) ;
  } catch (error) {
    assert.fail("Method Reverted", "depositNFT",  error.reason);
  }



  });



    it("invoice can be submitted ", async function () {




    let newInvoiceData = {
      description: 'testtx2',
      nonce: 2,
      token: fixedSupplyToken.options.address,
      amountDue: 100,
      payTo: myAccount,
      feeAddresses: [ feeAccount ],
      feePercents: [ 2 ],
      expiresAt: 0
    }

    let getInvoiceUUIDArgsArray = Object.values(newInvoiceData)

    let actualInvoiceUUID;

    try {
       actualInvoiceUUID=  await payspecV2.methods.getInvoiceUUID.apply(this,getInvoiceUUIDArgsArray).call({ from: myAccount }) ;
    } catch (error) {
     console.trace(error)
    }



      //inject the contract address here just to get the expected UUID in an offchain way
      let expecteduuid = PayspecHelper.getExpectedInvoiceUUID( Object.assign( {payspecContractAddress: payspecV2.options.address }, newInvoiceData )  )


      assert.equal( expecteduuid,actualInvoiceUUID );

      let finalInvoiceData = Object.assign(  newInvoiceData, {expecteduuid: expecteduuid } )




      let createAndPayArgsArray = Object.values( finalInvoiceData )

        console.log( 'finalInvoiceData', finalInvoiceData  , createAndPayArgsArray)

        let success;

          try {
            success = await payspecV2.methods.createAndPayInvoice.apply(this, createAndPayArgsArray ).send({ from: myAccount, gas:3000000 }) ;
          } catch (error) {
            console.trace( error )
          }

      assert.ok(success);

    });




  return //end tests here














    it("can approve  ", async function () {

    assert.isNotNull(nametagContract.options.address)

    var nftContractAddress = nametagContract.options.address;


    assert.equal( await nametagContract.methods.ownerOf(assetId).call(), myAccount)

    var exchangeAddress = openNFTExchange.options.address;


    try {

      await nametagContract.methods.approve(exchangeAddress, assetId).send({ from: myAccount, gas:3000000 })
    } catch (error) {
      assert.fail("Method Reverted", "approve",  error.reason);
    }


    //deposit the token
    try {
      await openNFTExchange.methods.depositNFT(nftContractAddress, assetId).send({ from: myAccount, gas:3000000 }) ;
    } catch (error) {
      assert.fail("Method Reverted", "depositNFT",  error.reason);
    }

    assert.equal( await openNFTExchange.methods.ownerOf(nftContractAddress,assetId).call(), myAccount)


    var tokenCurrencyAddress = fixedSupplyToken.options.address;

    //put up a 'sell' offer
    try {
      await openNFTExchange.methods.offerAssetForSale(nftContractAddress, assetId,tokenCurrencyAddress,100).send({ from: myAccount, gas:3000000 }) ;
    } catch (error) {
      assert.fail("Method Reverted", "depositNFT",  error.reason);
    }

    //another person accepts this offer


    //you bid on the item that is in their possession in the exchange


    //they accept your bid so the item goes to you



    //you withdraw the token
    try {
      await openNFTExchange.methods.withdrawNFT(nftContractAddress, assetId).send({ from: myAccount, gas:3000000 }) ;
    } catch (error) {
      assert.fail("Method Reverted", "withdrawNFT",  error.reason);
    }

    assert.equal( await openNFTExchange.methods.ownerOf(nftContractAddress,assetId).call(), 0)

    await nametagContract.methods.approve(exchangeAddress, assetId).send({ from: myAccount, gas:3000000 })

    await openNFTExchange.methods.depositNFT(nftContractAddress, assetId).send({ from: myAccount, gas:3000000 }) ;


    assert.equal( await openNFTExchange.methods.ownerOf(nftContractAddress,assetId).call(), myAccount)




    })




      it("can accept offchain bid  ", async function () {


        var nftContractAddress = nametagContract.options.address;


        var tokenCurrencyAddress = fixedSupplyToken.options.address;

        var exchangeAddress = openNFTExchange.options.address;

        var bidAmount = 100;

        let currentBlockNumber = await web3.eth.getBlockNumber()

        var expires = currentBlockNumber + 10000;




        assert.equal( await openNFTExchange.methods.ownerOf(nftContractAddress,assetId).call(), myAccount)


        await fixedSupplyToken.methods.approve(exchangeAddress, bidAmount  ).send({from: counterpartyAccount});


        var bid = ECDSAHelper.getOffchainBid(counterpartyAccount,nftContractAddress,assetId, tokenCurrencyAddress,bidAmount,  expires ) ;
        console.log('bid',bid)
        var bidTuple = ECDSAHelper.bidToTuple(bid)

        var bidHash = await openNFTExchange.methods.getBidPacketHash(bidTuple).call()
        console.log('contract bidhash',bidHash)

        var typedDataHash =  await openNFTExchange.methods.getBidTypedDataHash(bidTuple).call()
        console.log('contract typeddatahash ',typedDataHash)


        //not working
        var localTypedDataHash = ECDSAHelper.bufferToHex(ECDSAHelper.getBidTypedDataHash(bid, exchangeAddress));




        assert.equal( localTypedDataHash,typedDataHash );


        //ecsign not producing the right signature ?


        //Simulate metamask ------
          var counterpartyPrivateKey="99f7cd424c1f234e3a7ae7e0778d65a254e8e25c2a7fea3c7df9ba358c46e3d1";
          var messageToSign = typedDataHash;

          var msgHash = (EthUtil.toBuffer(messageToSign));
          var signatureBuffer = EthUtil.ecsign(msgHash, new Buffer(counterpartyPrivateKey, 'hex'));
         var signatureRPC = EthUtil.toRpcSig(signatureBuffer.v, signatureBuffer.r, signatureBuffer.s).toString('hex')
         //------ end simulate metamask

         console.log('sig',signatureRPC);
         console.log('bid tuple',bidTuple);


         var sigDecoded = EthUtil.fromRpcSig(signatureRPC)

        var recoveredPubKey = EthUtil.ecrecover(msgHash,sigDecoded.v,sigDecoded.r,sigDecoded.s)


        var recoveredAddress = EthUtil.pubToAddress(recoveredPubKey).toString("hex")

        //this isnt working
        assert.equal('0x'.concat(recoveredAddress).toLowerCase(),counterpartyAccount.toLowerCase())
         console.log('recoveredAddress',recoveredAddress);

      var addy =    await openNFTExchange.methods.getSigner(bidTuple,signatureRPC).call()
      console.log('addy',addy)

         await openNFTExchange.methods.acceptOffchainBidWithSignature(bidTuple,signatureRPC).send({from: myAccount, gas:3000000})


        //add domain typehash
        // https://ethvigil.com/docs/eip712_sign_example_code/


      });


});



/*
This method is crucial for all apps and dapps that will implement NametagToken (NTT)

This method allows the dapp to take a 'nametag' phrase (@bob) and get the hex token id for that phrase
Then, the dapp can ask the contract for the owner of the token with that id!   This is the account holding the nametag
*/

function phraseToTokenIdHex(phrase)
{
  var phraseBytes32 = web3utils.asciiToHex(phrase)

  var paddedPhraseBytes32 = web3utils.rightPad(phraseBytes32,64)

  var digest =  web3utils.soliditySha3(paddedPhraseBytes32 )

  return digest;
}



function leftPad(value, length) {
    return (value.toString().length < length) ? leftPad("0"+value, length):value;
}




async function printBalances(accounts) {
  // accounts.forEach(function(ac, i) {
     var balance_val = await (web3.eth.getBalance(accounts[0]));
     console.log('acct 0 balance', web3utils.fromWei(balance_val.toString() , 'ether') )
  // })
 }
