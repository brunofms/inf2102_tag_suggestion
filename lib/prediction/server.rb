#

require 'rubygems'
require 'sinatra'
require 'Builder'

require 'predictor'

configure do
  # TODO: Singleton implementation?
  $p = Predictor.new("/Users/brunofms/Dropbox/PUC/INF2102/Dataset/sportv/sportv_dev-mlknn.model")
end

get '/tags' do
  builder do |xml|
    xml.instruct!
    xml.tags do
      $p.get_predictions.each do |tag|
        xml.tag "#{tag}"
      end
    end
  end
end