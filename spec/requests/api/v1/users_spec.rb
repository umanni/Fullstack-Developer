require "swagger_helper"

RSpec.describe "Api::V1::Users" do
  let(:administrator) { create(:user, :admin, full_name: "Ada Lovelace") }
  let(:Authorization) { "Bearer #{administrator.generate_token_for(:api)}" }

  path "/api/v1/users" do
    get "Lists the people in the system" do
      tags "Users"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :query, in: :query, required: false, schema: { type: :string },
                description: "Matches a name or an email address"
      parameter name: :role, in: :query, required: false,
                schema: { type: :string, enum: %w[user admin] }
      parameter name: :page, in: :query, required: false, schema: { type: :integer }
      parameter name: :per_page, in: :query, required: false,
                schema: { type: :integer, maximum: 100 },
                description: "Bounded, so a hand-edited URL cannot ask for the whole table"

      response "200", "a page of people" do
        schema type: :object,
               properties: {
                 users: { type: :array, items: { "$ref" => "#/components/schemas/user" } },
                 pagination: { "$ref" => "#/components/schemas/pagination" }
               },
               required: %w[users pagination]

        let(:query) { "maria" }
        let(:role) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        before do
          create(:user, full_name: "Maria Silva")
          create(:user, full_name: "Joao Souza")
        end

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["users"].pluck("full_name")).to eq(["Maria Silva"])
          expect(body["pagination"]["count"]).to eq(1)
        end
      end

      response "403", "the token belongs to somebody who is not an administrator" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { "Bearer #{create(:user).generate_token_for(:api)}" }

        run_test!
      end

      response "401", "no token" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }

        run_test!
      end
    end

    post "Creates an account" do
      tags "Users"
      consumes "application/json"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              full_name: { type: :string, example: "Maria Silva" },
              email_address: { type: :string, format: :email, example: "maria@example.com" },
              password: { type: :string, format: :password, minLength: 8 },
              role: { type: :string, enum: %w[user admin] },
              locale: { type: :string, enum: User::SUPPORTED_LOCALES },
              avatar_url: { type: :string, nullable: true }
            },
            required: %w[full_name email_address password]
          }
        },
        required: %w[user]
      }

      response "201", "the account that was created" do
        schema "$ref" => "#/components/schemas/user"

        let(:body) do
          { user: { full_name: "Maria Silva", email_address: "maria@example.com",
                    password: "a-sufficiently-long-password" } }
        end

        run_test! do
          expect(User.find_by(email_address: "maria@example.com")).to be_user
          expect(AuditEvent.last).to have_attributes(action: "created", actor: administrator)
        end
      end

      response "422", "the account was refused" do
        schema "$ref" => "#/components/schemas/error"

        let(:body) { { user: { full_name: "", email_address: "not an address", password: "short" } } }

        run_test! do |response|
          expect(JSON.parse(response.body)["details"]).to include("email_address")
        end
      end
    end
  end

  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get "Returns one person" do
      tags "Users"
      produces "application/json"
      security [bearer_auth: []]

      response "200", "the person" do
        schema "$ref" => "#/components/schemas/user"

        let(:id) { create(:user, full_name: "Maria Silva").id }

        run_test! do |response|
          expect(JSON.parse(response.body)["full_name"]).to eq("Maria Silva")
        end
      end

      response "404", "nobody with that id" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { 0 }

        run_test!
      end
    end

    patch "Updates a person" do
      tags "Users"
      consumes "application/json"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              full_name: { type: :string },
              email_address: { type: :string, format: :email },
              password: { type: :string, format: :password, minLength: 8 },
              role: { type: :string, enum: %w[user admin] },
              locale: { type: :string, enum: User::SUPPORTED_LOCALES },
              avatar_url: { type: :string, nullable: true }
            }
          }
        },
        required: %w[user]
      }

      response "200", "the person as they now are" do
        schema "$ref" => "#/components/schemas/user"

        let(:id) { create(:user).id }
        let(:body) { { user: { role: "admin" } } }

        run_test! do
          expect(User.find(id)).to be_admin
          expect(AuditEvent.last.action).to eq("promoted")
        end
      end

      response "422", "the change was refused -- here, the last administrator" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { administrator.id }
        let(:body) { { user: { role: "user" } } }

        run_test! do
          expect(administrator.reload).to be_admin
        end
      end
    end

    delete "Removes a person" do
      tags "Users"
      produces "application/json"
      security [bearer_auth: []]

      response "204", "removed" do
        let(:id) { create(:user).id }

        run_test! do
          expect(User.exists?(id)).to be(false)
          expect(AuditEvent.last.action).to eq("deleted")
        end
      end

      response "422", "the only administrator left may not be removed" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { administrator.id }

        run_test! do
          expect(administrator.reload).to be_persisted
        end
      end
    end
  end
end
