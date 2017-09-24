require 'evidence_doc/evidence.rb'

# if ARGV.length != 9
#   $stderr.puts "***********************************************"
#   $stderr.puts "Require nine arguments at the command line interface"
#   $stderr.puts "#{$0} caid commaSeparatedTags modeOfInheritance phenotype login password commaSeparatedTagComments commaSepratedLinks commaSeparatedCommentsToLink"
#   $stderr.puts "#{$0} ruby generateEvidenceDocuments.rb CA11020 PVS1,PS1,PS3 Unknown Unknown login password 'Tag1 summary,Tag2 summary, Tag3 summary' 'http://dummy.org/tag1_link,http://dummy.org/tag2_link,http://dummy.org/tag3_link' 'Notes for l1,Notes for l2,Notesfor l3"
#   $stderr.puts "***********************************************"
#   raise "Insufficient arguments at the command line"
# end
module EvidenceDoc
  class GenerateEvidenceDocuments
    attr_accessor :caid,
      :tags,
      :moi,
      :phenotype,
      :login,
      :password,
      :tag_comments,
      :links,
      :links_comments

    def initialize(*args)
      raise "Insufficient arguments at the command line" if args.length != 5

      @caid           = args[0]
      @tags           = args[1]
      @moi            = 'Unknown'
      @phenotype      = 'Unknown'
      @login          = 'milossof@gmail.com'
      @password       = 'ashg1961'
      @tag_comments   = args[2]
      @links          = args[3]
      @links_comments = args[4]
    end

    def run
      # Validate CAid
      if caid.match(/^CA[0-9]+$/).nil?
        raise "Can't parse caid passed as the first argument to script"
      end
      # Validate tags
      if tags == ""
        raise "Please provide comma separated tags, eg. PVS1,PS1,PS2"
      end

      # Set moi and phenotype to unknown if blank provided
      if moi == ""
        $stderr.puts "Setting mode of inheritance to Unknown"
        self.moi = "Unknown"
      end

      if !["Autosomal Dominant", "Autosomal Recessive", "X-linked Dominant", "X-linked Recessive", "Mitochondrial", "Multifactorial" , "Other", "Unknown"].include?(moi)
        raise "The mode of inheritance is not valid should be one of the following values:
        Autosomal Dominant, Autosomal Recessive, X-linked Dominant, X-linked Recessive, Mitochondrial, Multifactorial , Other, Unknown"
      end

      if phenotype == ""
        $stderr.puts "Setting phenotype to Unknown"
        self.phenotype = "Unknown"
      end

      if login == ""
        raise "please provide login name that is not blank"
      end

      if password == ""
        raise "please provide password that is not blank"
      end

      #abc = Evidence.new()

      tags_array = []
      links_array  = []
      tag_comments_array = []
      links_comments_array = []

      # replaced all `,` split to `@`, as main data includes `,`. So split on
      # , will not work.
      tags.split("@").each do |tag|
        tags_array.push(tag)
        links_array.push(nil)
        links_comments_array.push(nil)
        tag_comments_array.push(nil)
      end

      i = 0
      links.split("@").each do |link|
        links_array[i] = link
        i+=1
      end

      i = 0
      tag_comments.split("@").each do |tag_comment|
        tag_comments_array[i] = tag_comment
        i+=1
      end

      i = 0
      links_comments.split("@").each do |comment|
        links_comments_array[i] = comment
        i+=1
      end

      if([tags_array.length , links_array.length, links_comments_array.length,tag_comments_array.length].uniq.length != 1)
        raise "Cant continue: number of tags, comments, links and comments to link dont match"
      end

      abc = Evidence.new( caid , phenotype, moi, tags_array, tag_comments , links_array, links_comments_array )
      abc = abc.to_hash

      JSON.pretty_generate abc
    end
  end
end


# caid       = ARGV[0]
# tags       = ARGV[1]
# moi        = ARGV[2]
# phenotype  = ARGV[3]
# login      = ARGV[4]
# password   = ARGV[5]
# tag_comments = ARGV[6]
# links      = ARGV[7]
# links_comments      = ARGV[8]
