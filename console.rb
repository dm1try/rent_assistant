require 'drb/drb'
require 'dotenv'
Dotenv.load

@crawler = DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
@catalog = DRbObject.new_with_uri(ENV['CATALOG_DRB_URI'])

def crawler
  @crawler
end

def catalog
  @catalog
end
