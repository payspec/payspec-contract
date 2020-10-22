var NametagToken = artifacts.require("./NametagToken.sol");

var ethUtil =  require('ethereumjs-util');
var web3utils =  require('web3-utils');
var solidityHelper =  require('./solidity-helper');

var miningHelper =  require('./mining-helper');
var networkInterfaceHelper =  require('./network-interface-helper');


const Web3 = require('web3')
// Instantiate new web3 object pointing toward an Ethereum node.
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))

//https://web3js.readthedocs.io/en/1.0/web3-utils.html
//https://medium.com/@valkn0t/3-things-i-learned-this-week-using-solidity-truffle-and-web3-a911c3adc730



//Test _reAdjustDifficulty
//Test rewards decreasing


contract('NametagToken', function(accounts) {


    it("can deploy ", async function () {

      console.log( 'deploying token' )
      var contract = await NametagToken.deployed('Nametag Token','NTT');


  }),




  it("can be minted", async function () {

    var contract = await NametagToken.deployed('Nametag Token','NTT');

    var phrase = 'toast';

    var digest =  phraseToTokenIdHex(phrase)


    var expectedId = await contract.bytes32ToTokenId(phrase);
    var expectedHex = web3utils.numberToHex(expectedId);

    assert.equal(digest,expectedHex)

    console.log('token id is ',digest)
    //toast becomes 0x8ab847ce1beebbb46fa247bfa0b755f51635dbeb9160f29f0dcb634914060cbc

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
