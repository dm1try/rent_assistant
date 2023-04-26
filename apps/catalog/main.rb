require 'drb'

class CatalogService
  def initialize
    # initialize your Ecto Repo here
  end

  def save_listing(listing)
    # save the listing to the database
  end

  def get_listings
    # retrieve all listings from the database
  end
end

DRb.start_service('druby://catalog:9000', CatalogService.new)
DRb.thread.join
