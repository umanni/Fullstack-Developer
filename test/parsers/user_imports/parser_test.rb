require "test_helper"

class UserImports::ParserTest < ActiveSupport::TestCase
  test "registry selects the implementation by extension" do
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("users.csv")
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("users.xlsx")
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("users.xls")
    assert_raises(ArgumentError) { UserImports::Parser.for("users.pdf") }
  end

  test "parse normalizes headers and attribute rows and skips blanks" do
    with_csv(<<~CSV) do |path|
      Full Name,EMAIL ADDRESS,Avatar URL
        Alice Import  ,alice@iam.test,https://example.com/a.png

      Bob Import,bob@iam.test,
    CSV
      result = UserImports::Parser.for("users.csv").new.parse(path)

      assert_equal %i[full_name email_address avatar_url], result.headers
      assert_equal 2, result.total_rows

      rows = result.rows.to_a
      assert_equal(
        { full_name: "Alice Import", email_address: "alice@iam.test", avatar_url: "https://example.com/a.png" },
        rows[0].attributes
      )
      assert_equal 2, rows[0].row_number
      assert_equal(
        { full_name: "Bob Import", email_address: "bob@iam.test", avatar_url: nil },
        rows[1].attributes
      )
      assert_equal 4, rows[1].row_number
    end
  end

  test "unknown headers are ignored" do
    with_csv("Full name,Email address,Spam Ding\nAda,ada@iam.test,nope\n") do |path|
      result = UserImports::Parser.for("users.csv").new.parse(path)

      assert_equal %i[full_name email_address], result.headers
      assert_equal({ full_name: "Ada", email_address: "ada@iam.test" }, result.rows.first.attributes)
    end
  end

  test "rows are lazily enumerated from the sheet" do
    with_csv("Full name,Email address\nA,a@iam.test\nB,b@iam.test\n") do |path|
      result = UserImports::Parser.for("users.csv").new.parse(path)

      assert_kind_of Enumerator::Lazy, result.rows
      assert_equal 2, result.total_rows
    end
  end

  test "rejects unsupported file extensions" do
    error = assert_raises(ArgumentError) { UserImports::Parser.for("users.ods") }
    assert_includes error.message, "unsupported spreadsheet format"
  end

  test "the base parser enforces the parse contract" do
    assert_raises(NotImplementedError) { UserImports::Parser.new.parse("noop") }
  end

  test "for selects the Roo strategy by extension" do
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("users.csv")
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("users.xlsx")
    assert_equal UserImports::Parser::Roo, UserImports::Parser.for("USERS.XLS")
  end

  private

  def with_csv(content)
    Tempfile.create([ "users", ".csv" ]) do |file|
      file.write(content)
      file.flush
      yield file.path
    end
  end
end
