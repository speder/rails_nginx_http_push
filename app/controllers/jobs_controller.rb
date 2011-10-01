class JobsController < ApplicationController
  def index
  end

  def new
  end

  def create
    publish_uri, @subscribe_uri = PubSub.pub_and_sub_uri(request.url.gsub(request.fullpath, ''))
    Delayed::Job.enqueue Job.new(params[:name], publish_uri)
  end
end
