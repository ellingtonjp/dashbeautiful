module Meraki
  module Dashboard
    RSpec.describe Dashboard do
      describe Organization do
        before :each do
          # test data associated with api key 1
          @organizations_key1 = [
            { id: 1, name: 'organization key1 one', url: 'https://dashboard.meraki.com/o/org_key1_1/manage/organization/overview' },
            { id: 2, name: 'organization key1 two', url: 'https://dashboard.meraki.com/o/org_key1_2/manage/organization/overview' },
            { id: 3, name: 'organization key1 three', url: 'https://dashboard.meraki.com/o/org_key1_3/manage/organization/overview' }
          ]
          @organization_key1_ids = @organizations_key1.map { |org| org[:id] }
          @organization_key1_names = @organizations_key1.map { |org| org[:name] }
          @organization_key1_urls = @organizations_key1.map { |org| org[:url] }
          @key1 = 'testapikey'
          @http1 = instance_double('Meraki::HTTP',
                                   organizations: @organizations_key1,
                                   api_key: @key1)

          # test data associated with api key 2
          @organizations_key2 = [
            { id: 4, name: 'organization key2 one', url: 'https://dashboard.meraki.com/o/org_key2_1/manage/organization/overview' },
            { id: 5, name: 'organization key2 two', url: 'https://dashboard.meraki.com/o/org_key2_2/manage/organization/overview' },
            { id: 6, name: 'organization key2 three', url: 'https://dashboard.meraki.com/o/org_key2_3/manage/organization/overview' }
          ]
          @organization_key2_ids = @organizations_key2.map { |org| org[:id] }
          @organization_key2_names = @organizations_key2.map { |org| org[:name] }
          @organization_key2_urls = @organizations_key2.map { |org| org[:url] }
          @key2 = 'testapikey'
          @http2 = instance_double('Meraki::HTTP',
                                   organizations: @organizations_key2,
                                   api_key: @key2)
        end

        describe 'Organization.init' do
          it 'initializes with organization id' do
            expect(Organization.init(organization: @organization_key1_ids[0], api_key: @key1, http: @http1)).not_to be_nil
          end

          it 'initializes with organization name' do
            expect(Organization.init(organization: @organization_key1_names[0], api_key: @key1, http: @http1)).not_to be_nil
          end

          it 'initializes with organization url' do
            expect(Organization.init(organization: @organization_key1_urls[0], api_key: @key1, http: @http1)).not_to be_nil
          end

          it 'raises ArgumentError if org id not accessible by user' do
            expect { Organization.init(organization: 99_999, api_key: @key1, http: @http1) }.to raise_error ArgumentError
          end

          it 'raises ArgumentError if name not accessible by user' do
            expect { Organization.init(organization: 'non accesible org', api_key: @key1, http: @http1) }.to raise_error ArgumentError
          end

          it 'raises ArgumentError if url not accessible by user' do
            expect { Organization.init(organization: 'non accesible url', api_key: @key1, http: @http1) }.to raise_error ArgumentError
          end
        end

        describe 'Organization.all' do
          it 'returns organizations with correct ids with orgs on api key' do
            expect(Organization.all(@key1, http: @http1).map(&:id)).to eq(@organization_key1_ids)
          end

          it 'returns organizations with correct names with orgs on api key' do
            expect(Organization.all(@key1, http: @http1).map(&:name)).to eq(@organization_key1_names)
          end

          it 'returns organizations with correct urls with orgs on api key' do
            expect(Organization.all(@key1, http: @http1).map(&:url)).to eq(@organization_key1_urls)
          end

          it 'raises argument error if no key passed' do
            expect { Organization.all }.to raise_error(ArgumentError)
          end
        end

        describe 'Organization.find_by' do
          it 'returns organization by name' do
            org = Organization.find_by(:name, 'organization key1 one', @key1, http: @http1)
            expect(org.name).to eq 'organization key1 one'
          end

          it 'returns organization by id' do
            org = Organization.find_by(:id, 1, @key1, http: @http1)
            expect(org.id).to eq 1
          end

          it 'returns nil if cannot find organization' do
            org = Organization.find_by(:id, 9999, @key1, http: @http1)
            expect(org).to be_nil
          end
        end

        describe 'Organization.init' do
        end

        # TODO: all Organization methods
      end
    end
  end
end
