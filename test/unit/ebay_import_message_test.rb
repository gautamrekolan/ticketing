require 'test_helper'
require 'fakeweb'
require 'pp'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def mock_xml_response(file)
    xml_file = File.new(File.join(Rails.root.to_s, 'test', 'fixtures', 'ebay_api', 'messages', file))
    xml = xml_file.read
  end
  
  def register_xml_files(*responses)
      responses.collect! do |r|
        {:body => r }
      end
      FakeWeb.register_uri(:post, "https://api.ebay.com/ws/api.dll", responses)
  end
  
  def setup
    EbayLastImportedTime.instance.update_attributes(:last_import => Time.now)
    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")

    @get_my_messages_response = mock_xml_response('get_my_messages_response.xml')
    @return_messages_response = mock_xml_response('get_return_messages_response.xml')
  end

  test "adds message to existing customer when matching user ID" do
    @return_messages_response.gsub!("jemmamadhouse", "mister-dizzy") 
    register_xml_files(@get_my_messages_response, @return_messages_response, @return_messages_response)
    result = ImportEbayMessages.new
    result.import!
    pp Customer.all
    pp EbayMessage.all
    pp Conversation.all
    
  end

end
