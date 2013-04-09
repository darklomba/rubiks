require 'spec_helper'

# This example is taken from the Mondrian documentation:
# http://mondrian.pentaho.com/documentation/schema.php#Cubes_and_dimensions
# then modified to use Rails/Rubiks conventions
#
# We want the output to be:
#
# <schema>
#   <cube name="Sales">
#     <table name="view_sales"/>
#
#     <dimension name="Date" foreignKey="date_id">
#       <hierarchy name="Year Quarter Month" hasAll="false" primaryKey="id">
#         <table name="view_dates"/>
#         <level name="Year" column="year"/>
#         <level name="Quarter" column="quarter"/>
#         <level name="Month" column="month"/>
#       </hierarchy>
#     </dimension>
#
#     <measure name="Unit Sales" column="unit_sales" aggregator="sum" formatString="#,###"/>
#     <measure name="Store Sales" column="store_sales" aggregator="sum" formatString="#,###.##"/>
#     <measure name="Store Cost" column="store_cost" aggregator="sum" formatString="#,###.00"/>
#
#     <calculatedMember name="Profit" dimension="Measures" formula="[Measures].[Store Sales] - [Measures].[Store Cost]">
#       <calculatedMemberProperty name="FORMAT_STRING" value="$#,##0.00"/>
#     </calculatedMember>
#   </cube>
# </schema>

describe 'A basic Mondrian XML Schema' do
  let(:described_class) { ::Rubiks::Schema }
  let(:schema_hash) {
    {
      'cubes' => [{
        'name' => 'sales',
        'measures' => [
          {
            'name' => 'unit_sales',
            'aggregator' => 'sum',
            'format_string' => '#,###'
          },
          {
            'name' => 'store_sales',
            'aggregator' => 'sum',
            'format_string' => '#,###.##'
          },
          {
            'name' => 'store_cost',
            'aggregator' => 'sum',
            'format_string' => '#,###.00'
          }
        ],
        'dimensions' => [
          {
            'name' => 'date',
            'hierarchies' => [{
              'name' => 'year_quarter_month',
              'levels' => [
                {
                  'name' => 'year',
                  'type' => 'numeric'
                },
                {
                  'name' => 'quarter',
                  'type' => 'string'
                },
                {
                  'name' => 'month',
                  'type' => 'numeric'
                }
              ]
            }]
          }
        ]
      }]
    }
  }

  subject { described_class.new_from_hash(schema_hash) }

  describe '#to_xml' do
    it 'renders XML' do
      subject.to_xml.should be_like <<-XML
      <?xml version="1.0" encoding="UTF-8"?>

      <schema>
        <cube name="Sales">
          <table name="view_sales"/>

          <dimension name="Date" foreignKey="date_id">
            <hierarchy name="Year Quarter Month" primaryKey="id">
              <table name="view_dates"/>
              <level name="Year" column="year"/>
              <level name="Quarter" column="quarter"/>
              <level name="Month" column="month"/>
            </hierarchy>
          </dimension>

          <measure name="Unit Sales" column="unit_sales" aggregator="sum" formatString="#,###"/>
          <measure name="Store Sales" column="store_sales" aggregator="sum" formatString="#,###.##"/>
          <measure name="Store Cost" column="store_cost" aggregator="sum" formatString="#,###.00"/>

          <calculatedMember name="Profit" dimension="Measures" formula="[Measures].[Store Sales] - [Measures].[Store Cost]">
            <calculatedMemberProperty name="FORMAT_STRING" value="$#,##0.00"/>
          </calculatedMember>
        </cube>
      </schema>
      XML
    end
  end

end