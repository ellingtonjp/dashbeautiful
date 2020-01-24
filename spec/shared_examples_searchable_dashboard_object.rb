RSpec.shared_examples 'SearchableDashboardObject' do
  %i[_all all all! find find! find_by find_by! searchable_attributes retrieve].each do |message|
    it "responds to #{message}" do
      expect(described_class.respond_to?(message))
    end
  end
end
