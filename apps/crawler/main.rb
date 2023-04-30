require 'drb'

DRbService.new(ENV.fetch("CRAWLER_DRB_URI"), CrawlerService.new).start
