class PioClient
  cattr_accessor :url, :access_key
  attr_accessor :client

  def initialize
    pio_threads = 50
    self.client = PredictionIO::EventClient.new(access_key, url, pio_threads, 3000)
  end

  def create_event(*args)
    client.create_event(*args)
  end
end
