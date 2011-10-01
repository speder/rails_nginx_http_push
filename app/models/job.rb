class Job < Struct.new(:name, :uri)
  def perform
    pubsub = PubSub.new(uri)
    pubsub.publish("hello #{name}")
    (rand(3)).times do
      sleep rand(3)
      pubsub.publish("hello #{name}")
    end
    pubsub.publish('goodbye', :eot => true)
  end 
end
