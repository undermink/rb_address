require 'sinatra/base'
require 'data_mapper'
require 'pp'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, (ENV["DATABASE_URL"]|| 'sqlite://'+File.expand_path('../adressen.db',__FILE__)))
DataMapper::Model.raise_on_save_failure=true

class Address
  include DataMapper::Resource
  property :id, Serial
  property :name, Text
  property :vorname, Text
  property :strasse, Text
  property :hausnr, Text
  property :plz, Text
  property :wohnort, Text
  property :land, Text
  property :email, Text
  property :tel, Text
  property :alias, Text
  property :url, Text
end


DataMapper.finalize
DataMapper.auto_upgrade!


class AddressApp < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/neu' do
    erb :neu
  end

  post '/entry' do
    Address.create!(params)
    pp params
    redirect '/'
  end

  post '/delete' do
    pp params
    @del=Address.get(params["id"])
    @del.destroy
    redirect 'search'
  end

  get '/search' do
    hash={}
    Address.properties.each{|p|
      hash[p.name.like]=params[p.name.to_s]+"%" if params[p.name.to_s]
    }
    @address=Address.all(hash)
    erb :result
  end

end
