require "spec_helper"

RSpec.describe Keepit::TransientStore do
  let(:s) { described_class }

  before { described_class.clear }
  after { described_class.clear }

  describe '#delete' do
    context 'when key exists' do
      it 'deletes the key and returns value' do
        s.write(:key, 1, expires_in: 10)

        expect(s.delete(:key)).to eq 1
        expect(s).to be_empty
      end
    end

    context 'when key does not exist' do
      it { expect(s.delete(:key)).to be_nil }
    end
  end

  describe '#empty?' do
    context 'when storage is empty' do
      it { expect(s).to be_empty }
    end

    context 'when storage is not empty' do
      before { s.write(:key, 1, expires_in: 10) }

      it { expect(s).to_not be_empty }
    end
  end

  describe '#exist?' do
    context 'when storage contains expired key' do
      before do
        Timecop.freeze(Date.today - 10) do
          s.write(:key, 1, expires_in: 10)
        end
      end

      it 'returns false and deletes expired key' do
        expect(s.exist?(:key)).to be_falsey
        expect(s).to be_empty
      end
    end

    context 'when storage contains the key' do
      before { s.write(:key, 1, expires_in: 10) }

      it { expect(s.exist?(:key)).to be_truthy }
    end

    context 'when storage does not contain the key' do
      it { expect(s.exist?(:key)).to be_falsey }
    end
  end

  describe '#fetch' do
    context 'when storage contains expired key' do
      before do
        Timecop.freeze(Date.today - 10) do
          s.write(:key, 1, expires_in: 10)
        end
      end

      it "call the block and save it's return value" do
        expect(s.fetch(:key, expires_in: 60) { 55 }).to eq 55
        expect(s.fetch(:key, expires_in: 60) { 66 }).to eq 55
      end
    end

    context 'when storage contains key' do
      before do
        s.write(:key, 1, expires_in: 60)
      end

      it 'return cached value' do
        expect(s.fetch(:key, expires_in: 60) { 55 }).to eq 1
      end
    end
  end

  describe '#read' do
    context 'when storage contains expired key' do
      before do
        Timecop.freeze(Date.today - 10) do
          s.write(:key, 1, expires_in: 10)
        end
      end

      it 'returns nil and deletes expired key' do
        expect(s.read(:key)).to be_nil
        expect(s).to be_empty
      end
    end

    context 'when storage contains the key' do
      before { s.write(:key, 1, expires_in: 10) }

      it { expect(s.read(:key)).to eq 1 }
    end

    context 'when storage does not contain the key' do
      it { expect(s.read(:key)).to be_nil }
    end
  end

  describe '#write' do
    it 'saves value' do
      expect(s.exist?(:key)).to be_falsey
      s.write(:key, 1, expires_in: 10)
      expect(s.exist?(:key)).to be_truthy
    end
  end
end
