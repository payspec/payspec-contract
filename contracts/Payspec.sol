pragma solidity ^0.8.0;

/*
PAYSPEC: Atomic and deterministic invoicing system

Generate offchain invoices based on sell-order data and allow users to fulfill those order invoices onchain.

*/
 

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



  
contract Payspec is Ownable, ReentrancyGuard {

  uint256 public immutable contractVersion  = 100;
  address immutable ETHER_ADDRESS = address(0x0000000000000000000000000000000000000010);
  
  mapping(bytes32 => Invoice) public invoices;
  mapping(bytes32 => bool) public cancelledInvoiceUUIDs;

  bool lockedByOwner = false; 

  event CreatedInvoice(bytes32 uuid);
  event CancelledInvoice(bytes32 uuid);
  event PaidInvoice(bytes32 uuid, address from);


  struct Invoice {
    bytes32 uuid;
    string description;
    uint256 nonce;
    bool created;


    address token;
    uint256 amountDue;
    address payTo;

    address[] feeAddresses;
    uint[] feePercents;

    address paidBy;
    uint256 amountPaid;
    uint256 ethBlockPaidAt;


    uint256 ethBlockExpiresAt;

  }



  constructor(   ) public {

  } 
 

  function lockContract() public onlyOwner {
    lockedByOwner = true;
  }


   function cancelInvoice(   string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint256 ethBlockExpiresAt, bytes32 expecteduuid   ) public returns (bool) {

     address from = msg.sender;

     bytes32 invoiceUUID = getInvoiceUUID(description, nonce, token, amountDue, payTo, feeAddresses, feePercents,  ethBlockExpiresAt ) ;

     require(!lockedByOwner);
     require( invoiceUUID == expecteduuid );
     require( payTo == from );  //can only cancel your own orders
     require( invoiceWasPaid(invoiceUUID) == false );
     require( invoiceWasCancelled(invoiceUUID) == false);

      cancelledInvoiceUUIDs[invoiceUUID] = true;


      emit CancelledInvoice(invoiceUUID);
    }


  function createAndPayInvoice(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint256 ethBlockExpiresAt, bytes32 expecteduuid  ) 
    public 
    payable 
    nonReentrant
    returns (bool) {
     
     if(token == ETHER_ADDRESS){
       require(msg.value == amountDue, "Transaction sent incorrect ETH amount.");
     }else{
       require(msg.value == 0, "Transaction sent ETH for an ERC20 invoice.");
     }
     
     bytes32 newuuid = _createInvoice(description,nonce,token,amountDue,payTo,feeAddresses, feePercents,ethBlockExpiresAt,expecteduuid);
     require(newuuid == expecteduuid);
     return _payInvoice(newuuid);
  }

   function _createInvoice(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint256 ethBlockExpiresAt, bytes32 expecteduuid ) 
    private 
    returns (bytes32 uuid) { 


      bytes32 newuuid = getInvoiceUUID(description, nonce, token, amountDue, payTo, feeAddresses, feePercents,  ethBlockExpiresAt ) ;

      require(!lockedByOwner);
      require( newuuid == expecteduuid );
      require( invoices[newuuid].uuid == 0 );  //make sure you do not overwrite invoices
      require(feeAddresses.length == feePercents.length);

      invoices[newuuid] = Invoice({
       uuid:newuuid,
       description:description,
       nonce: nonce,
       token: token,
       amountDue: amountDue,
       payTo: payTo,
       paidBy: address(0),
       feeAddresses: feeAddresses,
       feePercents: feePercents,
       amountPaid: 0,
       ethBlockPaidAt: 0,
       ethBlockExpiresAt: ethBlockExpiresAt,
       created:true
      });


       emit CreatedInvoice(newuuid);

       return newuuid;
   }

   function _payInvoice( bytes32 invoiceUUID ) private returns (bool) {

       address from = msg.sender;

       require(!lockedByOwner);
       require( invoices[invoiceUUID].uuid == invoiceUUID ); //make sure invoice exists
       require( invoiceWasPaid(invoiceUUID) == false );
       require( invoiceHasExpired(invoiceUUID) == false);
       require( invoiceWasCancelled(invoiceUUID) == false);

       uint totalAmountDueInFees = 0; // invoices[invoiceUUID].amountDue.mul( fee_pct ).div(100);



       for(uint i=0;i<invoices[invoiceUUID].feeAddresses.length;i++){
              uint amtDueInFees =  invoices[invoiceUUID].amountDue * ( invoices[invoiceUUID].feePercents[i] / 100);

              //transfer each fee to fee recipient
              require(  _payTokenAmount(invoices[invoiceUUID].token , from , invoices[invoiceUUID].feeAddresses[i], amtDueInFees ) , "Unable to pay fees amount due." );

              totalAmountDueInFees = totalAmountDueInFees + amtDueInFees ;
       }
 

      uint amountDueLessFees =  invoices[invoiceUUID].amountDue - totalAmountDueInFees ; 

      //transfer the tokens to the seller
      require( _payTokenAmount(  invoices[invoiceUUID].token ,  from,  invoices[invoiceUUID].payTo, amountDueLessFees  ),"Unable to pay amount due.");

      //mark the invoice as paid 
       invoices[invoiceUUID].amountPaid = invoices[invoiceUUID].amountDue;

       invoices[invoiceUUID].paidBy = from;

       invoices[invoiceUUID].ethBlockPaidAt = block.number;



       emit PaidInvoice(invoiceUUID, from);

       return true;


   }


   function _payTokenAmount(address tokenAddress, address from, address to, uint256 tokenAmount) 
      internal 
      returns (bool) {
      
      if(tokenAddress == ETHER_ADDRESS){
        payable(to).transfer( tokenAmount ); 
      }

      IERC20( tokenAddress  ).transferFrom( from ,  to, tokenAmount  );

      return true;
   }



   function getInvoiceUUID(  string memory description, uint256 nonce, address token, uint256 amountDue, address payTo, address[] memory feeAddresses, uint[] memory feePercents, uint expiresAt  ) public view returns (bytes32 uuid) {

         address payspecContractAddress = address(this); //prevent from paying through the wrong contract

         bytes32 newuuid = keccak256( abi.encodePacked(payspecContractAddress, description, nonce, token, amountDue, payTo, feeAddresses, feePercents, expiresAt ) );

         return newuuid;
    }

   function invoiceWasPaid( bytes32 invoiceUUID ) public view returns (bool){

       return invoices[invoiceUUID].amountPaid >= invoices[invoiceUUID].amountDue;
   }

   function invoiceWasCreated( bytes32 invoiceUUID ) public view returns (bool){

       return invoices[invoiceUUID].created ;
   }



    function getInvoiceDescription( bytes32 invoiceUUID ) public view returns (string memory){

       return invoices[invoiceUUID].description;
   }

   function getInvoiceTokenCurrency( bytes32 invoiceUUID ) public view returns (address){

       return invoices[invoiceUUID].token;
   }


   function getInvoiceAmountPaid( bytes32 invoiceUUID ) public view returns (uint){

       return invoices[invoiceUUID].amountPaid;
   }

   function getInvoicePayer( bytes32 invoiceUUID ) public view returns (address){

       return invoices[invoiceUUID].paidBy;
   }

   function getInvoiceEthBlockPaidAt( bytes32 invoiceUUID ) public view returns (uint){

       return invoices[invoiceUUID].ethBlockPaidAt;
   }



   function invoiceExpiresAt( bytes32 invoiceUUID ) public view returns (uint){

       return invoices[invoiceUUID].ethBlockExpiresAt;
   }

   function invoiceHasExpired( bytes32 invoiceUUID ) public view returns (bool){

       return (invoiceExpiresAt(invoiceUUID) != 0 && block.number >= invoiceExpiresAt(invoiceUUID));
   }

   function invoiceWasCancelled( bytes32 invoiceUUID ) public view returns (bool){

      return cancelledInvoiceUUIDs[invoiceUUID]  ;
   }

    function invoiceWasDisabled( bytes32 invoiceUUID ) public view returns (bool){

      return invoiceWasCancelled(invoiceUUID) || invoiceHasExpired(invoiceUUID);
   }



}
