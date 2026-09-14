require "test_helper"

# The brief names SQL injection, XSS and CSRF.
class SecurityTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "escapes markup that was stored in a user's name" do
    users(:member).update!(full_name: "<script>alert('xss')</script>")

    get admin_users_path

    assert_response :success
    assert_no_match "<script>alert", response.body
    assert_match "&lt;script&gt;alert", response.body
  end

  test "escapes markup echoed back into a validation message" do
    post admin_users_path, params: {
      user: { full_name: "<img src=x onerror=alert(1)>", email: "not-an-email",
              password: "secret-password", password_confirmation: "secret-password" }
    }

    assert_response :unprocessable_content
    assert_no_match "<img src=x", response.body
  end

  test "escapes markup carried by an import's row errors" do
    import = users(:admin).spreadsheet_imports.create!(
      file: { io: file_fixture("users.csv").open, filename: "users.csv" }
    )
    import.update!(row_errors: [ { "line" => 2, "message" => "<script>alert('row')</script>" } ])

    get admin_spreadsheet_import_path(import)

    assert_no_match "<script>alert('row')", response.body
  end

  # Unescaped, "%" matches everyone and "_" matches everyone with a name — both turn
  # the search box into a way to page through the whole table.
  test "treats LIKE wildcards in a search term as literal characters" do
    [ "%", "_" ].each do |wildcard|
      get admin_users_path(query: wildcard)

      assert_response :success
      assert_select "td", text: /Ada Lovelace/, count: 0, message: "#{wildcard} reached LIKE unescaped"
    end
  end

  test "does not let a search term reach the query as SQL" do
    get admin_users_path(query: "' OR 1=1 --")

    assert_response :success
    assert_select "td", text: /Ada Lovelace/, count: 0
    assert_predicate User, :any?, "the users table did not survive the term"
  end

  # params.expect guarantees the envelope, not that the fields inside it are filled. A
  # malformed request is a 4xx, never a 500.
  test "answers a half-filled login without raising" do
    post session_path, params: { session: { email: users(:member).email } }

    assert_response :unprocessable_content

    post session_path, params: { session: { password: "secret-password" } }

    assert_response :unprocessable_content
  end

  test "survives a page parameter that is not a number" do
    [ "page[]=1", "page[a]=1", "page=abc", "page=-1", "page=99999999999999999999" ].each do |query|
      get "/admin/users?#{query}"

      assert_response :success, "GET /admin/users?#{query}"
    end
  end

  test "ignores an avatar that is a string instead of an upload" do
    patch profile_path, params: { user: { avatar_image: "https://example.com/a.png" } }

    assert_response :redirect
    assert_not users(:admin).reload.avatar_image.attached?
  end

  test "ignores a spreadsheet that is a string instead of an upload" do
    assert_no_difference -> { SpreadsheetImport.count } do
      post admin_spreadsheet_imports_path, params: { spreadsheet_import: { file: "abc" } }
    end

    assert_response :unprocessable_content
  end

  test "rejects a state-changing request that carries no CSRF token" do
    with_forgery_protection do
      assert_no_difference -> { User.count } do
        post registration_path, params: {
          user: { full_name: "Mallory", email: "mallory@umanni.test",
                  password: "secret-password", password_confirmation: "secret-password" }
        }
      end

      assert_response :unprocessable_content
    end
  end

  test "ignores a session cookie this application did not sign" do
    sign_out
    cookies[:session_id] = users(:admin).sessions.create!.id

    get admin_users_path

    assert_redirected_to new_session_url
  end

  private
    # Rails turns forgery protection off in test.
    def with_forgery_protection
      original = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      yield
    ensure
      ActionController::Base.allow_forgery_protection = original
    end
end
