# sincapun.rb
# require 'pony'
# require 'net/http'
# require 'uri'
# require 'json'

class KonnektLive < Sinatra::Base
  get '/' do
    haml :index
  end

#   post '/' do
#     uri = URI.parse('https://www.google.com/recaptcha/api/siteverify')
#     response = Net::HTTP.post_form(uri, {
#       secret: '6LfWeiETAAAAALRKMOPFflJeuGabk0StvGoADdii',
#       response: params['g-recaptcha-response']
#       })
#     if JSON.parse(response.body)['success']
#       Pony.mail to: 'azeroths@gmail.com',
#                 from: "#{params[:name]} <#{params[:email]}>",
#                 subject: params[:message][0..40],
#                 body: params[:message]
#       @sent = true
#     else
#       @error = true
#     end
#     haml :index
#   end
end
