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

  bool lockedByOwner = false; 

  event CreatedInvoice(bytes32 uuid); 
  event PaidInvoice(bytes32 uuid, address from);


  struct Invoice {
    bytes32 uuid;
    string description;
    uint256 nonce;
    bool created;


    address token;
   
    uint256 totalAmountDue;
    
    address[] payTo;
    uint[] amountsDue;
    

    address paidBy;
    uint256 ethBlockPaidAt;


    uint256 ethBlockExpiresAt;

  }



  constructor(   ) public {

  } 
 

  function lockContract() public onlyOwner {
    lockedByOwner = true;
  }


   


  function createAndPayInvoice(  string memory description, uint256 nonce, address token,  uint256 totalAmountDue,address[] memory payTo, uint[] memory amountsDue, uint256 ethBlockExpiresAt, bytes32 expecteduuid  ) 
    public 
    payable 
    nonReentrant
    returns (bool) {
     
     if(token == ETHER_ADDRESS){
       require(msg.value == totalAmountDue, "Transaction sent incorrect ETH amount.");
     }else{
       require(msg.value == 0, "Transaction sent ETH for an ERC20 invoice.");
     }
     
     bytes32 newuuid = _createInvoice(description,nonce,token,totalAmountDue,payTo,amountsDue,ethBlockExpiresAt,expecteduuid);
    
     return _payInvoice(newuuid);
  }

   function _createInvoice(  string memory description, uint256 nonce, address token, uint256 totalAmountDue, address[] memory payTo, uint[] memory amountsDue, uint256 ethBlockExpiresAt, bytes32 expecteduuid ) 
    private 
    returns (bytes32 uuid) { 


      bytes32 newuuid = getInvoiceUUID(description, nonce, token, totalAmountDue, payTo, amountsDue,  ethBlockExpiresAt ) ;

      require(!lockedByOwner);
      require( newuuid == expecteduuid , "Invalid invoice uuid");
      require( invoices[newuuid].uuid == 0 );  //make sure you do not overwrite invoices
      require(payTo.length == amountsDue.length, "Invalid number of amounts due");

      require(ethBlockExpiresAt == 0 || block.number < ethBlockExpiresAt);

      invoices[newuuid] = Invoice({
       uuid:newuuid,
       description:description,
       nonce: nonce,
       token: token,

       totalAmountDue: totalAmountDue,

       payTo: payTo,
       amountsDue: amountsDue,
       
       paidBy: address(0),
        
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


       uint256 amountsDueSum = 0;


       for(uint i=0;i<invoices[invoiceUUID].payTo.length;i++){
              uint amtDue = invoices[invoiceUUID].amountsDue[i];
              amountsDueSum += amtDue; 

              //transfer each fee to fee recipient
              require(  _payTokenAmount(invoices[invoiceUUID].token , from , invoices[invoiceUUID].payTo[i], amtDue ) , "Unable to pay amount due." );
       } 

       require(amountsDueSum == invoices[invoiceUUID].totalAmountDue, "Invalid Total Amount Due");
      
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
      }else{ 
        IERC20( tokenAddress  ).transferFrom( from ,  to, tokenAmount  );
      }
      return true;
   }



   function getInvoiceUUID(  string memory description, uint256 nonce, address token,  uint256 totalAmountDue, address[] memory payTo, uint[] memory amountsDue, uint expiresAt  ) public view returns (bytes32 uuid) {

         address payspecContractAddress = address(this); //prevent from paying through the wrong contract

         bytes32 newuuid = keccak256( abi.encodePacked(payspecContractAddress, description, nonce, token, payTo, amountsDue,  expiresAt ) );

         return newuuid;
    }

 

   function invoiceWasCreated( bytes32 invoiceUUID ) public view returns (bool){

       return invoices[invoiceUUID].created ;
   }

   function invoiceWasPaid( bytes32 invoiceUUID ) public view returns (bool){

       return invoices[invoiceUUID].ethBlockPaidAt > 0 ;
   }


    function getInvoiceDescription( bytes32 invoiceUUID ) public view returns (string memory){

       return invoices[invoiceUUID].description;
   }

   function getInvoiceTokenCurrency( bytes32 invoiceUUID ) public view returns (address){

       return invoices[invoiceUUID].token;
   }


   function getInvoicePayer( bytes32 invoiceUUID ) public view returns (address){

       return invoices[invoiceUUID].paidBy;
   }

   function getInvoiceEthBlockPaidAt( bytes32 invoiceUUID ) public view returns (uint){

       return invoices[invoiceUUID].ethBlockPaidAt;
   }

 


}
