require 'sinatra'
require 'json'
# require './database'
require './dummy_database'

class KonnektLive < Sinatra::Base
  private_secrets = JSON.parse(File.open('config/secrets.json').read)
  db = DummyDatabase.new

  before do
    @texts = db.get('texts')
    @professions = db.get('professions')
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
    response = db.push("newsletter", {
      email: params['email']
    })
    @success = true
    haml :index
  end

  post '/reg' do
    params['reg']['professions'] = params['prof']
    @errors = []
    
    if params['reg']['year'].to_i > 2002 || params['reg']['year'].to_i < 1920
      @errors.push @texts['errors-year']
    end

    if params['reg']['terms'] != 'accepted'
      @errors.push @texts['errors-terms']
    end
    
    if @errors.empty?
      response = db.push("registrations", params['reg'])
    end

    params[:reg_test] = 1
    @success = @errors.empty?
    haml :index
  end

  get '/admin' do
    if params['key'] != private_secrets['admin_key']
      redirect '/'
    end
    @news_signups = db.get('newsletter')
    @regs = db.get('registrations')
    @schools = collect(@regs, 'school')
    @profs = collect_arrays(@regs, 'professions')
    haml :admin
  end

  get '/csv' do
    if params['key'] != private_secrets['admin_key']
      redirect '/'
    end
  end

  private

  def collect(original, what)
    h = Hash.new
    original.each do |r|
      if h[r[1][what]]
        h[r[1][what]] += 1
      else
        h[r[1][what]] = 1
      end
    end
    h = h.sort_by {|k, v| -v}
  end

  def collect_arrays(original, what)
    h = Hash.new
    original.each do |row|
      if row[1][what]
        row[1][what].each do |item|
          if h[item]
            h[item] += 1
          else
            h[item] = 1
          end
        end
      end
    end
    h = h.sort_by {|k, v| -v}
  end
end
