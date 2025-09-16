# frozen_string_literal: true
require_relative 'boot'
require_relative './app/api'

run CatalogAPI.new
