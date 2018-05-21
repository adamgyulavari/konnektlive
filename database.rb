require 'firebase'

class Database
  def initialize
    private_key_json_string = File.open('config/konnektlive-firebase.json').read
    @firebase = Firebase::Client.new("https://konnektlive.firebaseio.com", private_key_json_string)
  end

  def get(name)
    @firebase.get(name).body
  end

  def set(path, data)
    @firebase.set(path, data)
  end

  def push(name, value)
    value['created'] = Firebase::ServerValue::TIMESTAMP
    @firebase.push(name, value)
  end
end
