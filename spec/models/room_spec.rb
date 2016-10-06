require 'rails_helper'

RSpec.describe Room, type: :model do
  context "basic tests" do
    i18n_scope = 'activerecord.errors.models.room.attributes'
    let(:room) { FactoryGirl.build(:room) }

    it "has a valid factory" do
      expect(room).to be_valid
    end

    it "is invalid without a name" do
      room.name = ""
      expect(room).not_to be_valid
      expect(room.errors[:name]).to include (I18n.t('name.blank', scope: i18n_scope))
    end

    it "rejects duplicate names" do
      room2 = FactoryGirl.build(:room)
      room2.name = room.name.upcase.dup
      room2.save
      room.valid?
      expect(room.errors[:name]).to include(I18n.t('name.duplicated', scope: i18n_scope))
    end

    it "has a positive capacity" do
      room.capacity = 0
      expect(room).not_to be_valid
      expect(room.errors[:capacity]).to include (I18n.t('capacity.zero', scope: i18n_scope))
      room.capacity = -1
      expect(room).not_to be_valid
      expect(room.errors[:capacity]).to include (I18n.t('capacity.negative', scope: i18n_scope))
    end
  end

  context "calculate capacity" do
    let!(:room) { FactoryGirl.create(:room, capacity: 23) }
    let!(:shift) { FactoryGirl.create(:shift, room: room) }
    let!(:shift2) { FactoryGirl.create(:shift, room: room, sites_reserved: 10) }

    it "calculates #total_capacity" do
      expect(room.total_capacity).to eq(46)
    end

    it "calculates #total_sites_available" do
      expect(room.total_sites_available).to eq(36)
    end

    it "calculates #total_occupied" do
      expect(room.total_occupied).to eq(10)
    end
  end
end
