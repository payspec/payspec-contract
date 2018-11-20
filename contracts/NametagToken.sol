pragma solidity ^0.4.24;


import "./ERC721/ERC721.sol";
import "./ERC721/IERC721Metadata.sol";
import "./util/ERC165.sol";


/*

HASHTAG TOKEN

An ERC721 non-fungible token with the hash of your unique lowercased Alias imprinted upon it.

Register your handle by minting a new token with that handle.
Then, others can send Ethereum Assets directly to you handle (not your address) by sending it to the account which holds that token!

________

For example, one could register the handle @bob and then alice can use wallet services to send payments to @bob.
The wallet will be ask this contract which account the @bob token resides in and will send the payment there!

*/



contract HashtagToken  is ERC165, ERC721, IERC721Metadata {
  // Token name
  string internal _name;

  // Token symbol
  string internal _symbol;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;



    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *   bytes4(keccak256('name()')) ^
     *   bytes4(keccak256('symbol()')) ^
     *   bytes4(keccak256('tokenURI(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor(string name, string symbol) public {
      _name = name;
      _symbol = symbol;

      // register the supported interfaces to conform to ERC721 via ERC165
      _registerInterface(InterfaceId_ERC721Metadata);
    }





  function claimToken(
    address to,
    string name
  )
    public
    returns (bool)
  {

    string memory lowerName = _toLower(name);

    uint256 tokenId = (uint256) (keccak256(lowerName));


    _mint(to, tokenId);
    _setTokenURI(tokenId, lowerName);
    return true;
  }


  function nameToTokenId(string name) public constant returns (uint256) {

    string memory lowerName = _toLower(name);

    return  (uint256) (keccak256(lowerName));
  }

 

  function _toLower(string str) internal returns (string) {
  		bytes memory bStr = bytes(str);
  		bytes memory bLower = new bytes(bStr.length);
  		for (uint i = 0; i < bStr.length; i++) {
  			// Uppercase character...
  			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
  				// So we add 32 to make it lowercase
  				bLower[i] = bytes1(int(bStr[i]) + 32);
  			} else {
  				bLower[i] = bStr[i];
  			}
  		}
  		return string(bLower);
  	}

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string) {
    return _name;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string) {
    return _symbol;
  }




  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 tokenId) public view returns (string) {
    require(_exists(tokenId));
    return _tokenURIs[tokenId];
  }


  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param tokenId uint256 ID of the token to set its URI
   * @param uri string URI to assign
   */
  function _setTokenURI(uint256 tokenId, string uri) internal {
    require(_exists(tokenId));
    _tokenURIs[tokenId] = uri;
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param owner owner of the token to burn
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address owner, uint256 tokenId) internal {
    super._burn(owner, tokenId);

    // Clear metadata (if any)
    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }


}
