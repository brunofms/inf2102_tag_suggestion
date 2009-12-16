require 'logger'
require "java"

require "/opt/app/weka/weka.jar"
require "/opt/app/mulan-1.0.1.jar"

include_class "java.io.ObjectOutputStream"
include_class "java.io.FileOutputStream"
include_class "mulan.data.MultiLabelInstances"
include_class "mulan.classifier.lazy.MLkNN"

class Training

  def initialize(path, filestem)

    @path = path
    @filestem = filestem

  end

  def load_dataset

    $log.info "Loading the training set"
    train_data = MultiLabelInstances.new(
      @path + @filestem + "-train.arff",
      @path + @filestem + ".xml")

    return train_data

  end

  def build_model(train_data)

    $log.info "Training data: MLkNN"
    num_of_neighbors = 10
    smooth = 1.0
    mlknn = MLkNN.new(num_of_neighbors, smooth)
    mlknn.build(train_data)

    return mlknn

  end

  def serialize_model(model)

    $log.info "Serialing model"
    fos = FileOutputStream.new(@path + @filestem + "-mlknn.model")
    oos = ObjectOutputStream.new(fos)
    oos.writeObject(model);
		oos.flush();
		oos.close();
    
  end

end