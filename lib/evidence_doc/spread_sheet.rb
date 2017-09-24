require 'rubyXL'

module EvidenceDoc
  class SpreadSheet
    HGVS_VELL_CELL    = 12
    CAID_CELL         = 13
    MAF_CELL          = 14
    CLIN_VAR_URL_CELL = 15

    def initialize path_to_file
      @workbook = RubyXL::Parser.parse(path_to_file)
    end

    def write_to_cell row, col, val
      worksheet.add_cell(row, col, val)
    end

    def read_from_cell row, col
      row.cells[col].value
    end

    def each_row start_row = 1, &block
      worksheet.each do |row|
         next if row && row.r < start_row
         yield row
      end

    ensure
      @workbook.save
    end

    private

      def worksheet
        @worksheet ||= @workbook[0]
      end
  end
end
