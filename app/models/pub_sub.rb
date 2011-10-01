require 'net/http'
require 'uri'

class PubSub
  # These URI patterns must match those in the relevant Nginx config
  PUBLISH_URI   = '%s/push/publish?channel=%s'    
  SUBSCRIBE_URI = '%s/push/subscribe?channel=%s'

  # Returns Publish/Subscribe URI tuple with unique channel.
  # @param base_uri, a string, to build the pub and sub uris
  def self.pub_and_sub_uri(base_uri)
    channel = Time.now.strftime('%Y%m%d%H%M%S%L')
    [PUBLISH_URI % [base_uri, channel], SUBSCRIBE_URI % [base_uri, channel]]
  end
  
  attr_accessor :uri, :http

  # @param uri_string, the subscribe_uri from pub_and_sub_uri()
  def initialize(uri_string)
    @uri = URI.parse(uri_string)
    @http = Net::HTTP.new(uri.host, uri.port)
  end

  # Publish data in JSON format.
  # @param message, a string
  # @option error, a boolean, default false
  # @option eot, a boolean, true if end-of-transmission, default false
  def publish(message, options = {})
    error   = options[:error] || false
    eot     = options[:eot]   || false
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = {
      :message => message, 
      :error   => error ? 1 : 0, 
      :eot     => eot   ? 1 : 0
    }.to_json
    request.content_type = 'text/json'
#   request['accept']    = 'text/json'
    http.request(request)
  end
end
