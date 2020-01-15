# TODO: test update methods
module Dashbeautiful
  RSpec.describe Dashbeautiful do
    let(:api_key) { 'test-api-key' }
    let(:orgs) { organizations_fixture }
    let(:networks) { networks_fixture }
    let(:devices) { devices_fixture }
    let(:api) { api_double(key: api_key, organizations: orgs.values) }

    describe Organization do
      let(:org_data) { orgs[:organization_one] }
      let(:organization) { Organization.new api, **org_data }

      before :each do
        allow(api).to receive(:networks).with(organization.id) { networks.values }
      end

      it 'returns correct api key' do
        expect(organization.api_key).to eq('test-api-key')
      end

      it 'returns correct id' do
        expect(organization.id).to eq(org_data[:id])
      end

      it 'returns correct name' do
        expect(organization.name).to eq(org_data[:name])
      end

      it 'returns correct url' do
        expect(organization.url).to eq(org_data[:url])
      end

      describe 'networks' do
        it 'returns correct number of networks' do
          expect(organization.networks.length).to eq(networks.length)
        end

        it 'returns list of network objects with correct ids' do
          expect(organization.networks.map(&:id)).to eq(networks.values.map { |n| n[:id] })
        end

        it 'returns empty array on org with no networks' do
          api = api_double
          allow(api).to receive(:networks).with(1) { [] }
          organization.api = api
          expect(organization.networks).to be_empty
        end

        it 'returns cached value' do
          api_old = api_double
          allow(api_old).to receive(:networks).with(1) { [networks.values[0]] }

          organization.api = api_old

          old_value = organization.networks

          api_new = api_double
          allow(api_new).to receive(:networks).with(1) { [networks.values[1]] }
          organization.api = api_new

          new_value = organization.networks
          expect(new_value).to eq(old_value)
        end
      end

      describe 'networks!' do
        it 'returns networks with correct ids' do
          expect(organization.networks!.map(&:id)).to eq(networks.values.map { |n| n[:id] })
        end

        it 'does not return cached value' do
          api_old = api_double
          allow(api_old).to receive(:networks).with(1) { [networks.values[0]] }

          organization.api = api_old

          old_value = organization.networks

          api_new = api_double
          allow(api_new).to receive(:networks).with(1) { [networks.values[1]] }
          organization.api = api_new

          new_value = organization.networks!
          expect(new_value).to_not eq(old_value)
        end
      end

      describe 'class methods' do
        describe 'init' do
          it 'initializes with organization id, name, url' do
            org = Organization.init(organization: org_data[:id], api_key: api_key, api: api)
            expect(org.id).to eq(org_data[:id])
            expect(org.name).to eq org_data[:name]
            expect(org.url).to eq org_data[:url]
          end

          it 'raises ArgumentError if org id not accessible by user' do
            expect { Organization.init(organization: 99_999, api_key: api_key, api: api) }.to raise_error ArgumentError
          end

          it 'raises ArgumentError if name not accessible by user' do
            expect { Organization.init(organization: 'non accesible org', api_key: api_key, api: api) }.to raise_error ArgumentError
          end

          it 'raises ArgumentError if url not accessible by user' do
            expect { Organization.init(organization: 'non accesible url', api_key: api_key, api: api) }.to raise_error ArgumentError
          end
        end

        describe 'all' do
          it 'returns correct number of orgs' do
            expect(Organization.all(api_key, api: api).length).to eq(orgs.length)
          end

          it 'returns organizations with correct ids, names, urls with orgs on api key' do
            expect(Organization.all(api_key, api: api).map(&:id)).to eq(orgs.values.map { |o| o[:id] })
            expect(Organization.all(api_key, api: api).map(&:name)).to eq(orgs.values.map { |o| o[:name] })
            expect(Organization.all(api_key, api: api).map(&:url)).to eq(orgs.values.map { |o| o[:url] })
          end

          it 'raises argument error if no key passed' do
            expect { Organization.all }.to raise_error(ArgumentError)
          end
        end

        describe 'find_by' do
          it 'returns organization by name' do
            org = Organization.find_by(:name, 'organization two', api_key, api: api)
            expect(org.name).to eq 'organization two'
          end

          it 'returns organization by id' do
            org = Organization.find_by(:id, 1, api_key, api: api)
            expect(org.id).to eq 1
          end

          it 'returns nil if cannot find organization' do
            org = Organization.find_by(:id, 9999, api_key, api: api)
            expect(org).to be_nil
          end
        end
      end
    end

    describe Network do
      let(:organization) { Organization.new api, **orgs.values.first }
      let(:network_no_tags) { Network.new(organization, **networks[:network_no_tags]) }
      let(:network_one_tag) { Network.new(organization, **networks[:network_one_tag]) }
      let(:network_two_tags) { Network.new(organization, **networks[:network_two_tags]) }
      let(:network_three_tags_not_unique) { Network.new(organization, **networks[:network_three_tags_not_unique]) }
      let(:network) { network_one_tag }

      before :each do
        allow(api).to receive(:networks).with(organization.id) { networks.values }
        allow(api).to receive(:devices).with(network.id) { devices.values }
      end

      describe 'initialize' do
        it 'initializes' do
          expect(Network.new(organization, id: 0, name: 'network', tags: '')).to be_kind_of Network
        end

        it 'returns correct id and name' do
          expect(network.id).to eq 1
          expect(network.name).to eq 'network_with_one_tag'
        end

        it 'returns empty list when tags empty' do
          expect(network_no_tags.tags).to eq []
        end

        it 'returns list containing single tag when single tag' do
          expect(network_one_tag.tags.sort).to eq ['network-tag-one']
        end

        it 'returns list of tags when multiple tags' do
          expect(network_two_tags.tags.sort).to eq %w[network-tag-one network-tag-two]
        end

        it 'returns list of unique tags when same tag specified twice' do
          expect(network_three_tags_not_unique.tags.sort).to eq(%w[network-tag-one network-tag-two])
        end

        it 'raises ArgumentError if id is nil' do
          expect { Network.new(@org, name: 'network', tags: '') }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError if name is nil' do
          expect { Network.new(@org, id: 1, tags: '') }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError if tags is nil' do
          expect { Network.new(@org, id: 1, name: 'network') }.to raise_error(ArgumentError)
        end
      end

      describe 'devices' do
        it 'returns correct number of devices' do
          expect(network.devices.length).to eq(devices.length)
        end

        it 'returns list of device objects with correct names' do
          expect(network.devices.map(&:name)).to eq(devices.values.map { |d| d[:name] })
        end

        it 'returns empty array on network with no devices' do
          allow(api).to receive(:devices).with(network.id) { [] }
          expect(network.devices).to be_empty
        end

        it 'returns cached value' do
          api_old = api_double
          allow(api_old).to receive(:devices).with(network.id) { [devices.values[0]] }

          organization.api = api_old

          old_value = network.devices

          api_new = api_double
          allow(api_new).to receive(:devices).with(network.id) { [devices.values[1]] }
          organization.api = api_new

          new_value = network.devices
          expect(new_value).to eq(old_value)
        end
      end

      describe 'devices!' do
        it 'returns devices with correct name' do
          expect(network.devices!.map(&:name)).to eq(devices.values.map { |d| d[:name] })
        end

        it 'does not return cached value' do
          api_old = api_double
          allow(api_old).to receive(:devices).with(network.id) { [devices.values[0]] }

          organization.api = api_old

          old_value = network.devices

          api_new = api_double
          allow(api_new).to receive(:devices).with(network.id) { [devices.values[0]] }
          organization.api = api_new

          new_value = network.devices!
          expect(new_value).to_not eq(old_value)
        end
      end

      describe 'class methods' do
        describe 'all' do
          it 'returns correct number of networks' do
            expect(Network.all(organization).length).to eq(networks.length)
          end

          it 'returns networks with correct id and names' do
            expect(Network.all(organization).map(&:id)).to eq(networks.values.map { |n| n[:id] })
            expect(Network.all(organization).map(&:name)).to eq(networks.values.map { |n| n[:name] })
          end

          it 'raises argument error if no org passed' do
            expect { Network.all }.to raise_error(ArgumentError)
          end
        end

        describe 'find' do
          it 'returns network with correct id' do
            network = Network.find(organization) { |n| n.id == 1 }
            expect(network.id).to eq 1
          end

          it 'returns nil if network not found' do
            network = Network.find(organization) { |_network| false }
            expect(network).to be_nil
          end
        end

        describe 'find_by_id' do
          it 'returns network with the correct id' do
            expect(Network.find_by_id(1, organization).id).to eq 1
          end

          it 'returns nil if network not found' do
            network = Network.find_by_id(9999, organization)
            expect(network).to be_nil
          end
        end

        describe 'find_by_name' do
          it 'returns network with the correct name' do
            expect(Network.find_by_name('network_with_no_tags', organization).name).to eq('network_with_no_tags')
          end

          it 'returns nil if network not found' do
            network = Network.find_by_name('non existant network', organization)
            expect(network).to be_nil
          end
        end
      end
    end

    describe Device do
      # TODO: more specs
      let(:organization) { Organization.new api, **orgs.values.first }
      let(:network) { Network.new(organization, **networks[:network_no_tags]) }
      let(:device) { Device.new(network, **devices[:device_mv_no_tags]) }

      before :each do
        # allow(api) calls
      end

      it 'returns correct name' do
        expect(device.name).to eq devices[:device_mv_no_tags][:name]
      end
    end
  end
end
