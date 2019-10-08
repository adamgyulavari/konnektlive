require 'sinatra'
require 'json'
require 'csv'
require './database'
# require './dummy_database'

class KonnektLive < Sinatra::Base
  
  def initialize
    super
    @private_secrets = JSON.parse(File.open('config/secrets.json').read)
    @db = Database.new
  end

  before do
    @texts = @db.get('texts')
    @professions = @db.get('professions')
    @programs = @db.get('programs').sort_by {|k, v| "#{v['start']}#{2400-v['end'].split(':').join('').to_i}"}
    @programs_uni = @db.get('programs-uni')
    @programs_uni = @programs_uni.sort_by {|k, v| "#{v['start']}#{2400-v['end'].split(':').join('').to_i}"} if @programs_uni
    @sponsors = @db.get('sponsors')
    @partners = @db.get('partners')
    @rotations = %w(rotate-l1 rotate-l2 rotate-r1 rotate-r2)
    @settings = @db.get('settings')
  end

  helpers do
    def staging?
      request.host == 'staging.konnektlive.com' || request.host == 'localhost'
    end

    def displayable?(item)
      !item['unpublished'] || staging?
    end

    def display_section(section)
      return true if @settings[section] == 'production'
      return true if @settings[section] == 'staging' && staging?
      return false
    end

    def sort_by(hash, by)
      hash.sort_by { |k, v| v[by].downcase }
    end
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

  get '/confirm' do
    @reg = @db.get('registrations/'+params['id'])
    haml :confirm
  end

  post '/confirm' do
    @reg = @db.get('registrations/'+params['id'])
    @db.set("registrations/#{params['id']}/confirmed", params['confirm'])
    @db.set("registrations/#{params['id']}/pic-terms", params['pic-terms']) if params['pic-terms']
    @success = true
    haml :confirm
  end


  post '/' do
    response = @db.push("newsletter", {
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

    if params['reg']['terms'] != 'accepted' || params['reg']['pic-terms'] != 'accepted'
      @errors.push @texts['errors-terms']
    end
    
    if @errors.empty?
      response = @db.push("registrations", params['reg'])
    end

    params[:reg_test] = 1
    @success = @errors.empty?
    haml :index
  end

  get '/admin' do
    authorize!

    get_admin_data
    setup

    haml :admin
  end

  get '/csv' do
    authorize!

    content_type 'application/csv'
    attachment "konnekt_live_registrations-#{Time.now.strftime("%Y%m%d-%H%M")}.csv"
    
    get_admin_data
    
    csv_string = CSV.generate do |csv|
      keys = ['name', 'email', 'year', 'school', 'professions', 'news', 'terms', 'pic-terms', 'created', 'confirmed', 'type']
      csv << keys + ['id', 'confirm-url']
      @regs.each do |reg|
        csv << (keys.map{|k| reg[1][k].is_a?(Array) ? reg[1][k].join(" ") : reg[1][k]} + additional_csv(reg[0]))
      end
    end
  end

  private

  def authorize!
    if params['key'] != @private_secrets['admin_key']
      redirect '/'
    end
  end

  def get_admin_data
    prefix = ''
    if params['year']
      prefix = 'archive/' + params['year'] + '/'
    end

    @news_signups = @db.get(prefix + 'newsletter') || Hash.new
    @regs = @db.get(prefix + 'registrations') || Hash.new
  end

  def setup
    @archives = @db.get('archive', {shallow: true})
    @schools = collect(@regs, 'school')
    @profs = collect_arrays(@regs, 'professions')
    @confirmed = select(@regs, 'confirmed', 'confirmed').count
    @teachers = select(@regs, 'type', 'teacher')
    @students = select(@regs, 'type', 'student')
  end

  def additional_csv(id)
    [id, "http://konnektlive.com/confirm?id=#{id}"]
  end

  def select(from, where, isWhat)
    return Hash.new if from.nil?
    from.select{|_, r| r[where] == isWhat}
  end

  def collect(original, what)
    h = Hash.new
    return h if original.nil?
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
    return h if original.nil?
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
