#\ -p 8082
require ::File.join( ::File.dirname(__FILE__), 'app' )
if ENV['RACK_ENV'] == "production"
  require "remote_syslog_logger"
  @current_path = File.expand_path(File.dirname(__FILE__))
  require "#{@current_path}/lib/remote_syslog"

  use Rack::CommonLogger, RemoteSyslog.new(Settings.remote_log_host,Settings.remote_log_port)
else
  logger = Logger.new("log/#{ENV['RACK_ENV']}.log")
	use Rack::CommonLogger, logger
end
run Mercury.new