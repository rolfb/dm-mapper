require 'spec_helper'

share_examples_for "DataMapper::Mapper::Attribute#primitive?" do
  subject { attribute.primitive? }

  let(:type)      { stub('type') }
  let(:attribute) { described_class.new(:name, :type => type) }

  it { should be(true) }
end
