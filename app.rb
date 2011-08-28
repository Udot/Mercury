# encoding: utf-8
ENV['RACK_ENV'] = "development" unless ENV['RACK_ENV'] != nil
require "rubygems"
require "bundler/setup"
require "fileutils"

# get all the gems in
Bundler.require(:default)

class Mercury < Sinatra::Application
	RailsConfig.load_and_set_settings("./config/settings.yml", "./config/settings/#{settings.environment.to_s}.yml")

  configure do
    LOGGER = Logger.new("log/#{settings.environment.to_s}.log")
  end
  helpers do
    def logger
      LOGGER
    end
  end

  get "/alive" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    status 200
    st_answ = {"status" => "running"}.to_json
    body st_answ
  end

  post '/repositories/create/?' do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    data = params
    if not init_store(data["path"])
      status 409
      answ = {"result" => false, "error" => "can't create repository"}.to_json
      body answ
    end
    if repo_init(data["path"])
      status 200
      answ = {"result" => true}.to_json
      body answ
    else
      status 409
      answ = {"result" => false, "error" => "can't create repository"}.to_json
      body answ
    end
  end

  post "/repositories/status" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    data = params
    answer = {"status" => "loose"}.to_json
    answer = {"status" => "created"}.to_json if File.exist?(data["path"])
    status 200
    body answer
  end

  post "/keys" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    logger.info("data in")
    if not params[:data]
      status 400
      body "Missing data"
      return
    end
    data = JSON.parse(params[:data])
    File.open("/tmp/authorized_keys", "w") { |file_out| file_out.write(data["authfile"]) }
    status 200
    body "exported"
  end

  private
  def api_auth(the_env)
    token = the_env['HTTP_TOKEN'] || the_env['TOKEN']
    username = the_env['HTTP_USERNAME'] || the_env['USERNAME']
    return false if (Settings.api.token != token) || (Settings.api.username != username)
    return true
  end

  def init_store(repository_path)
    if File.exist?(repository_path)
      return false
    end
    FileUtils.mkdir_p(repository_path)
    return true
  end

  def repo_init(repository)
    app_dir = File.expand_path(File.dirname(__FILE__))
    File.umask(0001)
    dirs = {
      "hooks" => nil,
      "info" => nil,
      "objects" => { "info" => nil, "pack" => nil },
      "refs" => { "heads" => nil, "tags" => nil }}
    files = ["HEAD", "config", "description"]
    hooks = ["post-receive"]

    dot_git = Pathname(repository)

    # Create the dirs
    l_mkdirs(dot_git, dirs)

    # Create base files
    bare = true
    files.each do |l_file|
      if !File.exist?("#{dot_git}/#{l_file}")
        File.open("#{dot_git}/#{l_file}", "a") do |file_out|
          IO.foreach("#{app_dir}/config/templates/#{l_file}") { |w| file_out.puts(w) }
        end
      end
    end
    hooks.each do |h_file|
      if !File.exist?("#{dot_git}/#{l_file}")
        File.open("#{dot_git}/hooks/#{l_file}", "a") do |file_out|
          IO.foreach("#{app_dir}/config/templates/#{l_file}") { |w| file_out.puts(w) }
        end
      end
    end
    FileUtils.chmod_R(770, repository)
    return true
  end # def git_repo_init

  # l_mkdirs method creates dirs using a hash
  #
  # root is a pathname object
  # dir_hash is a hash containing dirs to create in root
  # if subdirs need to be created in those then the key points to another hash
  def l_mkdirs(root, dir_hash)
    dir_hash.each_key do |s_dir|
      Dir.mkdir(root + s_dir) if !(root + s_dir).exist?
      l_mkdirs(root + s_dir, dir_hash[s_dir]) if dir_hash[s_dir]
    end
  end
end