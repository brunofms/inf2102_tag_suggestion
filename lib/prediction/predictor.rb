require "java"
require "rexml/document"

require "/opt/app/weka/weka.jar"
require "/opt/app/mulan-1.0.1.jar"

include_class "java.io.ObjectInputStream"
include_class "java.io.FileInputStream"
include_class "java.lang.System"
include_class "java.util.Arrays"

include_class "mulan.data.MultiLabelInstances"
include_class "mulan.classifier.lazy.MLkNN"
include_class "mulan.classifier.MultiLabelOutput"

include_class "weka.core.Attribute"
include_class "weka.core.FastVector"
include_class "weka.core.Instance"
include_class "weka.core.Instances"

class Predictor

  def initialize (serialized_model)

    puts "Deserializing model"

    fis = FileInputStream.new serialized_model
    ois = ObjectInputStream.new fis
    @model = ois.readObject
		ois.close

    @labels = get_labels
  end

  def get_predictions(text)

    tags = []
    tokens = []

    text.split(/[\W]+/).each do |token|
      tokens << token.downcase
    end

    puts "Loading the unlabeled data set"
    instance = create_instance(tokens)

    puts "Predicting"

    output = @model.makePrediction(instance)

    if output.hasRanking
      ranking = output.getRanking
      offset =  instance.numAttributes
      labels = get_labels

      # TODO: colocar ranking, bipartition e confidences num hash
      (1..(ranking.size() - offset)).each do |j|
        if ranking[j-1] <= 10
          tags << /TAG_(\S*)/.match(@labels[j-1])[1]
        end
      end
    end

    tags

  end

  private
  def create_instance(tokens)

    # set up attributes
    atts = FastVector.new
    att_vals = FastVector.new

    att_vals.addElement("0")
    att_vals.addElement("1")

    tokens.each do |token|
      atts.addElement(Attribute.new(token, att_vals))
    end

    # create Instances object
    data = Instances.new("Unlabelled", atts, 0)

    # fill with data
    vals = Array.new(data.numAttributes())
    (1..tokens.size).each do |z|
      vals[z-1] = atts.indexOf(Attribute.new(tokens[z-1], att_vals))
    end

    vals_d = vals.to_java :double

    instance = Instance.new(1.0,vals_d)
    instance.setDataset(data)
    data.add(instance)

    return instance
  end

  def get_labels
    labels = []
    # TODO: put into a config file
    file = File.new("/Users/brunofms/Dropbox/PUC/INF2102/Dataset/sportv/sportv_dev.xml")
    doc = REXML::Document.new(file)

    doc.elements.each('labels/label') do |label|
      labels << label.attributes['name']
    end

    return labels
  end
end