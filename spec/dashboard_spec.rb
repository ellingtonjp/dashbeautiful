module Meraki
  module Dashboard
    RSpec.describe Dashboard do
      describe Organization do
        describe 'Organization.all' do
          context 'without initialization' do
            before :each do
              @key = 'a08458b849308f7e9c701dcf72f9b17ba4907af6'
            end

            it "should return all organizations associated with api key" do
              expect(Organization.all(@key)).not_to be_empty
            end

            it "should raise argument error if no key passed" do
              expect { Organization.all }.to raise_error(ArgumentError)
            end
          end

          context 'without initialization' do
            before :each do
              @key1 = 'a08458b849308f7e9c701dcf72f9b17ba4907af6'
              @key2 = 'a08458b849308f7e9c701dcf72f9b17ba4907af6'
              @org = Organization.init(organization: 'testbed-mv', api_key: @key1)
            end

            it "should return all organizations associated with initialized api key" do
              expect(@org.all).not_to be_empty
            end

            it "should return all organizations associated with passed api key" do
              expect(@org.all(@key2)).to_not be_empty
            end

            it "should not set new api key" do
              @org.all(@key2)
              expect(Organization.api_key).to eq @key1
              expect(@org.api_key).to eq @key1
            end
          end
        end
      end

      # before :each do
      #   @api_key = '1234'
      #   @dashboard = Dashboard::Dashboard.init(@api_key)
      # end

      # it "should initialize" do
      #   expect(@dashboard.api_key).to eq @api_key
      # end
    end
  end
end