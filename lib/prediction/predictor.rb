require "java"

require "/opt/app/weka/weka.jar"
require "/opt/app/mulan-1.0.1.jar"

include_class "java.io.ObjectInputStream"
include_class "java.io.FileInputStream"
include_class "java.util.Arrays"
include_class "mulan.data.MultiLabelInstances"
include_class "mulan.classifier.lazy.MLkNN"
include_class "mulan.classifier.MultiLabelOutput"
include_class "weka.core.Instance"

class Predictor

  def initialize (serialized_model)

    puts "Deserializing model"

    fis = FileInputStream.new serialized_model
    ois = ObjectInputStream.new fis
    @model = ois.readObject
		ois.close
  end

  def get_predictions

    tags = Array.new
    regexp = /TAG_(\S*)/

    puts "Loading the unlabeled data set"
    unlabeled_data = MultiLabelInstances.new "/Users/brunofms/Dropbox/PUC/INF2102/Dataset/sportv/sportv_dev_predict.arff", "/Users/brunofms/Dropbox/PUC/INF2102/Dataset/sportv/sportv_dev.xml"
    num_instances = unlabeled_data.getDataSet().numInstances()

    (1..num_instances).each do |i|
      instance = Instance.new unlabeled_data.getDataSet().instance(i-1)
      instance.setDataset(unlabeled_data.getDataSet())

      # FIXME: resolver bug no numAttributes()
      # puts instance.numAttributes()

      puts "Predicting"
      output = @model.makePrediction(instance)

      if output.hasRanking
        ranking = output.getRanking

        # TODO: colocar ranking, bipartition e confidences num hash
        (1..(ranking.size()-17)).each do |j|
          if ranking[j-1] <= 15
            tags << regexp.match(instance.attribute(j-1+17).to_s)[1]
          end
        end
      end

    end

    tags

  end
end