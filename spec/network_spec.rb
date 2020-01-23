module Dashbeautiful
  RSpec.describe Dashbeautiful do
    describe Network do
      let(:api_key) { 'test-api-key' }
      let(:orgs) { organizations_fixture }
      let(:networks) { networks_fixture }
      let(:devices) { devices_fixture }
      let(:api) { api_double(key: api_key, organizations: orgs.values) }

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
  end
end
