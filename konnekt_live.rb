require 'sinatra'
require 'firebase'
require 'json'

class KonnektLive < Sinatra::Base
  private_key_json_string = File.open('config/konnektlive-firebase.json').read
  firebase = Firebase::Client.new("https://konnektlive.firebaseio.com", private_key_json_string)

  before do
    @texts = firebase.get('texts').body
    @professions = firebase.get('professions').body
    @rotations = %w(rotate-l1 rotate-l2 rotate-r1 rotate-r2)
  end

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
