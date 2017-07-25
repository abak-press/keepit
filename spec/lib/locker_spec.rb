require "spec_helper"

RSpec.describe Keepit::Locker do
  describe '#locked?' do
    it 'locks appropriate resources' do
      described_class.lock(%w(products rubrics global))
      Keepit::TransientStore.clear

      expect(described_class.locked?('companies')).to be_truthy
      expect(described_class.locked?('companies', check_global: false)).to be_falsey

      described_class.unlock(%w(global))
      Keepit::TransientStore.clear

      expect(described_class.locked?('products')).to be_truthy
      expect(described_class.locked?('rubrics')).to be_truthy
      expect(described_class.locked?('companies')).to be_falsey
      expect(described_class.locked?('global')).to be_falsey

      described_class.unlock(%w(products rubrics))
      Keepit::TransientStore.clear

      expect(described_class.locked?('products')).to be_falsey
      expect(described_class.locked?('rubrics')).to be_falsey
    end
  end
end
