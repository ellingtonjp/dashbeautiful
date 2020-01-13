module Meraki
  module Dashboard
    RSpec.describe Dashboard do
      before :each do
        # test data associated with api key 1
        @key1 = 'testapikey'
        @organizations_key1 = [
          { id: 1, name: 'organization key1 one', url: 'https://dashboard.meraki.com/o/org_key1_1/manage/organization/overview' },
          { id: 2, name: 'organization key1 two', url: 'https://dashboard.meraki.com/o/org_key1_2/manage/organization/overview' },
          { id: 3, name: 'organization key1 three', url: 'https://dashboard.meraki.com/o/org_key1_3/manage/organization/overview' }
        ]
        @organization_key1_ids = @organizations_key1.map { |org| org[:id] }
        @organization_key1_names = @organizations_key1.map { |org| org[:name] }
        @organization_key1_urls = @organizations_key1.map { |org| org[:url] }
        # TODO: add rest of attributes
        @networks_org1 = [
          { id: 1, name: 'network_1' },
          { id: 2, name: 'network_2' },
          { id: 3, name: 'network_3' }
        ]
        @network_org1_ids = @networks_org1.map { |network| network[:id] }
        @network_org1_names = @networks_org1.map { |network| network[:name] }
        @api1 = instance_double('Meraki::API',
                                 organizations: @organizations_key1,
                                 networks: @networks_org1,
                                 key: @key1)

        # test data associated with api key 2
        @key2 = 'testapikey'
        @organizations_key2 = [
          { id: 4, name: 'organization key2 one', url: 'https://dashboard.meraki.com/o/org_key2_1/manage/organization/overview' },
          { id: 5, name: 'organization key2 two', url: 'https://dashboard.meraki.com/o/org_key2_2/manage/organization/overview' },
          { id: 6, name: 'organization key2 three', url: 'https://dashboard.meraki.com/o/org_key2_3/manage/organization/overview' }
        ]
        @organization_key2_ids = @organizations_key2.map { |org| org[:id] }
        @organization_key2_names = @organizations_key2.map { |org| org[:name] }
        @organization_key2_urls = @organizations_key2.map { |org| org[:url] }
        @api2 = instance_double('Meraki::API',
                                 organizations: @organizations_key2,
                                 networks: @networks_org1,
                                 key: @key2)

      end

      describe Organization do
        before :each do
          @org_data = @organizations_key1.first
          @org = Organization.new @api1, **@org_data
        end

        it 'returns correct api key' do
          expect(@org.api_key).to eq @api1.key
        end

        it 'returns correct id' do
          expect(@org.id).to eq @org_data[:id]
        end

        it 'returns correct name' do
          expect(@org.name).to eq @org_data[:name]
        end

        it 'returns correct url' do
          expect(@org.url).to eq @org_data[:url]
        end

        describe 'networks' do
          it 'returns correct number of networks' do
            expect(@org.networks.length).to eq @networks_org1.length
          end

          it 'returns list of network objects with correct ids' do
            expect(@org.networks.map(&:id)).to eq @network_org1_ids
          end

          it 'returns empty array on org with no networks' do
            api = instance_double('Meraki::API',
                                  organizations: @organizations_key1,
                                  networks: [],
                                  key: @key1)
            org = Organization.new api, **@organizations_key1.first
            expect(org.networks).to be_empty
          end
        end

        describe 'class methods' do
          describe 'init' do
            it 'initializes with organization id' do
              org = Organization.init(organization: @organization_key1_ids[0], api_key: @key1, api: @api1)
              expect(org.id).to eq @organization_key1_ids[0]
            end

            it 'initializes with organization name' do
              org = Organization.init(organization: @organization_key1_names[0], api_key: @key1, api: @api1)
              expect(org.name).to eq @organization_key1_names[0]
            end

            it 'initializes with organization url' do
              org = Organization.init(organization: @organization_key1_urls[0], api_key: @key1, api: @api1)
              expect(org.url).to eq @organization_key1_urls[0]
            end

            it 'raises ArgumentError if org id not accessible by user' do
              expect { Organization.init(organization: 99_999, api_key: @key1, api: @api1) }.to raise_error ArgumentError
            end

            it 'raises ArgumentError if name not accessible by user' do
              expect { Organization.init(organization: 'non accesible org', api_key: @key1, api: @api1) }.to raise_error ArgumentError
            end

            it 'raises ArgumentError if url not accessible by user' do
              expect { Organization.init(organization: 'non accesible url', api_key: @key1, api: @api1) }.to raise_error ArgumentError
            end
          end

          describe 'all' do
            it 'returns correct number of orgs' do
              expect(Organization.all(@key1, api: @api1).length).to eq(@organizations_key1.length)
            end

            it 'returns organizations with correct ids with orgs on api key' do
              expect(Organization.all(@key1, api: @api1).map(&:id)).to eq(@organization_key1_ids)
            end

            it 'returns organizations with correct names with orgs on api key' do
              expect(Organization.all(@key1, api: @api1).map(&:name)).to eq(@organization_key1_names)
            end

            it 'returns organizations with correct urls with orgs on api key' do
              expect(Organization.all(@key1, api: @api1).map(&:url)).to eq(@organization_key1_urls)
            end

            it 'raises argument error if no key passed' do
              expect { Organization.all }.to raise_error(ArgumentError)
            end
          end

          describe 'find_by' do
            it 'returns organization by name' do
              org = Organization.find_by(:name, 'organization key1 one', @key1, api: @api1)
              expect(org.name).to eq 'organization key1 one'
            end

            it 'returns organization by id' do
              org = Organization.find_by(:id, 1, @key1, api: @api1)
              expect(org.id).to eq 1
            end

            it 'returns nil if cannot find organization' do
              org = Organization.find_by(:id, 9999, @key1, api: @api1)
              expect(org).to be_nil
            end
          end
        end
      end

      # TODO: add rest of network attributes
      describe Network do
        before :each do
          @org_data = @organizations_key1.first
          @org = Organization.new @api1, **@org_data
          @network = Network.new @org, **@networks_org1.first
        end

        it 'returns correct api key' do
          expect(@network.api_key).to eq @api1.key
        end

        describe 'class methods' do
          describe 'all' do
            it 'returns correct number of networks' do
              expect(Network.all(@org).length).to eq(@networks_org1.length)
            end

            it 'returns networks with correct ids' do
              expect(Network.all(@org).map(&:id)).to eq(@network_org1_ids)
            end

            it 'returns networks with correct names' do
              expect(Network.all(@org).map(&:name)).to eq(@network_org1_names)
            end

            it 'raises argument error if no org passed' do
              expect { Network.all }.to raise_error(ArgumentError)
            end
          end

          describe 'find' do
            it 'returns network with correct id' do
              network = Network.find(@org) { |network| network.id == 1 }
              expect(network.id).to eq 1
            end

            it 'returns nil if network not found' do
              network = Network.find(@org) { |_network| false }
              expect(network).to be_nil
            end
          end

          describe 'find_by_id' do
            it 'returns network with the correct id' do
              expect(Network.find_by_id(1, @org).id).to eq 1
            end

            it 'returns nil if network not found' do
              network = Network.find_by_id(9999, @org)
              expect(network).to be_nil
            end
          end

          describe 'find_by_name' do
            it 'returns network with the correct name' do
              expect(Network.find_by_name('network_1', @org).name).to eq 'network_1'
            end

            it 'returns nil if network not found' do
              network = Network.find_by_name('non existant network', @org)
              expect(network).to be_nil
            end
          end
        end

        it 'initializes' do
          puts @organizations_key.inspect
          org = Organization.new @api1, **@organizations_key1.first
          network = Network.new(org, id: 11, name: 'network')
          expect(network.name).to eq 'network'
        end
      end
    end
  end
end
