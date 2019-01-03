require 'rails_helper'

RSpec.describe ReviewableHistory, type: :model do

  let(:user) { Fabricate(:user) }
  let(:admin) { Fabricate(:admin) }
  let(:moderator) { Fabricate(:moderator) }

  it "adds a `created` history event when a reviewable is created" do
    reviewable = ReviewableUser.needs_review!(target: user, created_by: admin)
    reviewable.perform(moderator, :approve)
    reviewable = ReviewableUser.needs_review!(target: user, created_by: admin)

    history = reviewable.history
    expect(history.size).to eq(3)

    expect(history[0].reviewable_history_type).to eq(ReviewableHistory.types[:created])
    expect(history[0].status).to eq(Reviewable.statuses[:pending])
    expect(history[0].created_by).to eq(admin)

    expect(history[1].reviewable_history_type).to eq(ReviewableHistory.types[:transitioned])
    expect(history[1].status).to eq(Reviewable.statuses[:approved])
    expect(history[1].created_by).to eq(moderator)

    expect(history[2].reviewable_history_type).to eq(ReviewableHistory.types[:transitioned])
    expect(history[2].status).to eq(Reviewable.statuses[:pending])
    expect(history[2].created_by).to eq(admin)
  end

end
