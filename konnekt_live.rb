require 'sinatra'
require 'firebase'
require 'json'

class KonnektLive < Sinatra::Base
  private_key_json_string = File.open('config/konnektlive-firebase.json').read
  firebase = Firebase::Client.new("https://konnektlive.firebaseio.com", private_key_json_string)

  get '/' do
    haml :index
  end

  post '/' do
    response = firebase.push("newsletter", {
      email: params['email'],
      created: Firebase::ServerValue::TIMESTAMP
    })
    @success = true
    haml :index
  end
end
