require "test_helper"

class Users::DestroyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "deletes a standard user and broadcasts updated statistics" do
    user = users(:member)

    assert_enqueued_with(job: Dashboard::BroadcastStatsJob) do
      assert_difference "User.count", -1 do
        Users::Destroy.call(user:)
      end
    end

    assert_predicate user, :destroyed?
  end

  test "does not delete the final administrator" do
    users(:second_admin).update!(role: :user)
    admin = users(:admin)

    assert_no_difference "User.count" do
      Users::Destroy.call(user: admin)
    end

    assert_includes admin.errors[:base], Users::Destroy::LAST_ADMIN_MESSAGE
  end

  test "allows an administrator deletion while another administrator remains" do
    admin = users(:admin)

    assert_difference "User.count", -1 do
      Users::Destroy.call(user: admin)
    end
  end

  test "preserves import history when its administrator is deleted" do
    admin = users(:admin)
    user_import = UserImport.create!(created_by: admin, spreadsheet: {
      io: StringIO.new("full_name,email,avatar_image_url\n"), filename: "users.csv", content_type: "text/csv"
    })

    assert_difference "User.count", -1 do
      assert_no_difference "UserImport.count" do
        Users::Destroy.call(user: admin)
      end
    end

    assert_nil user_import.reload.created_by
  end

  test "deletes an imported user without deleting its row history" do
    user = users(:member)
    user_import = UserImport.create!(created_by: users(:admin), spreadsheet: {
      io: StringIO.new("full_name,email,avatar_image_url\n"), filename: "users.csv", content_type: "text/csv"
    })
    import_row = user_import.rows.create!(
      row_number: 2,
      payload: { "full_name" => user.full_name, "email" => user.email },
      status: :succeeded,
      user:
    )

    assert_difference "User.count", -1 do
      assert_no_difference "UserImportRow.count" do
        Users::Destroy.call(user:)
      end
    end

    assert_nil import_row.reload.user
  end
end
