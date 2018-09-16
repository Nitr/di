require 'sinatra/base'
require 'open_weather'

class App < Sinatra::Base
  data_store = ThreadSafe::Cache.new

  container = Dry::Container.new
  container.register(:data_store, data_store)
  container.register(:current_ip, ->{ container.resolve(:data_store)[:current_ip] })
  container.register(:current_city, ->{ Ipgeobase.lookup(container.resolve(:current_ip)).city })
  container.register(:current_weather) do
    OpenWeather::Current.city(container.resolve(:current_city), { units: "metric", APPID: "cf317d7101bc15c10c4f2850d2d8f1c2" })
  end

  before do
    data_store = container.resolve(:data_store)
    data_store[:current_ip] = request.ip
  end

  get '/' do
    container.resolve(:current_city)
  end

  get '/weather' do
    container.resolve(:current_weather).to_s
  end
end
