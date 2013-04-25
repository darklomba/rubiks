module ::Rubiks

  class Dimension < NamedObject
    def type(new_value=nil)
      @type = new_value.to_s if new_value.present?
      @type ||= @options[:type]
    end

    def hierarchies
      @hierarchies ||= []
    end

    def hierarchy(hierarchy_name, options={}, &block)
      options.merge!(:table_name => self.table_name)
      hierarchies.push ::Rubiks::Hierarchy.find_or_create(hierarchy_name, options, &block)
    end

    def json_hash
      hash = default_json_attributes.merge(
        :hierarchies => hierarchies.map{ |hier| hier.json_hash }
      )
      hash[:type] = type.to_s if type.present?
      hash.delete_if { |key,value| value.nil? }
    end

    def to_xml(builder = nil)
      builder = builder || new_builder

      xml_attrs = default_xml_attributes.merge(:foreignKey => "#{name}_id")
      xml_attrs[:type] = type if type.present?
      builder.dimension(xml_attrs) do
        hierarchies.each{ |hierarchy| hierarchy.to_xml(builder) }
      end
    end
  end

end
