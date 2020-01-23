module Dashbeautiful
  RSpec.describe Dashbeautiful do
    describe Device do
      let(:api_key) { 'test-api-key' }
      let(:orgs) { organizations_fixture }
      let(:networks) { networks_fixture }
      let(:devices) { devices_fixture }
      let(:api) { api_double(key: api_key, organizations: orgs.values) }

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
