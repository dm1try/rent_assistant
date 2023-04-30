require "bundler/setup"

$LOAD_PATH << File.expand_path("app", __dir__)
$LOAD_PATH << File.expand_path("../../lib", __dir__)

require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO
