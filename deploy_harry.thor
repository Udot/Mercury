# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "net/http"
require "yaml"

# get all the gems in
Bundler.require(:default)

module SimpleApi
  extend self
  def post(request, payload)
    config = YAML.load_file("./config/settings/production.yml")
    http_r = Net::HTTP.new(config['harry_host'], config['harry_port'])
    http_r.use_ssl = false
    response = nil
    http_r.start() do |http|
      req = Net::HTTP::Post.new(request)
      req.add_field("TOKEN", config['harry_token'])
      req.body = payload
      req.set_form_data(payload)
      response = http.request(req)
    end
    return [response.code, response.body]
  end

end

class Harry < Thor
  include Thor::Actions
  desc "deploy", "call on harry to deploy from git"
  def deploy
    config = YAML.load_file("./config/settings/production.yml")
    # params[:name], params[:url], params[:bundler]
    name = config["app_name"]
    url = config["git_repository"]
    bundler = "true"
    payload = {"name" => name, "repository" => url, "bundler" => "lah"}
    SimpleApi.post("/",payload)
  end
end