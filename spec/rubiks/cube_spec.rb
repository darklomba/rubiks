require 'spec_helper'

describe ::Rubiks::Cube do
  subject { described_class.new }

  it_behaves_like 'a named object'

  its(:to_xml) { should be_equivalent_to(Nokogiri::XML(<<-XML)) }
    <cube name="Default">
      <table name="view_defaults"/>
    </cube>
  XML
end
