# TODO: specs
#   - update_[attribute]
#   - attribute=
#   - attribute!
#   - registering API key
#   - all/find/find_by/etc
module Dashbeautiful
  RSpec.describe Dashbeautiful do
    let(:api_key) { 'test-api-key' }
    let(:orgs) { organizations_fixture }
    let(:networks) { networks_fixture }
    let(:devices) { devices_fixture }
    let(:api) { api_double(key: api_key, organizations: orgs.values) }

    describe Organization do
      let(:org_data) { orgs[:organization_one] }
      let(:organization) { Organization.new api: api, **org_data }

      before :each do
        allow(api).to receive(:networks).with(organization.id) { networks.values }
      end

      describe 'initialized with data' do
        it 'returns api' do
          expect(organization.api).to eq(api)
        end

        %i[id name url].each do |attribute|
          it "returns correct #{attribute}" do
            expect(organization.send(attribute)).to eq(org_data[attribute])
          end
        end
      end

      # TODO: specs for name!, id!, url!
      describe '#initialize' do
        [
          { nil_param: 'api', params: { api: nil, id: 1, name: 'org', url: 'url' } },
          { nil_param: 'id', params: { api: 'api', id: nil, name: 'org', url: 'url' } },
          { nil_param: 'name', params: { api: 'api', id: 1, name: nil, url: 'url' } },
          { nil_param: 'url', params: { api: 'api', id: 1, name: 'org', url: nil } }
        ].each do |h|
          it "raises ArgumentError if #{h[:nil_param]} is nil" do
            expect { Organization.new(**h[:params]) }.to raise_error(ArgumentError)
          end
        end
      end

      describe '#networks' do
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

      describe '#networks!' do
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
        describe '#init' do
          %i[id name url].each do |attribute|
            it "initializes by organization #{attribute}" do
              org = Organization.init(org_data[attribute], api: api)
              expect(org.send(attribute)).to eq(org_data[attribute])
            end
          end

          it 'raises ArgumentError if org id not accessible by user' do
            expect { Organization.init(99_999, api: api) }.to raise_error ArgumentError
          end

          it 'raises ArgumentError if name not accessible by user' do
            expect { Organization.init('non accesible org', api: api) }.to raise_error ArgumentError
          end
        end

        describe '#all' do
          it 'returns correct number of orgs' do
            expect(Organization.all(api: api).length).to eq(orgs.length)
          end

          it 'returns organizations with correct ids, names, urls with orgs on api key' do
            expect(Organization.all(api: api).map(&:id)).to eq(orgs.values.map { |o| o[:id] })
            expect(Organization.all(api: api).map(&:name)).to eq(orgs.values.map { |o| o[:name] })
            expect(Organization.all(api: api).map(&:url)).to eq(orgs.values.map { |o| o[:url] })
          end

          it 'raises argument error if no key passed' do
            expect { Organization.all }.to raise_error(ArgumentError)
          end
        end

        describe '#find_by' do
          it 'returns organization by name' do
            org = Organization.find_by(:name, 'organization two', api: api)
            expect(org.name).to eq 'organization two'
          end

          it 'returns organization by id' do
            org = Organization.find_by(:id, 1, api: api)
            expect(org.id).to eq 1
          end

          it 'returns nil if cannot find organization' do
            org = Organization.find_by(:id, 9999, api: api)
            expect(org).to be_nil
          end
        end
      end
    end

    describe Network do
      let(:organization) { Organization.new api: api, **orgs.values.first }
      let(:network_no_tags) { Network.new(organization: organization, **networks[:network_no_tags]) }
      let(:network_one_tag) { Network.new(organization: organization, **networks[:network_one_tag]) }
      let(:network_two_tags) { Network.new(organization: organization, **networks[:network_two_tags]) }
      let(:network_three_tags_not_unique) { Network.new(organization: organization, **networks[:network_three_tags_not_unique]) }
      let(:network) { network_one_tag }

      before :each do
        allow(api).to receive(:networks).with(organization.id) { networks.values }
        allow(api).to receive(:devices).with(network.id) { devices.values }
      end

      describe 'initialize' do
        it 'initializes' do
          expect(Network.new(organization: organization, id: 0, name: 'network', tags: '', type: 'network')).to be_kind_of Network
        end

        it 'returns correct id and name' do
          expect(network.id).to eq 1
          expect(network.name).to eq 'network_with_one_tag'
        end

        it 'raises ArgumentError if organization is nil' do
          expect { Network.new(nil, id: 1, name: 'network', tags: '', type: 'network') }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError if id is nil' do
          expect { Network.new(organization: organization, name: 'network', tags: '', type: 'network') }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError if name is nil' do
          expect { Network.new(organization: organization, id: 1, tags: '', type: 'network') }.to raise_error(ArgumentError)
        end

        it 'raises ArgumentError if tags is nil' do
          expect { Network.new(organization: organization, id: 1, name: 'network', type: 'camera') }.to raise_error(ArgumentError)
        end
      end

      describe 'tags' do
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
        before(:each) do
          orgs.values.each do |org|
            allow(api).to receive(:networks).with(org[:id]) { networks.values }
          end
          allow(api).to receive(:devices).with(network.id) { devices.values }
        end

        describe 'all' do
          it 'returns correct number of networks' do
            expect(Network.all(api: api).length).to eq(networks.length * orgs.length)
          end

          # TODO: doesn't work with DashboardBase
          # it 'returns networks with correct id and names' do
          #   expect(Network.all(api: api).map(&:id)).to eq(networks.values.map { |n| n[:id] })
          #   expect(Network.all(api: api).map(&:name)).to eq(networks.values.map { |n| n[:name] })
          # end

          it 'raises argument error if no org passed' do
            expect { Network.all }.to raise_error(ArgumentError)
          end
        end

        describe 'find' do
          it 'returns network with correct id' do
            network = Network.find(api: api) { |n| n.id == 1 }
            expect(network.id).to eq 1
          end

          it 'returns nil if network not found' do
            network = Network.find(api: api) { |_network| false }
            expect(network).to be_nil
          end
        end
      end
    end

    describe Device do
      # TODO: more specs
      let(:organization) { Organization.new api: api, **orgs.values.first }
      let(:network) { Network.new(organization: organization, **networks[:network_no_tags]) }
      let(:device_data) { devices[:device_mv_no_tags] }
      let(:device) { Device.new(network: network, **device_data) }

      before :each do
        # allow(api) calls
      end

      it 'returns correct name' do
        expect(device.name).to eq(devices[:device_mv_no_tags][:name])
      end
    end
  end
end
