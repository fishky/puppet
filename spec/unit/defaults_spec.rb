require 'spec_helper'
require 'puppet/settings'

describe "Defaults" do
  describe ".default_diffargs" do
    describe "on AIX" do
      before(:each) do
        Facter.stubs(:value).with(:kernel).returns("AIX")
      end
      describe "on 5.3" do
        before(:each) do
          Facter.stubs(:value).with(:kernelmajversion).returns("5300")
        end
        it "should be empty" do
          expect(Puppet.default_diffargs).to eq("")
        end
      end
      [ "",
        nil,
        "6300",
        "7300",
      ].each do |kernel_version|
        describe "on kernel version #{kernel_version.inspect}" do
          before(:each) do
            Facter.stubs(:value).with(:kernelmajversion).returns(kernel_version)
          end

          it "should be '-u'" do
            expect(Puppet.default_diffargs).to eq("-u")
          end
        end
      end
    end
    describe "on everything else" do
      before(:each) do
        Facter.stubs(:value).with(:kernel).returns("NOT_AIX")
      end

      it "should be '-u'" do
        expect(Puppet.default_diffargs).to eq("-u")
      end
    end
  end

  describe 'cfacter' do

    before :each do
      Facter.reset
    end

    it 'should default to false' do
      expect(Puppet.settings[:cfacter]).to be_falsey
    end

    it 'should raise an error if cfacter is not installed' do
      Puppet.features.stubs(:cfacter?).returns false
      expect { Puppet.settings[:cfacter] = true }.to raise_exception ArgumentError, 'cfacter version 0.2.0 or later is not installed.'
    end

    it 'should raise an error if facter has already evaluated facts' do
      Facter[:facterversion]
      Puppet.features.stubs(:cfacter?).returns true
      expect { Puppet.settings[:cfacter] = true }.to raise_exception ArgumentError, 'facter has already evaluated facts.'
    end

    it 'should initialize cfacter when set to true' do
      Puppet.features.stubs(:cfacter?).returns true
      CFacter = mock
      CFacter.stubs(:initialize)
      Puppet.settings[:cfacter] = true
    end

  end
end
