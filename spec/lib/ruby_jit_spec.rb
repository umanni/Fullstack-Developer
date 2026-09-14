require "rails_helper"

RSpec.describe RubyJit do
  let(:zjit_env) { { "RUBY_JIT" => "zjit" } }
  let(:logger) { instance_double(Logger, warn: nil) }

  describe ".mode" do
    it "is nil when RUBY_JIT is unset or blank" do
      expect(described_class.mode({})).to be_nil
      expect(described_class.mode("RUBY_JIT" => " ")).to be_nil
    end

    it "accepts yjit, zjit and off in any case" do
      expect(described_class.mode("RUBY_JIT" => "ZJIT")).to eq("zjit")
      expect(described_class.mode("RUBY_JIT" => " off ")).to eq("off")
    end

    it "rejects any other value" do
      expect { described_class.mode("RUBY_JIT" => "mjit") }.to raise_error(ArgumentError, /yjit, zjit, off/)
    end
  end

  describe ".configure" do
    let(:config) { ActiveSupport::OrderedOptions.new.merge!(yjit: :rails_default) }

    it "keeps Rails' default when RUBY_JIT is unset" do
      described_class.configure(config, {})

      expect(config.yjit).to eq(:rails_default)
    end

    it "turns YJIT on for yjit" do
      described_class.configure(config, "RUBY_JIT" => "yjit")

      expect(config.yjit).to be(true)
    end

    it "turns YJIT off for zjit and off, since a process runs only one JIT" do
      described_class.configure(config, zjit_env)
      expect(config.yjit).to be(false)

      config.yjit = true
      described_class.configure(config, "RUBY_JIT" => "off")
      expect(config.yjit).to be(false)
    end
  end

  describe ".enable_zjit" do
    it "does nothing unless RUBY_JIT is zjit" do
      expect(described_class.enable_zjit(logger:, env: {})).to be(false)
      expect(logger).not_to have_received(:warn)
    end

    context "without ZJIT in this Ruby" do
      before { hide_const("RubyVM::ZJIT") }

      it "warns and keeps running without a JIT" do
        expect(described_class.enable_zjit(logger:, env: zjit_env)).to be(false)
        expect(logger).to have_received(:warn).with(/built without ZJIT/)
      end
    end

    context "with ZJIT in this Ruby" do
      # String references throughout: RubyVM::ZJIT and RubyVM::YJIT only exist in a Ruby built with rustc.
      let(:zjit) { class_double("RubyVM::ZJIT", enabled?: false, enable: true).as_stubbed_const } # rubocop:disable RSpec/VerifiedDoubleReference

      it "enables it" do
        zjit

        expect(described_class.enable_zjit(logger:, env: zjit_env)).to be(true)
        expect(zjit).to have_received(:enable)
      end

      it "leaves it alone when it is already running" do
        allow(zjit).to receive(:enabled?).and_return(true)

        expect(described_class.enable_zjit(logger:, env: zjit_env)).to be(true)
        expect(zjit).not_to have_received(:enable)
      end

      it "warns when another JIT already holds the process" do
        allow(zjit).to receive(:enable).and_return(false)

        expect(described_class.enable_zjit(logger:, env: zjit_env)).to be(false)
        expect(logger).to have_received(:warn).with(/another JIT/)
      end
    end
  end

  describe ".active" do
    it "names ZJIT when it is running" do
      class_double("RubyVM::ZJIT", enabled?: true).as_stubbed_const # rubocop:disable RSpec/VerifiedDoubleReference

      expect(described_class.active).to eq("zjit")
    end

    it "names YJIT when it is running" do
      hide_const("RubyVM::ZJIT")
      class_double("RubyVM::YJIT", enabled?: true).as_stubbed_const # rubocop:disable RSpec/VerifiedDoubleReference

      expect(described_class.active).to eq("yjit")
    end

    it "is off under the interpreter" do
      hide_const("RubyVM::ZJIT")
      hide_const("RubyVM::YJIT")

      expect(described_class.active).to eq("off")
    end
  end
end
