pragma solidity 0.5.0;


import "./ERC721/ERC721Enumerable.sol";
import "./ERC721/IERC721Metadata.sol";
import "./util/ERC165.sol";


/*

NAMETAG TOKEN

An ERC721 non-fungible token with the hash of your unique lowercased Alias imprinted upon it.

Register your handle by minting a new token with that handle.
Then, others can send Ethereum Assets directly to you handle (not your address) by sending it to the account which holds that token!

________

For example, one could register the handle @bob and then alice can use wallet services to send payments to @bob.
The wallet will be ask this contract which account the @bob token resides in and will send the payment there!

*/



contract NametagToken  is ERC721Enumerable, IERC721Metadata {
  // Token name
  string internal _name = 'NametagToken';

  // Token symbol
  string internal _symbol = 'NTT';

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;
  mapping(uint256 => address) private reservedTokenId;


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
    constructor( ) public {

      // register the supported interfaces to conform to ERC721 via ERC165
      _registerInterface(InterfaceId_ERC721Metadata);
    }



    function reserveToken( address to, uint256 tokenId ) public  returns (bool)
    {
        reservedTokenId[tokenId] = to;
        return true;
    }

    function claimToken( address to,  string memory name  ) public  returns (bool)
    {
      require(containsOnlyLower(name));

      uint256 tokenId = (uint256) (keccak256(abi.encodePacked(name)));

      require( reservedTokenId[tokenId] == address(0x0) || reservedTokenId[tokenId] == to  );

      _mint(to, tokenId);
      _setTokenURI(tokenId, name);
      return true;
    }


  function nameToTokenId(string memory name) public view returns (uint256) {

    string memory lowerName = _toLower(name);

    return  (uint256) (keccak256(abi.encodePacked(lowerName)));
  }

  function containsOnlyAlphaNumerics(string memory str) public view returns (bool) {
      bytes memory bStr = bytes(str);

      for (uint i = 0; i < bStr.length; i++) {
          bytes1   char = bStr[i];

          if ( !( ((char >= 0x30) && (char <= 0x39))
                || ((char >= 0x41) && (char <= 0x5A))
                  || ((char >= 0x61) && (char <= 0x7A)) )   ) {
          return false;
        }
      }

      return true;

    }

    function containsOnlyLower(string memory str) public view returns (bool) {
        bytes memory bStr = bytes(str);

        for (uint i = 0; i < bStr.length; i++) {
            bytes1   char = bStr[i];

            if ( !((char >= 0x61) && (char <= 0x7A))   ) {
            return false;
          }
        }

        return true;

      }



    /**
        * Lower
        *
        * Converts all the values of a string to their corresponding lower case
        * value.
        *
        * @param _base When being used for a data type this is the extended object
        *              otherwise this is the string base to convert to lower case
        * @return string
        */
       function _toLower(string memory  _base)
           internal
           pure
           returns (string memory str) {
           bytes memory _baseBytes = bytes(_base);
           for (uint i = 0; i < _baseBytes.length; i++) {
               _baseBytes[i] = _lower(_baseBytes[i]);
           }
           return string(_baseBytes);
       }


    /**
    * Lower
    *
    * Convert an alphabetic character to lower case and return the original
    * value when not alphabetic
    *
    * @param _b1 The byte to be converted to lower case
    * @return bytes1 The converted value if the passed value was alphabetic
    *                and in a upper case otherwise returns the original value
    */
   function _lower(bytes1 _b1)
       private
       pure
       returns (bytes1) {

       if (_b1 >= 0x41 && _b1 <= 0x5A) {
           return bytes1(uint8(_b1)+32);
       }

       return _b1;
   }


  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string memory name) {
    return _name;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
   function symbol() external view returns (string memory symbol) {
      return _symbol;
   }




  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 tokenId) public view returns (string memory uti) {
    require(_exists(tokenId));
    return _tokenURIs[tokenId];
  }


  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param tokenId uint256 ID of the token to set its URI
   * @param uri string URI to assign
   */
  function _setTokenURI(uint256 tokenId, string memory uri) internal {
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
