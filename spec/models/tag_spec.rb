require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should validate_length_of(:title).is_at_most(50) }
  end

  describe 'assoications' do
    it { should have_and_belong_to_many(:tasks) }
  end
end
