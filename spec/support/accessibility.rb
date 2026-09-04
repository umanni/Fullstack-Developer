require "json"

# Runs axe-core against the page the browser is showing. The axe-core-rspec
# matcher would do this too, but it reaches for Selenium's driver API, and
# these specs drive Chrome over CDP with Cuprite -- so the few lines it takes
# to load the library and read the violations live here instead.
module AccessibilityChecking
  AXE_JS = Pathname.new(Gem.loaded_specs.fetch("axe-core-api").gem_dir)
                   .join("node_modules/axe-core/axe.min.js")

  # The WCAG 2.1 AA rule sets, which is the level the README claims.
  RULE_SETS = %w[wcag2a wcag2aa wcag21a wcag21aa].freeze

  def accessibility_violations
    load_axe

    page.evaluate_async_script(<<~JS, RULE_SETS)
      const done = arguments[arguments.length - 1];
      axe.run(document, { runOnly: { type: "tag", values: arguments[0] } })
         .then((results) => done(JSON.parse(JSON.stringify(results.violations))));
    JS
  end

  private

  def load_axe
    return if page.evaluate_script("typeof window.axe === 'object'")

    page.execute_script(AXE_JS.read)
  end
end

# Reads as an expectation about the page and fails with the rule, the impact
# and the offending markup, which is what makes a failure actionable.
RSpec::Matchers.define :be_accessible do
  match do |page_under_test|
    @violations = page_under_test.accessibility_violations
    @violations.empty?
  end

  failure_message do
    lines = @violations.map do |violation|
      targets = violation["nodes"].map { |node| Array(node["target"]).join(" ") }.first(3)
      "  [#{violation["impact"]}] #{violation["id"]}: #{violation["help"]}\n    " \
        "#{targets.join("\n    ")}\n    #{violation["helpUrl"]}"
    end

    "expected the page to have no accessibility violations, but axe reported " \
      "#{@violations.size}:\n#{lines.join("\n")}"
  end
end

RSpec.configure do |config|
  config.include AccessibilityChecking, type: :system
end
