require "kele/version"
require "kele/errors"
require 'json'
require "httparty"

class Kele
  include HTTParty
  BASE_URL = 'https://www.bloc.io/api/v1'
  def initialize(email, password)
    response = self.class.post("#{BASE_URL}/sessions", body: { email: email, password: password })
   raise "Invalid email address or password" if response.code != 200
    @auth_token = response["auth_token"]
  end
end