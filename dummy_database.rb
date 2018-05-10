require 'json'

class Database
  def initialize
    @data_hash = JSON.parse(File.read('dummy_data.json'))
    @a = 'qwertyuioasdfghjlzxcvbm1234567890'.split('')
  end

  def get(name)
    @data_hash[name]
  end

  def push(name, value)
    @data_hash[name][random_hash(8)] = value
  end

  private

  def random_hash(number)
    number.times.map{|_| @a.sample}.join('')
  end
end
