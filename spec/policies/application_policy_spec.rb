require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:record) { Object.new }

  describe "default permissions" do
    let(:policy) { described_class.new(nil, record) }

    it "denies index" do
      expect(policy.index?).to be(false)
    end

    it "denies show" do
      expect(policy.show?).to be(false)
    end

    it "denies create" do
      expect(policy.create?).to be(false)
    end

    it "denies update" do
      expect(policy.update?).to be(false)
    end

    it "denies destroy" do
      expect(policy.destroy?).to be(false)
    end
  end

  describe "scope" do
    it "requires subclasses to implement resolve" do
      scope = described_class::Scope.new(nil, Borrowing.all)

      expect { scope.resolve }.to raise_error(NoMethodError, /You must define #resolve/)
    end
  end

  describe "role helpers" do
    let!(:librarian) do
      User.create!(email: "policy_librarian@example.com", password: "password123", password_confirmation: "password123", role: "librarian")
    end
    let!(:member) do
      User.create!(email: "policy_member@example.com", password: "password123", password_confirmation: "password123", role: "member")
    end

    it "treats present users as authenticated" do
      policy = described_class.new(member, record)

      expect(policy.send(:authenticated?)).to be(true)
    end

    it "identifies librarian role" do
      policy = described_class.new(librarian, record)

      expect(policy.send(:librarian?)).to be(true)
      expect(policy.send(:member?)).to be(false)
    end

    it "identifies member role" do
      policy = described_class.new(member, record)

      expect(policy.send(:librarian?)).to be(false)
      expect(policy.send(:member?)).to be(true)
    end
  end
end
