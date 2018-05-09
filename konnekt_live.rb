require 'sinatra'
require 'firebase'
require 'json'

class KonnektLive < Sinatra::Base
  private_key_json_string = File.open('config/konnektlive-firebase.json').read
  # firebase = Firebase::Client.new("https://konnektlive.firebaseio.com", private_key_json_string)

  before do
    begin
      @texts = firebase.get('texts').body
      @professions = firebase.get('professions').body
    rescue
      file = File.read('dummy_data.json')
      data_hash = JSON.parse(file)
      @texts = data_hash['texts']
      @professions = data_hash['professions']
    end
    @rotations = %w(rotate-l1 rotate-l2 rotate-r1 rotate-r2)
  end

  get '/' do
    params['reg'] = {}
    haml :index
  end

  get '/register' do
    params['reg'] = {}
    params['from_reg'] = 1
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
    end

    if params['reg']['terms'] != 'accepted'
      @errors.push @texts['errors-terms']
    end
    
    if @errors.empty?
      response = firebase.push("registrations", params['reg'])
    end

    params[:reg_test] = 1
    @success = @errors.empty?
    haml :index
  end
end
