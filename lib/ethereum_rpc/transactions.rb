module EthereumRPC
  class Transactions
    TRUST_HEIGHT = 10

    def initialize(request_url: )
      @request_url = request_url
    end

    # Returns True if status is success and more than 10 blocks are mined after transaction
    # Returns False if either status is not success ot less than 10 blocks are mined after transaction
    # Returns nil otherwise

    def verified_transaction?(tx_hash: )
      tx_receipt = fetch_tx_receipt(tx_hash)
      return false unless tx_receipt['result'] # Invalid tx_hash
      status = tx_receipt['result']['status']
      return false unless status && status.to_i(16) == 1
      first_tx_block, last_tx_block = first_and_recent_tx_block_number(tx_receipt)
      return last_tx_block - first_tx_block > TRUST_HEIGHT ? true : nil
    end

    def first_and_recent_tx_block_number(tx_receipt)
      first_tx_block = tx_receipt['result']['blockNumber']
      first_tx_block = first_tx_block && first_tx_block.to_i(16)
      last_tx_block = latest_tx_block_number['result']
      last_tx_block = last_tx_block.to_i(16)
      [first_tx_block, last_tx_block]
    end

    def latest_tx_block_number
      api_request(method: 'eth_blockNumber', params: [], id: 2)
    end

    def fetch_tx_receipt(tx_hash)
      api_request(method: 'eth_getTransactionReceipt', params: [tx_hash], id: 1)
    end

    def api_request(params = {})
      response = RestClient.post(@request_url, params.merge(jsonrpc: '2.0').to_json)
      return JSON.parse(response)
    rescue Exception => e
      return nil
    end
  end
end
