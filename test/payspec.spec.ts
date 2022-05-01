 
import chai, { expect } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import hre from 'hardhat'
//import { deploy } from 'helpers/deploy-helpers'
import { Payspec } from '../generated/typechain'

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
    

    return {
      payspecContract
    }
  }
)



describe('Payspec Contract', () => {

  let payspecContract: Payspec

  beforeEach(async () => {
    const result = await setup()
    payspecContract = result.payspecContract
  })


 

    it('should return a response', async () => {
      
      expect(true).to.eql(true)
    })

    
  
})
