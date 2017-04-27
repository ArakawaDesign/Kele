require "kele/version"
require "kele/errors"
require 'json'
require "httparty"

class Kele
  include HTTParty
  def initialize(email, password)
    response = self.class.post(api_url("sessions"), body: { email: email, password: password })
   raise "Invalid email address or password" if response.code != 200
    @auth_token = response["auth_token"]
  end
  
  def get_me
    response = self.class.get(api_url("users/me"), headers: { "authorization" => @auth_token })
    @user_data = JSON.parse(response.body)
    @user_data.keys.each do |key|
      self.class.send(:define_method, key.to_sym) do
        @user_data[key]
      end
    end
    @user_data
  end
  
  def get_mentor_availability(mentor_id)
    response = self.class.get(api_url("mentors/#{mentor_id}/student_availability"), headers: {"authorization" => @auth_token })
    @mentor_availability = JSON.parse(response.body)
  end
  
  private
  def api_url(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end
end