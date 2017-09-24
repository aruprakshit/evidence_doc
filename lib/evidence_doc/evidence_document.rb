require 'evidence_doc/generate_evidence_documents'
require 'evidence_doc/spread_sheet'
require 'evidence_doc/gnom_cache'
require 'evidence_doc/evidence'
require 'evidence_doc/acmg_reasoner_wrapper_module'

require 'ostruct'

module EvidenceDoc
  class EvidenceDocument
    URL = 'https://www.ncbi.nlm.nih.gov/pubmed/'

    COLUMNS = {
      'caid' => 14,
      'pmid' => 9,
      'pathogenicity' => 20,
      'tags' => {
        'bs1' => 23,
        'bs2' => 24,
        'ba1' => 25,
        'pm2' => 26,
        'ps4' => 27,
        'bp1' => 28,
        'bp3' => 29,
        'bp4' => 30,
        'bp7' => 31,
        'pp3' => 32,
        'pm4' => 33,
        'pm5' => 34,
        'ps1' => 35,
        'pvs1' => 36,
        'bs3' => 37,
        'pp2' => 38,
        'pm1' => 39,
        'ps3' => 40,
        'bs4' => 41,
        'pp1' => 42,
        'pm6' => 43,
        'ps2' => 44,
        "bp2" => 45,
        "pm3" => 46,
        'bp6' => 47,
        'pp5' => 48,
        'bp5' => 49,
        'pp4' => 50
      }
    }

    FILE_PATH = File.realpath('data/input.xlsx', __dir__)

    attr_reader :columns

    def initialize
      @columns = to_ostruct(COLUMNS)
    end

    def generate
      start_row = 4   # should be changed as per the sheet organization
      last_row  = 9   # should be changed as per the sheet organization

      sheet = SpreadSheet.new(FILE_PATH)
      sheet.each_row(start_row) do |row|
        break if row.r > last_row
        caid = sheet.read_from_cell(row, columns.caid)
        tags = sheet.read_from_cell(row, columns.tags.bs1)
        tags_and_comments = {}

        columns.tags.each_pair do |tag_name, column_number|
          tags_and_comments[tag_name.upcase] = sheet.read_from_cell(row, column_number)
        end

        pmid = sheet.read_from_cell(row, columns.pmid)
        pmids = pmid.to_s.strip.split(/[,;]/) if pmid.to_s.strip != '?' && !pmid.nil?
        pmids = pmids.map { |id| "https://www.ncbi.nlm.nih.gov/pubmed/#{id}"}.join('@') if pmids

        tags_and_comments = delete_blank_tags(tags_and_comments)
        cache_store.put(
          caid,
          [
            tags_and_comments.keys.join('@'),                   # tags
            tags_and_comments.values.join('@ '),                # tags summary,
            pmids || '',                                              # commaSepratedLinks
            "#{pmid}#{'@' * (tags_and_comments.keys.size - 1)}" # commaSeparatedCommentsToLink
          ]
        )

        puts "Processing Row number: #{row.r}"
      end

      puts cache_store.to_hash.inspect
      cache_store.to_hash.each do |caid, values|
        json_generator = EvidenceDoc::GenerateEvidenceDocuments.new(
          caid,
          values[0],
          values[1],
          values[2],
          values[3])
        result = json_generator.run

        File.open("#{__dir__}/data/#{caid}.json", 'w') do |f|
          f.write(result)
        end
      end
    end

    def pathogenicity
      start_row = 4
      last_row  = 9

      sheet = SpreadSheet.new(FILE_PATH)
      sheet.each_row(start_row) do |row|
        break if row.r > last_row
        tags_and_comments = {}
        caid = sheet.read_from_cell(row, columns.caid)

        columns.tags.each_pair do |tag_name, column_number|
          tags_and_comments[tag_name.upcase.to_s] = sheet.read_from_cell(row, column_number)
        end

        tags_and_comments = delete_blank_tags(tags_and_comments)
        cache_store.put(
          caid,
          tags_and_comments.keys
        )
      end

      cache_store.to_hash.each do |k, v|
        puts EvidenceDoc::AcmgReasonerWrapperModule.tags2assertion(v)
      end
    end

    private

    def to_ostruct(hash)
      OpenStruct.new(hash.each_with_object({}) do |(key, val), memo|
        memo[key] = val.is_a?(Hash) ? to_ostruct(val) : val
      end)
    end

    def cache_store
      @store ||= GnomeCache.new
    end

    def delete_blank_tags tags_data
      tags_data.reject { |k, v| v.nil? }
    end
  end
end
