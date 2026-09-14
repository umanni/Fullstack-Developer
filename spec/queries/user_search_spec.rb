require "rails_helper"

RSpec.describe UserSearch do
  def search(scope = User.all, **params) = described_class.new(scope, params)

  describe "defaults" do
    it "falls back to the newest-first ordering with no filters" do
      expect(search.to_props).to include(
        query: "", sort: "created_at", direction: "desc", role: nil, page: 1
      )
    end

    it "orders by created_at desc when no sort is given" do
      older = create(:user, created_at: 2.days.ago)
      newer = create(:user, created_at: 1.day.ago)

      expect(search.records).to eq([ newer, older ])
    end
  end

  describe "sorting" do
    before do
      create(:user, full_name: "Grace Hopper", created_at: 3.days.ago)
      create(:user, full_name: "Ada Lovelace", created_at: 2.days.ago)
      create(:user, full_name: "Barbara Liskov", created_at: 1.day.ago)
    end

    it "sorts by an allowlisted column ascending" do
      expect(search(sort: "full_name", direction: "asc").records.pluck(:full_name))
        .to eq([ "Ada Lovelace", "Barbara Liskov", "Grace Hopper" ])
    end

    it "sorts by an allowlisted column descending" do
      expect(search(sort: "full_name", direction: "desc").records.pluck(:full_name))
        .to eq([ "Grace Hopper", "Barbara Liskov", "Ada Lovelace" ])
    end

    it "sorts by created_at ascending" do
      expect(search(sort: "created_at", direction: "asc").records.pluck(:full_name))
        .to eq([ "Grace Hopper", "Ada Lovelace", "Barbara Liskov" ])
    end

    it "accepts symbols as well as strings" do
      expect(search(sort: :full_name, direction: :asc).to_props)
        .to include(sort: "full_name", direction: "asc")
    end

    it "ignores a column outside the allowlist" do
      expect(search(sort: "password_digest").to_props).to include(sort: "created_at")
    end

    it "ignores an unknown direction" do
      expect(search(direction: "sideways").to_props).to include(direction: "desc")
    end

    it "refuses a SQL injection payload in sort rather than interpolating it" do
      finder = search(sort: "created_at; DROP TABLE users --")

      expect(finder.to_props).to include(sort: "created_at")
      expect { finder.records.load }.not_to raise_error
      expect(User.count).to eq(3)
    end

    it "refuses a SQL injection payload in direction" do
      finder = search(sort: "full_name", direction: "asc, (SELECT 1)")

      expect(finder.to_props).to include(direction: "desc")
      expect { finder.records.load }.not_to raise_error
    end

    it "sorts by role" do
      roles = search(sort: "role", direction: "asc").records.pluck(:role)

      expect(roles).to eq(roles.sort)
    end
  end

  describe "role filtering" do
    let!(:admin)  { create(:user, :admin, full_name: "Ada Lovelace") }
    let!(:member) { create(:user, full_name: "Grace Hopper") }

    it "keeps only admins" do
      expect(search(role: "admin").records).to eq([ admin ])
    end

    it "keeps only members" do
      expect(search(role: "member").records).to eq([ member ])
    end

    it "accepts a symbol role" do
      expect(search(role: :admin).records).to eq([ admin ])
    end

    it "ignores a role that is not part of the enum" do
      finder = search(role: "superuser")

      expect(finder.to_props).to include(role: nil)
      expect(finder.records).to contain_exactly(admin, member)
    end

    it "ignores a case-mismatched role rather than guessing" do
      expect(search(role: "ADMIN").to_props).to include(role: nil)
    end

    it "ignores a blank role" do
      expect(search(role: "").to_props).to include(role: nil)
    end
  end

  describe "name query" do
    let!(:ada)   { create(:user, full_name: "Ada Lovelace") }
    let!(:grace) { create(:user, full_name: "Grace Hopper") }

    it "matches a substring case-insensitively" do
      expect(search(query: "lovel").records).to eq([ ada ])
    end

    it "matches regardless of the casing of the stored name" do
      expect(search(query: "GRACE").records).to eq([ grace ])
    end

    it "strips surrounding whitespace before matching" do
      finder = search(query: "  Ada  ")

      expect(finder.records).to eq([ ada ])
      expect(finder.to_props).to include(query: "Ada")
    end

    it "treats a whitespace-only query as no query at all" do
      expect(search(query: "   ").records).to contain_exactly(ada, grace)
    end

    it "returns nothing when nothing matches" do
      expect(search(query: "Margaret").records).to be_empty
    end

    it "escapes % so it is matched literally instead of matching everyone" do
      percent = create(:user, full_name: "100% Cotton")

      expect(search(query: "100%").records).to eq([ percent ])
    end

    it "escapes _ so it is matched literally instead of matching any character" do
      underscore = create(:user, full_name: "snake_case")
      create(:user, full_name: "snakeXcase")

      expect(search(query: "snake_case").records).to eq([ underscore ])
    end

    it "combines the query with the role filter" do
      create(:user, :admin, full_name: "Ada Byron")

      expect(search(query: "Ada", role: "member").records).to eq([ ada ])
    end
  end

  describe "the scope it is given" do
    it "never reaches outside it" do
      create(:user, full_name: "Ada Lovelace")
      grace = create(:user, full_name: "Grace Hopper")

      expect(search(User.where(full_name: "Grace Hopper")).records).to eq([ grace ])
    end

    it "counts within it" do
      create_list(:user, 2)

      expect(search(User.none).total).to eq(0)
    end
  end

  describe "pagination" do
    before { stub_const("#{described_class}::PER_PAGE", 2) }

    let!(:users) do
      3.times.map { |i| create(:user, full_name: "User #{i}", created_at: i.days.ago) }
    end

    it "returns at most one page of records" do
      expect(search(sort: "full_name", direction: "asc").records.size).to eq(2)
    end

    it "offsets to the requested page" do
      expect(search(sort: "full_name", direction: "asc", page: 2).records.pluck(:full_name))
        .to eq([ "User 2" ])
    end

    it "returns nothing past the last page" do
      expect(search(page: 99).records).to be_empty
    end

    it "counts every match, not just the current page" do
      expect(search.total).to eq(3)
    end

    it "rounds total_pages up for a partial last page" do
      expect(search.total_pages).to eq(2)
    end

    it "does not add an empty page when the total divides evenly" do
      users.last.destroy

      expect(search.total_pages).to eq(1)
    end

    it "reports one page when there are no matches" do
      finder = search(query: "nobody")

      expect(finder.total).to eq(0)
      expect(finder.total_pages).to eq(1)
    end

    describe "the page parameter" do
      it "defaults to 1" do
        expect(search.page).to eq(1)
      end

      it "clamps zero to 1" do
        expect(search(page: 0).page).to eq(1)
      end

      it "clamps a negative page to 1, so the offset can never go negative" do
        finder = search(page: -5)

        expect(finder.page).to eq(1)
        expect { finder.records.load }.not_to raise_error
      end

      it "coerces a numeric string" do
        expect(search(page: "2").page).to eq(2)
      end

      it "treats a non-numeric page as 1" do
        expect(search(page: "abc").page).to eq(1)
      end
    end
  end

  describe "memoization" do
    it "runs the count query once" do
      create(:user)
      finder = search

      expect(finder.total).to eq(1)

      create(:user)

      expect(finder.total).to eq(1)
    end

    it "returns the same relation object for repeated calls" do
      finder = search

      expect(finder.records).to equal(finder.records)
    end
  end

  describe "#to_props" do
    it "exposes everything the front end needs to render the current state" do
      create_list(:user, 2, :admin, full_name: "Ada Lovelace")

      props = search(query: " Ada ", sort: "full_name", direction: "asc",
                     role: "admin", page: "1").to_props

      expect(props).to eq(
        query: "Ada", sort: "full_name", direction: "asc", role: "admin",
        page: 1, total_pages: 1, total: 2
      )
    end

    it "works with ActionController::Parameters" do
      params = ActionController::Parameters.new(
        query: "Ada", sort: "full_name", direction: "asc", role: "admin", page: "2"
      )

      expect(described_class.new(User.all, params).to_props).to include(
        query: "Ada", sort: "full_name", direction: "asc", role: "admin", page: 2
      )
    end
  end
end
