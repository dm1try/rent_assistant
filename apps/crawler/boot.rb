require "bundler/setup"

$LOAD_PATH << File.expand_path("app", __dir__)
$LOAD_PATH << File.expand_path("../../lib", __dir__)

require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO
$stdout.sync = true

require "sequel"
begin
  database_url = ENV['CRAWLER_DATABASE_URL'] || ENV['DATABASE_URL']
  DB = Sequel.connect(database_url)
rescue
  $logger.warn "Could not connect to database: #{database_url}"
end
