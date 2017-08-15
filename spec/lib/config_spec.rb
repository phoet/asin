require 'spec_helper'

module ASIN
  describe ASIN do
    context "configuration" do
      it "should fail without secret and key" do
        ASIN::Configuration.reset!
        expect { @helper.lookup 'bla' }.to raise_error(ArgumentError, "you are missing mandatory configuration options. please set [:secret, :key, :associate_tag]")
      end

      it "should fail with wrong configuration key" do
        expect(lambda { @helper.configure :wrong => 'key' }).to raise_error(ArgumentError)
      end

      it "should not override the configuration" do
        config = @helper.configure :key => 'wont get overridden'
        expect(config.key).to_not be_nil

        config = @helper.configure :secret => 'is also set'
        expect(config.key).to_not be_nil
        expect(config.secret).to_not be_nil
      end

      it "should work with a configuration block" do
        conf = ASIN::Configuration.configure do |config|
          config.key = 'bla'
        end
        expect(conf.key).to eql('bla')
      end

      it "should read configuration from yml" do
        config = ASIN::Configuration.configure :yaml => 'spec/asin.yml'
        expect(config.secret).to eql('secret_yml')
        expect(config.key).to eql('key_yml')
        expect(config.host).to eql('host_yml')
        expect(config.logger).to eql('logger_yml')
      end

      it "should read configuration from yml with block" do
        conf = ASIN::Configuration.configure :yaml => 'spec/asin.yml' do |config, yml|
          config.secret = nil
          config.key = yml['secret']
        end
        expect(conf.secret).to be_nil
        expect(conf.key).to eql('secret_yml')
      end
    end
  end
end
