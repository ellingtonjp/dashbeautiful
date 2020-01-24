module Dashbeautiful
  RSpec.describe Dashbeautiful do
    # business logic tests for module
    describe SearchableDashboardObject do
      Obj = Struct.new(:id, :foo, :bar)

      let(:dbl) do
        dbl = double
        dbl.extend(SearchableDashboardObject)
        dbl
      end

      let(:api) { double }

      describe '#all' do
        it 'calls _all' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all(api: api)
        end

        it 'calls _all once if run twice' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all(api: api)
          dbl.all(api: api)
        end

        it 'returns cached value' do
          allow(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all(api: api)
          allow(dbl).to receive(:_all).with(api: api).and_return([4, 5, 6])
          value = dbl.all(api: api)
          expect(value).to eq([1, 2, 3])
        end
      end

      describe '#all!' do
        it 'calls _all' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all(api: api)
        end

        it 'calls _all twice if run twice' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all!(api: api)
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all!(api: api)
        end

        it 'returns new value' do
          allow(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3])
          dbl.all(api: api)
          allow(dbl).to receive(:_all).with(api: api).and_return([4, 5, 6])
          value = dbl.all!(api: api)
          expect(value).to eq([4, 5, 6])
        end
      end

      describe '#find' do
        it 'returns correct value' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3, 4])
          expect(dbl.find(api: api) { |e| e == 3 }).to eq(3)
        end

        it 'returns nil if element not in list' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3, 4])
          expect(dbl.find(api: api) { |e| e == 5 }).to be_nil
        end

        it 'returns cached value' do
          allow(dbl).to receive(:_all).with(api: api).and_return([{ id: 0, foo: 'foo' }, { id: 1, foo: 'bar' }])
          expect(dbl.find(api: api) { |e| e[:foo] == 'foo' }[:id]).to eq(0)

          allow(dbl).to receive(:_all).with(api: api).and_return([{ id: 0, foo: 'bar' }, { id: 1, foo: 'foo' }])
          expect(dbl.find(api: api) { |e| e[:foo] == 'foo' }[:id]).to eq(0)
        end
      end

      describe '#find!' do
        it 'returns correct value' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3, 4])
          expect(dbl.find!(api: api) { |e| e == 3 }).to eq(3)
        end

        it 'returns nil if element not in list' do
          expect(dbl).to receive(:_all).with(api: api).and_return([1, 2, 3, 4])
          expect(dbl.find(api: api) { |e| e == 5 }).to be_nil
        end

        it 'returns new value' do
          allow(dbl).to receive(:_all).with(api: api).and_return([{ id: 0, foo: 'foo' }, { id: 1, foo: 'bar' }])
          expect(dbl.find!(api: api) { |e| e[:foo] == 'foo' }[:id]).to eq(0)

          allow(dbl).to receive(:_all).with(api: api).and_return([{ id: 0, foo: 'bar' }, { id: 1, foo: 'foo' }])
          expect(dbl.find!(api: api) { |e| e[:foo] == 'foo' }[:id]).to eq(1)
        end
      end

      describe '#find_by' do
        let(:obj0) { Obj.new(0, 'foo0', 'bar0') }
        let(:obj1) { Obj.new(1, 'foo1', 'bar1') }
        let(:obj2) { Obj.new(2, 'foo2', 'bar2') }
        let(:objs) { [obj0, obj1, obj2] }

        before(:each) { allow(dbl).to receive(:_all).with(api: api).and_return(objs) }

        it 'returns correct value' do
          expect(dbl.find_by(:id, 1, api: api)).to eq(obj1)
        end

        it 'returns nil if object not found' do
          expect(dbl.find_by(:id, 4, api: api)).to be_nil
        end

        it 'returns cached value' do
          dbl.find_by(:id, 1, api: api) # should cache value
          new_objs = [Obj.new(4, 'foo4', 'bar4'),
                      Obj.new(5, 'foo5', 'bar5'),
                      Obj.new(6, 'foo6', 'bar6')]
          allow(dbl).to receive(:_all).with(api: api).and_return(new_objs)
          expect(dbl.find_by(:id, 1, api: api)).to eq(obj1)
        end
      end

      describe '#find_by!' do
        let(:obj0) { Obj.new(0, 'foo0', 'bar0') }
        let(:obj1) { Obj.new(1, 'foo1', 'bar1') }
        let(:obj2) { Obj.new(2, 'foo2', 'bar2') }
        let(:objs) { [obj0, obj1, obj2] }

        before(:each) { allow(dbl).to receive(:_all).with(api: api).and_return(objs) }

        it 'returns correct value' do
          expect(dbl.find_by!(:id, 1, api: api)).to eq(obj1)
        end

        it 'returns nil if object not found' do
          expect(dbl.find_by!(:id, 4, api: api)).to be_nil
        end

        it 'returns cached value' do
          dbl.find_by!(:id, 1, api: api) # should cache value
          new_objs = [Obj.new(4, 'foo4', 'bar4'),
                      Obj.new(5, 'foo5', 'bar5'),
                      Obj.new(6, 'foo6', 'bar6')]
          allow(dbl).to receive(:_all).with(api: api).and_return(new_objs)
          expect(dbl.find_by!(:id, 5, api: api)).to eq(new_objs[1])
        end
      end

      describe '#retrieve' do
        let(:obj0) { Obj.new(0, 'foo0', 'bar0') }
        let(:obj1) { Obj.new(1, 'foo1', 'bar1') }
        let(:obj2) { Obj.new(2, 'foo2', 'bar2') }
        let(:objs) { [obj0, obj1, obj2] }

        before(:each) do
          allow(dbl).to receive(:_all).with(api: api).and_return(objs)
          allow(dbl).to receive(:searchable_attributes).and_return(%i[id foo bar])
        end

        it 'retrieves correct object by id attribute' do
          expect(dbl.retrieve(0, api: api)).to eq(obj0)
        end

        it 'retrieves correct object by foo attribute' do
          expect(dbl.retrieve('foo1', api: api)).to eq(obj1)
        end

        it 'retrieves correct object by foo attribute' do
          expect(dbl.retrieve('bar2', api: api)).to eq(obj2)
        end

        it 'raises ArgumentError if it cannot find object' do
          expect { dbl.retrieve('fake') }.to raise_error ArgumentError
        end
      end
    end
  end
end
