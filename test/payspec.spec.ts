 
import chai, { expect } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import { BigNumber, Signer } from 'ethers'
import hre from 'hardhat'
//import { deploy } from 'helpers/deploy-helpers'
import { FixedSupplyToken, Payspec } from '../generated/typechain'
import { getPayspecInvoiceUUID, PayspecInvoice } from './helpers/payspec-helper'

chai.should()
chai.use(chaiAsPromised)

const { getNamedSigner, deployments } = hre

// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface SetupOptions {}

interface SetupReturn {
  payspecContract: Payspec
  
}

const setup = deployments.createFixture<SetupReturn, SetupOptions>(
  async (hre, _opts) => {
    await hre.deployments.fixture(['primary'], {
      keepExistingDeployments: false,
    })

    const payspecContract = await hre.contracts.get<Payspec>('Payspec')
    const fixedSupplyToken = await hre.contracts.get<FixedSupplyToken>('FixedSupplyToken')
    

    return {
      payspecContract,
      fixedSupplyToken
    }
  }
)



describe('Payspec Contract', () => {

  let payspecContract: Payspec
  let fixedSupplyToken: FixedSupplyToken

  let deployer:Signer  

  let customer:Signer 

  let vendor:Signer 

  

  beforeEach(async () => {
    const result = await setup()
    payspecContract = result.payspecContract
    fixedSupplyToken = result.fixedSupplyToken


    deployer = await getNamedSigner('deployer')

    customer = await getNamedSigner('customer')

    vendor = await getNamedSigner('vendor')

  })


 

    it('should build an invoice', async () => { 
 
      let newInvoiceData:PayspecInvoice = {
        payspecContractAddress:payspecContract.address,
        description: 'testtx',
        nonce: BigNumber.from(1),
        token: fixedSupplyToken.address,
        amountDue: BigNumber.from(100),
        payTo: await vendor.getAddress(),
        feeAddresses: [ await deployer.getAddress() ],
        feePercents: [ 2 ],
        expiresAt: 0
      }      
 
      
        let actualInvoiceUUID=  await payspecContract.getInvoiceUUID(
          newInvoiceData.description,
          newInvoiceData.nonce,
          newInvoiceData.token,
          newInvoiceData.amountDue,
          newInvoiceData.payTo,
          newInvoiceData.feeAddresses,
          newInvoiceData.feePercents,
          newInvoiceData.expiresAt
        ) //.call({ from: myAccount }) ;
    


        let expecteduuid = getPayspecInvoiceUUID( newInvoiceData )



        expecteduuid.should.eql(actualInvoiceUUID)
          
        console.log('actualInvoiceUUID',actualInvoiceUUID)
 
 
    })

    it('should create and pay an invoice', async () => { 

      let newInvoiceData:PayspecInvoice = {
        payspecContractAddress:payspecContract.address,
        description: 'testtx',
        nonce: BigNumber.from(1),
        token: fixedSupplyToken.address,
        amountDue: BigNumber.from(100),
        payTo: await vendor.getAddress(),
        feeAddresses: [ await deployer.getAddress() ],
        feePercents: [ 2 ],
        expiresAt: 0
      }      
      let expecteduuid = getPayspecInvoiceUUID( newInvoiceData )

      //mint and preapprove tokens 
      await fixedSupplyToken.connect(customer).mint(await customer.getAddress(), 10000) 
      await fixedSupplyToken.connect(customer).approve(payspecContract.address, 10000)

      await payspecContract.connect(customer).createAndPayInvoice(
        newInvoiceData.description,
        newInvoiceData.nonce,
        newInvoiceData.token,
        newInvoiceData.amountDue,
        newInvoiceData.payTo,
        newInvoiceData.feeAddresses,
        newInvoiceData.feePercents,
        newInvoiceData.expiresAt,
        expecteduuid
      )


      let invoiceData = await payspecContract.invoices(expecteduuid)

      console.log('invoiceData',invoiceData)

      expect(invoiceData.created).to.eql(true)


    })

    
  
})
