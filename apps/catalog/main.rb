require_relative 'boot'
require 'catalog_service'
require 'drb_service'

DRbService.new(ENV.fetch("CATALOG_DRB_URI"), CatalogService.new).start
