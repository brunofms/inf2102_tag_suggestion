require "rubygems"
require "daemons"

require 'config'
require 'training'

def main
  
  include Config

  $log = Logger.new(LOG[:path], 'daily')

  loop do

    t = Training.new(DATASET[:path],DATASET[:filestem])
    t.serialize_model(t.build_model(t.load_dataset))

    sleep(120)

  end
  
end

main