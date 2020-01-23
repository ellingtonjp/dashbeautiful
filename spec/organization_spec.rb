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
  end
end
