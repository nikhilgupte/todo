require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:task) { Task.create(title: 'test') }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }

    context 'tags' do
      let(:tag) { Tag.create(title: 'tag') }
      before do
        task.tags << tag
      end
      it 'does not allow duplicate tags' do
        expect { task.tags << tag }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'assoications' do
    it { should have_and_belong_to_many(:tags) }
  end

  describe '.tag_names=' do
    let(:tags) { 4.times.collect { |i| Tag.create(title: "tag #{i}") } }
    let(:new_tag_names) { %w[apple banana orange] }
    subject do
      task.tag_names = new_tag_names
    end
    context 'with existing tags' do
      before { task.tags << tags }
      it 'deletes all existing tags' do
        subject
        expect(task.tags).not_to include(*tags)
      end
    end
    it 'creates and assigns tags' do
      expect { subject }.to change { Tag.count }.by(3)
      expect(task.tags.pluck(:title)).to include(*new_tag_names)
    end
    context 'when some of the tag name already exist' do
      before { Tag.create title: 'apple' }
      it 'associates existing tags' do
        expect { subject }.to change { Tag.count }.by(2)
        expect(task.tags.pluck(:title)).to include(*new_tag_names)
      end
    end
  end
end
