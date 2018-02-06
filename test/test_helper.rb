$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rails"
require "active_support/all"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "active_record/railtie"
require "yuba"
Time.zone = 'Tokyo'
require "minitest/autorun"


require 'active_record'
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

require_relative 'yuba/support/models'
