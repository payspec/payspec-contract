pragma solidity ^0.5.0;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/*
PAYSPEC: Generic global invoicing contract


*/

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}






contract PaySpec  {

   using SafeMath for uint;


   mapping(bytes32 => Invoice) invoices;



  event CreatedInvoice(bytes32 uuid);
  event PaidInvoice(bytes32 uuid, address from);


  struct Invoice {
    bytes32 uuid;
    string description;
    uint256 nonce;


    address token;
    uint256 amountDue;
    address payTo;
    uint256 ethBlockCreatedAt;


    address paidBy;
    uint256 amountPaid;
    uint256 ethBlockPaidAt;


    uint256 ethBlockExpiresAt;

  }



  constructor(  ) public {


  }


  //do not allow ether to enter
  function() external    payable {
      revert();
  }




   function createInvoice(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, uint256 ethBlockExpiresAt ) public returns (uint uuid) {




      uint256 ethBlockCreatedAt = block.number;

      bytes32 newuuid = keccak256( abi.encodePacked( description, nonce, token, amountDue, payTo, ethBlockCreatedAt ) );

      require( invoices[newuuid].uuid == 0 );  //make sure you do not overwrite invoices

      invoices[newuuid] = Invoice({
       uuid:newuuid,
       description:description,
       nonce: nonce,
       token: token,
       amountDue: amountDue,
       payTo: payTo,
       ethBlockCreatedAt: ethBlockCreatedAt,
       paidBy: address(0),
       amountPaid: 0,
       ethBlockPaidAt: 0,
       ethBlockExpiresAt: ethBlockExpiresAt

      });


       emit CreatedInvoice(newuuid);

       return uuid;
   }

   function payInvoice( bytes32 invoiceUUID, address from) public returns (bool) {

       require( invoices[invoiceUUID].uuid == invoiceUUID ); //make sure invoice exists
       require( invoiceWasPaid(invoiceUUID) == false );
       require( invoiceHasExpired(invoiceUUID) == false);

       //transfer the tokens
       require( ERC20Interface( invoices[invoiceUUID].token  ).transferFrom( from ,  invoices[invoiceUUID].payTo, invoices[invoiceUUID].amountDue   ) );

       invoices[invoiceUUID].amountPaid = invoices[invoiceUUID].amountDue;

       invoices[invoiceUUID].paidBy = from;

       invoices[invoiceUUID].ethBlockPaidAt = block.number;



       emit PaidInvoice(invoiceUUID, from);

       return true;


   }


   function invoiceWasPaid( bytes32 invoiceUUID ) public view returns (bool)
   {
       return invoices[invoiceUUID].amountPaid >= invoices[invoiceUUID].amountDue;
   }



   function invoiceExpiresAt( bytes32 invoiceUUID ) public view returns (uint)
   {
       return invoices[invoiceUUID].ethBlockExpiresAt;
   }

   function invoiceHasExpired( bytes32 invoiceUUID ) public view returns (bool)
   {
       return (invoiceExpiresAt(invoiceUUID) != 0 && block.number >= invoiceExpiresAt(invoiceUUID));
   }

   /*
     Receive approval from ApproveAndCall() to pay invoice.  The first 32 bytes of the data array are used for the invoice UUID bytes32.

   */
     function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public returns (bool) {

        require(  payInvoice(bytesToBytes32(data,0), from)  );

        return true;

     }

    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32) {
      bytes32 out;

      for (uint i = 0; i < 32; i++) {
        out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
      }
      return out;
    }


}
