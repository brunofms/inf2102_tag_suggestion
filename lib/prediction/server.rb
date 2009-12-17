#

require 'rubygems'
require 'sinatra'
require 'Builder'

require 'predictor'

configure do
  $p = Predictor.new("/Users/brunofms/Dropbox/PUC/INF2102/Dataset/sportv/sportv_dev-mlknn.model")
end

get '/tags' do
  text = params[:titulo] + ' ' + params[:descricao]
  
  builder do |xml|
    xml.instruct!
    xml.tags do
      $p.get_predictions(text).each do |tag|
        xml.tag "#{tag}"
      end
    end
  end
end