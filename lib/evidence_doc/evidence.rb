require 'json'
require 'digest/sha1'
require 'rest-client'
require 'net/http'

module EvidenceDoc
  CAIDHOST = 'http://reg.genome.network/allele/'
  CALCHOST = 'http://calculator.clinicalgenome.org'

  def buildAuthToken(rsrcURI, gbLogin, userPassword, gbTime = Time.now.to_i)
    gbToken = getgbToken rsrcURI, gbLogin, userPassword, gbTime
    return "gbLogin=#{gbLogin}&gbTime=#{gbTime}&gbToken=#{gbToken}".strip
  end

  def getgbToken(rsrcURI, gbLogin, userPassword, gbTime = Time.now.to_i)
    credential = Digest::SHA1.hexdigest gbLogin + userPassword
    Digest::SHA1.hexdigest rsrcURI + credential + gbTime.to_s
  end

  def uploadDoc(login, pwd, payload, doc)
    # The calculator is set up in such a way that
    grp  = login
    kb   = login
    coll = "Evidence"
    host = CALCHOST

    rsrcPath = "#{host}/REST/v1/grp/#{grp}/kb/#{kb}/coll/#{coll}/doc/#{doc}?"
    uri = "#{rsrcPath}#{buildAuthToken(rsrcPath, login , pwd)}"
    response = RestClient.put uri, payload, {:content_type => :json}
    return response
  end

  def getAllDoc(login,pwd)
    grp  = login
    kb   = login
    coll = "Evidence"
    host = CALCHOST
    rsrcPath = "#{host}/REST/v1/grp/#{grp}/kb/#{kb}/coll/#{coll}/docs?"
    uri = "#{rsrcPath}#{buildAuthToken(rsrcPath, login , pwd)}"
    puts uri
    response = RestClient.get uri
    return response
  end

  class Evidence

    attr_accessor :to_hash
    attr_accessor :add_tag
    attr_accessor :delete_tag

    def initialize(caid, phenotype, modeOfInheritance,tags,tag_comments,links=[],links_comments=[])
       @caid = "#{CAIDHOST}#{caid}"
       @phenotype = phenotype
       @moi = modeOfInheritance
       @tags = tags.to_a
       @links = links
       @links_comments = links_comments
    end

    def to_hash
      alphanumeric = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
      docid = "CLI-#{(0...6).map { alphanumeric[rand(alphanumeric.length)] }.join}-EV"

      tag_hash = []

      (0...@tags.length).each do |i|
        if @links[i].nil?
    tag_hash.push(Tag.new(@tags[i],'On','').to_hash)
        else
    tag_hash.push(Tag.new(@tags[i],'On','',Array(@links[i]),Array(@links_comments[i])).to_hash)
        end
      end

      return_hash = {
        "Allele evidence" => {
    "value" => docid ,
    "properties" => {
      "Subject" => {
        "value" => @caid ,
        "properties" => {
          "Phenotype" => {"value" => @phenotype },
          "Mode of inheritance" =>  {"value" =>@moi },
          "Evidence Tags" =>
            {
        "items" => tag_hash
      }
        }
      }
    }
        }
      }
    end

    def add_tag in_tag
      @tags.push(in_tag)
    end

    def delete_tag in_tag
      @tags.delete(in_tag)
    end

  end

  class Tag

    attr_accessor :to_hash
    attr_accessor :update_summary
    attr_accessor :add_link_and_summary

    # parameters:
    # tag: name of the tag
    # status: on/off
    # summary: text

    def initialize(tag, status, summary, links=[], links_comments=[])
      @tag     = tag
      @status  = status
      @summary = summary
      @t2p     = Tag2Pst.new()
      if @summary.nil? or @summary == ""
        @summary = @t2p.summary @tag
      end
      @links   = links
      @links_comments   = links_comments
    end

    def to_hash
      generate_hash = {
        "Evidence Tag" => {
    "properties" => {
      "Tag" =>
      { "value" => @tag ,
              "properties" => {
         "Status"        => { "value" => @status  } ,
         "Summary"       => { "value" => @summary } ,
         "Pathogenicity" => { "value" => @t2p.pathogenicity(@tag) } ,
         "Strength"      => { "value" => @t2p.strength(@tag)} ,
         "Type"          => { "value" => @t2p.type(@tag) }
        }
      }
    }
        }
      }

      if !@links.empty?
        generate_hash["Evidence Tag"]["properties"]["Tag"]["properties"]["Links"] = {}
        temp_array  = []
        counter = 0
        (0...@links.length).each do |i|
           given_link = {
                   "Link" => {
                       "value" => @links[i],
                       "properties" => {
             "Comment" => {"value" => @links_comments[i]},
             "Link Code" => {"value" => "Supports"}
           },
                     }
                  }
     temp_array.push(given_link)
        end
        generate_hash["Evidence Tag"]["properties"]["Tag"]["properties"]["Links"]["items"] = temp_array
      end

      return generate_hash
    end

    def update_summary in_summary
      @summary = in_summary
    end

    def add_link_and_summary in_link, in_summary
      @links << in_link
      @links_comments <<  in_summary
    end

  end

  class Tag2Pst

    attr_accessor :pathogencity, :strength, :type

    def initialize
      # Read the tags file
      input = JSON.parse(File.read(File.realpath('data/ACMG2015_Caps.json', __dir__)))

      # convert to Hash that has tag as key
      @newHash = Hash.new()

      input["AllowedTags"]["properties"]["Partitions"]["items"].each do |partition|
        partition["Partition"]["properties"]["Tags"]["items"].each do |tag|
    @newHash[tag["Tag"]["value"]] =
      {
      "type"         => partition["Partition"]["properties"]["Level3"]["value"],
      "strength"     => partition["Partition"]["properties"]["Level2"]["value"],
      "pathogencity" => partition["Partition"]["properties"]["Level1"]["value"],
      "Text"         => tag["Tag"]["properties"]["Text"]["value"]
    }
        end
      end
    end

    def pathogenicity tag
      return @newHash[tag]["pathogencity"]
    end

    def strength tag
      return @newHash[tag]["strength"]
    end

    def type tag
      return @newHash[tag]["type"]
    end

    def summary tag
      return @newHash[tag]["Text"]
    end
  end

  def runCalculatorJob (login, pwd, kbdoc)

    grp  = login
    kb   = login
    coll = "Evidence"

    kbDocUrl = "#{CALCHOST}/REST/v1/grp/#{grp}/kb/#{kb}/coll/#{coll}/doc/#{kbdoc}"
    kbTransformUrl = "#{CALCHOST}/REST/v1/grp/pcalc_resources/kb/pcalc_resources/trRulesDoc/acmgTransform"
    rulesDocUrl = "#{CALCHOST}/REST/v1/grp/pcalc_resources/kb/pcalc_resources/coll/GuidelineRulesMetaRules/doc/ACMG2015-Guidelines"
    jobUrl = "#{CALCHOST}/REST/v1/genboree/tool/reasonerV2a1/job?"

    uri = "#{jobUrl}#{buildAuthToken(jobUrl,login,pwd)}"

    puts uri

    jobConf = {
      "inputs" => [kbDocUrl, kbTransformUrl],
      "outputs" => [],
      "settings" => {
        "rulesDoc" => rulesDocUrl
      },
      "context" => {}
    }

    response = RestClient.put uri, jobConf.to_json , {:content_type => :json}

    return response
  end
end
