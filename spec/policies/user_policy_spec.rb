require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin)  { create(:user, :admin) }
  let(:member) { create(:user) }
  let(:other)  { create(:user) }

  def policy_for(actor, record) = described_class.new(actor, record)

  describe "an admin acting on someone else" do
    subject(:policy) { policy_for(admin, member) }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.new?).to be(true) }
    it { expect(policy.edit?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
    it { expect(policy.toggle_role?).to be(true) }
  end

  describe "an admin acting on themselves" do
    subject(:policy) { policy_for(admin, admin) }

    it { expect(policy.index?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.update?).to be(true) }

    it "cannot change their own role, which is the guard against self-demotion" do
      expect(policy.toggle_role?).to be(false)
    end

    # NOTE: the comment above `toggle_role?` says an admin must not be able to
    # "demote or delete themselves out of access", but `destroy?` is
    # `user.admin? || owner?` and so is true here. This example pins the
    # behaviour as it actually is; see also the model-level last-admin guard,
    # which only stops the *final* admin from being removed.
    it "can currently still destroy their own account" do
      expect(policy.destroy?).to be(true)
    end
  end

  describe "a member acting on themselves" do
    subject(:policy) { policy_for(member, member) }

    it { expect(policy.index?).to be(false) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.new?).to be(false) }
    it { expect(policy.toggle_role?).to be(false) }

    it "can view, edit and delete their own account" do
      expect(policy.show?).to be(true)
      expect(policy.update?).to be(true)
      expect(policy.destroy?).to be(true)
      expect(policy.edit?).to be(true)
    end
  end

  describe "a member acting on another user" do
    subject(:policy) { policy_for(member, other) }

    it "is denied every action" do
      actions = %i[index? show? create? update? destroy? new? edit? toggle_role?]

      expect(actions.select { |action| policy.public_send(action) }).to be_empty
    end
  end

  describe "#permitted_attributes" do
    it "lets an admin assign role on top of the base attributes" do
      expect(policy_for(admin, member).permitted_attributes).to eq(described_class::ADMIN_ATTRIBUTES)
      expect(policy_for(admin, member).permitted_attributes).to include(:role)
    end

    it "withholds role from an admin editing themselves, matching toggle_role?" do
      attributes = policy_for(admin, admin).permitted_attributes

      expect(attributes).to eq(described_class::BASE_ATTRIBUTES)
      expect(attributes).not_to include(:role)
      expect(policy_for(admin, admin).toggle_role?).to be(false)
    end

    it "grants role to an admin creating a user, who cannot be its owner" do
      expect(policy_for(admin, User.new).permitted_attributes).to include(:role)
    end

    it "withholds role from a member editing themselves" do
      attributes = policy_for(member, member).permitted_attributes

      expect(attributes).to eq(described_class::BASE_ATTRIBUTES)
      expect(attributes).not_to include(:role)
    end

    it "covers the writable profile fields" do
      expect(described_class::BASE_ATTRIBUTES).to contain_exactly(
        :full_name, :email_address, :password, :password_confirmation,
        :avatar_url, :avatar_image
      )
    end

    it "exposes frozen constants so callers cannot mutate them" do
      expect(described_class::BASE_ATTRIBUTES).to be_frozen
      expect(described_class::ADMIN_ATTRIBUTES).to be_frozen
    end
  end

  describe "#scope" do
    before do
      admin
      member
      other
    end

    it "returns every user for an admin" do
      expect(policy_for(admin, admin).scope).to match_array(User.all)
    end

    it "returns only themselves for a member" do
      expect(policy_for(member, member).scope).to contain_exactly(member)
    end

    it "still returns only the actor when a member targets someone else" do
      expect(policy_for(member, other).scope).to contain_exactly(member)
    end
  end

  # The policy calls `user.admin?` unguarded, so it assumes an authenticated
  # actor. These examples document that a guest reaches a NoMethodError rather
  # than a denial -- relevant because PasswordsController and
  # SessionsController#new/#create allow unauthenticated access.
  describe "with no authenticated user" do
    it "raises instead of denying" do
      expect { policy_for(nil, member).show? }.to raise_error(NoMethodError, /admin\?/)
      expect { policy_for(nil, member).permitted_attributes }.to raise_error(NoMethodError, /admin\?/)
      expect { policy_for(nil, member).scope }.to raise_error(NoMethodError, /admin\?/)
    end
  end
end
