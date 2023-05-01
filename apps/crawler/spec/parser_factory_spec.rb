require 'spec_helper'
require 'parser_factory'

RSpec.describe ParserFactory do
  describe '.new_for' do
    it 'returns an array of parsers' do
      expect(ParserFactory.new_for('Warszawa', []).first).to be_a(Olx)
    end
  end
end
