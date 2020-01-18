require 'dashbeautiful/api'
require 'dashbeautiful/dashboard_base'
require 'dashbeautiful/device'
require 'dashbeautiful/network'
require 'dashbeautiful/organization'
require 'dashbeautiful/version'

# description TODO
module Dashbeautiful
  def self.register(key)
    @api_key = key
  end

  def self.registered?
    !@api_key.nil?
  end

  def self.key
    @api_key
  end

  class APIRequestError < StandardError; end
end
