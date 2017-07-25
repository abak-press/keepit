require "spec_helper"

RSpec.describe Keepit::Guard do
  subject(:guard) do
    Class.new(described_class) do
      config.resource = "barmen".freeze
    end
  end

  let(:success_wrap) { guard.wrap { "ok" } }
  let(:fail_wrap) { guard.wrap { raise StandardError } }
  let(:fatal_wrap) { guard.wrap { raise Exception } }
  let(:notificator) { spy(:notificator) }

  before do
    guard.reset
    ::Keepit::TransientStore.clear
    guard.config.error_notificator = notificator
  end

  context "when resource alive" do
    it "returns a result" do
      expect(success_wrap).to eq "ok"
    end
  end

  context "when resource did not answer" do
    it "returns nil" do
      expect(fail_wrap).to be nil
    end

    it "reports a error" do
      expect(notificator).to receive(:call)
      fail_wrap
    end

    context "and number of errors exceeded the critical threshold" do
      it "stops report a error" do
        11.times { fail_wrap }

        expect(notificator).to_not receive(:call)
        fail_wrap
      end
    end
  end

  context "when resource raise unknown exception" do
    it "fails with that exception" do
      expect { fatal_wrap }.to raise_error(Exception)
    end
  end

  context "when resource on maintenance" do
    it "returns nil" do
      Keepit::Locker.lock("barmen")
      expect(success_wrap).to be nil
      Keepit::Locker.unlock("barmen")
    end
  end
end
