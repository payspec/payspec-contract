pragma solidity ^0.4.24;

import "./ERC721/ERC721Metadata.sol";




/*

NAMETAG TOKEN

An ERC721 non-fungible token with the hash of your unique Alias imprinted upon it.

Register your handle by minting a new token with that handle.
Then, others can send Ethereum Assets directly to you handle (not your address) by sending it to the account which holds that token!

________

For example, one could register the handle @bob and then alice can use wallet services to send payments to @bob.
The wallet will be ask this contract which account the @bob token resides in and will send the payment there!

*/



contract NametagToken is ERC721, ERC721Metadata  {


constructor()
{
  _name = 'Nametag Token';
  _symbol = 'NTT';
}




  function claimNametagToken(
    address to,
    bytes32 name
  )
    public
    returns (bool)
  {

    uint256 tokenId = (uint256) (keccak256(name));
    string memory metadata = bytes32ToString(name);

    _mint(to, tokenId);
    _setTokenURI(tokenId, metadata);
    return true;
  }


  function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
      return string(bytesStringTrimmed);
  }


}
