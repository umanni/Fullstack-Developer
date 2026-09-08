# frozen_string_literal: true

module UserImports
  # The only strategy structure allowed in this project (arquitetura §2.1,
  # regra 1): an interface with #parse and a registry of extension -> impl.
  # Formats are selected by DATA (a constant hash), not by a Factory object.
  class Parser
    REGISTRY = {
      ".csv" => Roo,
      ".xlsx" => Roo,
      ".xls" => Roo
    }.freeze

    # Selects the implementation for a file name — the single place that
    # knows which format maps to which strategy (OCP: new format = new entry).
    def self.for(file_name)
      implementation = REGISTRY[File.extname(file_name.to_s).downcase]
      raise ArgumentError, "unsupported spreadsheet format: #{file_name}" unless implementation

      implementation
    end

    # Contract: yields UserImports::Result { headers:, rows:, total_rows: }.
    def parse(_uploaded_file)
      raise NotImplementedError, "#{self.class} must implement #parse"
    end
  end
end
