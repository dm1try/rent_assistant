require "bundler/setup"

$LOAD_PATH << File.expand_path("app", __dir__)
$LOAD_PATH << File.expand_path("../../lib", __dir__)

require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

# initialize the database connection
require "sequel"
begin
  DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
  DB.extension :pg_array
rescue
  $logger.warn "Could not connect to database: #{ENV["DATABASE_URL"]}"
end

