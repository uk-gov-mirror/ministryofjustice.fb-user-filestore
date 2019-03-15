require 'rails_helper'

RSpec.describe MimeChecker do
  context 'when passed type is allowed' do
    subject { described_class.new('text/html', ['text/plain', 'text/html']) }

    it 'returns true' do
      expect(subject.call).to be_truthy
    end
  end

  context 'when passed type is not allowed' do
    subject { described_class.new('text/html', ['text/plain', 'image/png']) }

    it 'returns false' do
      expect(subject.call).to be_falsey
    end
  end

  context 'when passed type is allowed by wildcard' do
    subject { described_class.new('text/html', ['text/*', 'image/png']) }

    it 'returns true' do
      expect(subject.call).to be_truthy
    end
  end

  context 'when passed type is not allowed by wildcard' do
    subject { described_class.new('image/jpeg', ['text/*', 'image/png']) }

    it 'returns false' do
      expect(subject.call).to be_falsey
    end
  end

  context 'when passed type is allowed by global wildcard' do
    subject { described_class.new('image/jpeg', ['*/*', 'image/png']) }

    it 'returns true' do
      expect(subject.call).to be_truthy
    end
  end

  context 'when whitelist is empty' do
    subject { described_class.new('image/jpeg', []) }

    it 'returns false' do
      expect(subject.call).to be_falsey
    end
  end

  context 'when type is not valid type' do
    subject { described_class.new('foo', ['application/pdf']) }

    it 'returns false' do
      expect(subject.call).to be_falsey
    end
  end

  context 'when type blank' do
    subject { described_class.new('', ['application/pdf']) }

    it 'returns false' do
      expect(subject.call).to be_falsey
    end
  end
end
