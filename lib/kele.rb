require "kele/version"
require "kele/errors"
require "kele/roadmap"
require 'json'
require "httparty"

class Kele
  include HTTParty
  include Roadmap
  
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
  
  def get_messages(page = nil)
    if page == nil
      response = self.class.get(api_url("message_threads"), headers: { "authorization" => @auth_token })
    else
      response = self.class.get(api_url("message_threads?page=#{page}"), headers: { "authorization" => @auth_token })
    end
    @messages = JSON.parse(response.body)
  end
  
  def create_message(recipient_id, subject, message)
    response = self.class.post(api_url("messages"), 
      body: { 
        "user_id": id, 
        "recipient_id": recipient_id, 
        "subject": subject, 
        "stripped-text": message }, 
      headers: { "authorization" => @auth_token })
    puts response
  end
  
  def create_submission(assignment_branch, assignment_commit_link, checkpoint_id, comment, enrollment_id)
    response = self.class.post(api_url("checkpoint_submissions"),
      body: {
        "assignment_branch": assignment_branch,
        "assignment_commit_link": assignment_commit_link,
        "checkpoint_id": checkpoint_id,
        "comment": comment,
        "enrollment_id": enrollment_id
        },
      headers: {"authorization" => @auth_token})
    puts response
  end
  
  private
  def api_url(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end
end