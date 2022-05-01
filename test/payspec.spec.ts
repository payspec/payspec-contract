 
import chai, { expect } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import hre from 'hardhat'
import { deploy } from 'helpers/deploy-helpers'
import { Payspec } from 'types/typechain'

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
      payspecContrac
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
      const result = await axios.get(uriRoot + '/api/ping', {})

      expect(result.data.success).to.eql(true)
    })

    it('should generate an auth token', async () => {
      const insertion = await generateAuthToken()

      authToken = insertion[0].token
    })

    it('should fail with bad authtoken', async () => {
      const inputData = {
        recipientAddress: '0xF4dAb24C52b51cB69Ab62cDE672D3c9Df0B39681',
        authToken: 'invalidAuthToken',
      }
      const result = await axios.post(
        uriRoot + '/api/request_attestation',
        inputData
      )

      expect(result.data.success).to.eql(false)
    })

    it('should return signed attestation', async () => {
      const inputData = {
        recipientAddress: '0xF4dAb24C52b51cB69Ab62cDE672D3c9Df0B39681',
        authToken: authToken,
      }
      const result = await axios.post(
        uriRoot + '/api/request_attestation',
        inputData
      )

      expect(result.data.success).to.eql(true)
    })
  
})
