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
    params['reg'] = {}
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

  post '/reg' do
    params['reg']['created'] = Firebase::ServerValue::TIMESTAMP
    params['reg']['professions'] = params['prof']
    @errors = []
    if params['reg']['year'].to_i > 2002 || params['reg']['year'].to_i < 1920
      @errors.push @texts['errors-year']
    else
      response = firebase.push("registrations", params['reg'])
    end
    
    params[:reg_test] = 1
    @success = @errors.empty?
    haml :index
  end
end
