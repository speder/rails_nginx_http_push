require 'net/http'
require 'uri'

class PubSub
  # URIs must match those in Nginx config
  PUBLISH_URI   = '%s/push/publish?channel=%s'    
  SUBSCRIBE_URI = '%s/push/subscribe?channel=%s'

  # Returns Publish/Subscribe URI tuple with unique channel. The Publish URI is
  # passed to the model, and subsequently executed via Delayed::Job, while the
  # subscribe URI is passed to the view, and subsequently to Javascript function,
  # This method is called by the Controller.
  def self.pub_and_sub_uri(base_uri)
    channel = generate_channel
    
    [PUBLISH_URI   % [base_uri, channel], SUBSCRIBE_URI % [base_uri, channel]]
  end

  def self.generate_channel
    Time.now.strftime('%Y%m%d%H%M%S%L')
  end
  
  attr_accessor :uri, :http

  def initialize(uri_string)
    @uri  = URI.parse(uri_string)
    @http = Net::HTTP.new(uri.host, uri.port)
  end

  # Publish data in the following JSON format:
  #   message String
  #   error 1/0
  #   eot 1/0
  # This format is referenced in the Subscriber code at
  #   app/assets/javascripts/push.js
  def publish(message, options = {})
    error = options[:error] || false
    eot   = options[:eot]   || false
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = {
      :message => message, 
      :error   => error ? 1 : 0, 
      :eot     => eot   ? 1 : 0
    }.to_json
    request.content_type = 'text/json'
#   request['accept']  = 'text/json'
    http.request(request)
  end
end
