require 'rubiks/nodes/annotated_node'
require 'rubiks/nodes/dimension'
require 'rubiks/nodes/measure'

module ::Rubiks

  class Cube < ::Rubiks::AnnotatedNode
    child :dimensions, [::Rubiks::Dimension]
    child :measures, [::Rubiks::Measure]

    validates :dimensions_present, :measures_present

    def self.new_from_hash(hash={})
      new_instance = new('',[],[])
      return new_instance.from_hash(hash)
    end

    def from_hash(working_hash)
      return self if working_hash.nil?
      working_hash.stringify_keys!

      parse_name(working_hash.delete('name'))
      parse_dimensions(working_hash.delete('dimensions'))
      parse_measures(working_hash.delete('measures'))
      return self
    end

    def measures_present
      if self.measures.present?
        self.measures.each do |measure|
          measure.validate
          errors.push(*measure.errors)
        end
      else
        errors << 'Measures Required for Cube'
      end
    end

    def parse_measures(measures_array)
      return if measures_array.nil? || measures_array.empty?

      measures_array.each do |measure_hash|
        self.measures << ::Rubiks::Measure.new_from_hash(measure_hash)
      end
    end

    def dimensions_present
      if self.dimensions.present?
        self.dimensions.each do |dimension|
          dimension.validate
          errors.push(*dimension.errors)
        end
      else
        errors << 'Dimensions Required for Cube'
      end
    end

    def parse_dimensions(dimensions_array)
      return if dimensions_array.nil? || dimensions_array.empty?

      dimensions_array.each do |dimension_hash|
        self.dimensions << ::Rubiks::Dimension.new_from_hash(dimension_hash)
      end
    end

    def to_hash
      hash = {}

      hash['name'] = self.name.to_s if self.name.present?
      hash['dimensions'] = self.dimensions.map(&:to_hash) if self.dimensions.present?
      hash['measures'] = self.measures.map(&:to_hash) if self.measures.present?

      return hash
    end

    def to_xml(builder = nil)
      builder = Builder::XmlMarkup.new(:indent => 2) if builder.nil?

      attrs = self.to_hash
      builder.cube('name' => attrs['name']) {
        builder.table('name' => "view_#{attrs['name']}")

        self.dimensions.each{ |dim| dim.to_xml(builder) } if self.dimensions.present?
        self.measures.each{ |measure| measure.to_xml(builder) } if self.measures.present?
      }
    end
  end

end