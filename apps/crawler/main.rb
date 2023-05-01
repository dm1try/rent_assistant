require_relative 'boot'
require 'drb'
require 'drb_service'
require 'crawler_service'

DRbService.new(ENV.fetch("CRAWLER_DRB_URI"), CrawlerService.new).start
