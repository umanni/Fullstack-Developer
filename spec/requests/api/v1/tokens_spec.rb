require "swagger_helper"

RSpec.describe "Api::V1::Tokens" do
  let(:password) { "a-sufficiently-long-password" }

  path "/api/v1/tokens" do
    post "Exchanges credentials for a bearer token" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      security []

      parameter name: :credentials, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email_address: { type: :string, format: :email, example: "ada@example.com" },
          password: { type: :string, format: :password }
        },
        required: %w[email_address password]
      }

      response "201", "a token, valid for 24 hours" do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 expires_at: { type: :string, format: :"date-time" },
                 user: { "$ref" => "#/components/schemas/user" }
               },
               required: %w[token expires_at user]

        let!(:user) { create(:user, email_address: "ada@example.com", password: password) }
        let(:credentials) { { email_address: "ada@example.com", password: password } }

        run_test! do |response|
          token = JSON.parse(response.body).fetch("token")
          expect(User.find_by_token_for(:api, token)).to eq(user)
        end
      end

      response "401", "the address and the password do not match" do
        schema "$ref" => "#/components/schemas/error"

        let!(:user) { create(:user, email_address: "ada@example.com", password: password) }
        let(:credentials) { { email_address: "ada@example.com", password: "not the password" } }

        run_test!
      end

      response "401", "no such account" do
        let(:credentials) { { email_address: "nobody@example.com", password: password } }

        run_test!
      end
    end
  end

  path "/api/v1/me" do
    get "Returns the account the token belongs to" do
      tags "Authentication"
      produces "application/json"
      security [bearer_auth: []]

      response "200", "the signed in account" do
        schema "$ref" => "#/components/schemas/user"

        let(:user) { create(:user, full_name: "Ada Lovelace") }
        let(:Authorization) { "Bearer #{user.generate_token_for(:api)}" }

        run_test! do |response|
          expect(JSON.parse(response.body)["full_name"]).to eq("Ada Lovelace")
        end
      end

      response "401", "no token, or a token that has expired" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { "Bearer not-a-real-token" }

        run_test!
      end
    end
  end
end
