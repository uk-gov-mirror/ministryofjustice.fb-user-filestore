class ServiceTokenService
  def self.get(service_slug)
    client.get(service_slug)
  end

  def self.client
    @client ||= Adapters::ServiceTokenCacheClient.new
  end
end
