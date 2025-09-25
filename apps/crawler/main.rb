require_relative 'boot'

require 'crawler_service'


# Directly start the crawler service
CrawlerService.new.start_crawling

