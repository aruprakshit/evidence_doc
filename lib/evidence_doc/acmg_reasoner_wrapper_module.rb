require 'json'

module EvidenceDoc
  class AcmgReasonerWrapperModule
    # Conver the tags in number of pathogenic-strong, LP-strong kind of categorization
    #if ARGV.length != 1
    #  raise "Provide comma limited tags from command line. EXAMPLE: ruby #{$0} PVS1,PS2"
    #end

    def self.score( array )
      hash = Hash.new(0)
      array.each{|key| hash[key] += 1}
      #hash
      return_string = ""
      hash.each do |key,value|
        return_string = return_string + key + "=" + value.to_s + ","
      end
      return_string = return_string[0...-1]
      #return_string = return_string + '"'
      return_string
    end

    def self.acmgTag2Strength tag
      map_hash = {
        "PVS1" => "Pathogenic.Very Strong",
        "PS1" => "Pathogenic.Strong",
        "PS2" => "Pathogenic.Strong",
        "PS3" => "Pathogenic.Strong",
        "PS4" => "Pathogenic.Strong",
        "PM1" => "Pathogenic.Moderate",
        "PM2" => "Pathogenic.Moderate",
        "PM3" => "Pathogenic.Moderate",
        "PM4" => "Pathogenic.Moderate",
        "PM5" => "Pathogenic.Moderate",
        "PM6" => "Pathogenic.Moderate",
        "PP1" => "Pathogenic.Supporting",
        "PP2" => "Pathogenic.Supporting",
        "PP3" => "Pathogenic.Supporting",
        "PP4" => "Pathogenic.Supporting",
        "PP5" => "Pathogenic.Supporting",
        "BP1" => "Benign.Supporting",
        "BP2" => "Benign.Supporting",
        "BP3" => "Benign.Supporting",
        "BP4" => "Benign.Supporting",
        "BP5" => "Benign.Supporting",
        "BP6" => "Benign.Supporting",
        "BP7" => "Benign.Supporting",
        "BS1" => "Benign.Strong",
        "BS2" => "Benign.Strong",
        "BS3" => "Benign.Strong",
        "BS4" => "Benign.Strong",
        "BA1" => "Benign.Stand Alone",
        "BS1-Supporting" => "Benign.Supporting",
        "BS2-Supporting" => "Benign.Supporting",
        "BP1-Strong" => "Benign.Strong",
        "BP3-Strong" => "Benign.Strong",
        "BP4-Strong" => "Benign.Strong",
        "BP7-Strong" => "Benign.Strong",
        "BS3-Supporting" => "Benign.Supporting",
        "BS4-Supporting" => "Benign.Supporting",
        "BP2-Strong" => "Benign.Strong",
        "BP6-Strong" => "Benign.Strong",
        "BP5-Strong" => "Benign.Strong",
        "PM2-Supporting" => "Pathogenic.Supporting",
        "PS4-Supporting" => "Pathogenic.Supporting",
        "PM4-Supporting" => "Pathogenic.Supporting",
        "PM5-Supporting" => "Pathogenic.Supporting",
        "PS1-Supporting" => "Pathogenic.Supporting",
        "PVS1-Supporting" => "Pathogenic.Supporting",
        "PM1-Supporting" => "Pathogenic.Supporting",
        "PS3-Supporting" => "Pathogenic.Supporting",
        "PM6-Supporting" => "Pathogenic.Supporting",
        "PS2-Supporting" => "Pathogenic.Supporting",
        "PM3-Supporting" => "Pathogenic.Supporting",
        "PS4-Moderate" => "Pathogenic.Moderate",
        "PP3-Moderate" => "Pathogenic.Moderate",
        "PS1-Moderate" => "Pathogenic.Moderate",
        "PVS1-Moderate" => "Pathogenic.Moderate",
        "PP2-Moderate" => "Pathogenic.Moderate",
        "PS3-Moderate" => "Pathogenic.Moderate",
        "PP1-Moderate" => "Pathogenic.Moderate",
        "PS2-Moderate" => "Pathogenic.Moderate",
        "PP5-Moderate" => "Pathogenic.Moderate",
        "PP4-Moderate" => "Pathogenic.Moderate",
        "PM2-Strong" => "Pathogenic.Strong",
        "PP3-Strong" => "Pathogenic.Strong",
        "PM4-Strong" => "Pathogenic.Strong",
        "PM5-Strong" => "Pathogenic.Strong",
        "PVS1-Strong" => "Pathogenic.Strong",
        "PM1-Strong" => "Pathogenic.Strong",
        "PP2-Strong" => "Pathogenic.Strong",
        "PP1-Strong" => "Pathogenic.Strong",
        "PM6-Strong" => "Pathogenic.Strong",
        "PM3-Strong" => "Pathogenic.Strong",
        "PP5-Strong" => "Pathogenic.Strong",
        "PP4-Strong" => "Pathogenic.Strong",
        "PM2-Very Strong" => "Pathogenic.Very Strong",
        "PS4-Very Strong" => "Pathogenic.Very Strong",
        "PS1-Very Strong" => "Pathogenic.Very Strong",
        "PM4-Very Strong" => "Pathogenic.Very Strong",
        "PM5-Very Strong" => "Pathogenic.Very Strong",
        "PP3-Very Strong" => "Pathogenic.Very Strong",
        "PP2-Very Strong" => "Pathogenic.Very Strong",
        "PM1-Very Strong" => "Pathogenic.Very Strong",
        "PS3-Very Strong" => "Pathogenic.Very Strong",
        "PP1-Very Strong" => "Pathogenic.Very Strong",
        "PM6-Very Strong" => "Pathogenic.Very Strong",
        "PS2-Very Strong" => "Pathogenic.Very Strong",
        "PM3-Very Strong" => "Pathogenic.Very Strong",
        "PP5-Very Strong" => "Pathogenic.Very Strong",
        "PP4-Very Strong" => "Pathogenic.Very Strong"
      }
      return map_hash[tag]
    end

    def self.summaryToFinalAssertion summary
      file = "#{__dir__}/Reasoner.R "
      command = file + '"Guidelines\tBenign.Stand Alone\tBenign.Strong\tBenign.Supporting\tPathogenic.Moderate\tPathogenic.Strong\tPathogenic.Supporting\tPathogenic.Very Strong\tInference\nRule29\t\t\t>=1\t\t\t\t>=1\tUncertain Significance - Conflicting Evidence\nRule28\t>=1\t\t\t\t\t>=1\t\tUncertain Significance - Conflicting Evidence\nRule27\t>=1\t\t\t>=1\t\t\t\tUncertain Significance - Conflicting Evidence\nRule26\t>=1\t\t\t\t>=1\t\t\tUncertain Significance - Conflicting Evidence\nRule25\t>=1\t\t\t\t\t\t>=1\tUncertain Significance - Conflicting Evidence\nRule24\t\t>=1\t\t\t\t>=1\t\tUncertain Significance - Conflicting Evidence\nRule23\t\t>=1\t\t\t\t\t>=1\tUncertain Significance - Conflicting Evidence\nRule22\t\t>=1\t\t>=1\t\t\t\tUncertain Significance - Conflicting Evidence\nRule21\t\t>=1\t\t\t>=1\t\t\tUncertain Significance - Conflicting Evidence\nRule20\t\t\t\t==2\t==1\t\t\tLikely Pathogenic\nRule19\t\t\t>=2\t\t\t\t\tLikely Benign\nRule18\t\t==1\t==1\t\t\t\t\tLikely Benign\nRule17\t==1\t\t\t\t\t\t\tBenign - Stand Alone\nRule16\t\t>=2\t\t\t\t\t\tBenign\nRule15\t\t\t\t==1\t\t>=4\t\tLikely Pathogenic\nRule14\t\t\t\t==2\t\t>=2\t\tLikely Pathogenic\nRule13\t\t\t\t>=3\t\t\t\tLikely Pathogenic\nRule12\t\t\t\t\t==1\t>=2\t\tLikely Pathogenic\nRule11\t\t\t\t==1\t==1\t\t\tLikely Pathogenic\nRule10\t\t\t\t\t\t>=2\t==1\tLikely Pathogenic\nRule32\t\t\t>=1\t>=1\t\t\t\tUncertain Significance - Conflicting Evidence\nRule31\t\t\t>=1\t\t\t>=1\t\tUncertain Significance - Conflicting Evidence\nRule30\t\t\t>=1\t\t>=1\t\t\tUncertain Significance - Conflicting Evidence\nRule9\t\t\t\t==1\t\t\t==1\tLikely Pathogenic\nRule8\t\t\t\t==1\t==1\t>=4\t\tPathogenic\nRule7\t\t\t\t==2\t==1\t>=2\t\tPathogenic\nRule6\t\t\t\t>=3\t==1\t\t\tPathogenic\nRule5\t\t\t\t\t>=2\t\t\tPathogenic\nRule4\t\t\t\t\t\t>=2\t==1\tPathogenic\nRule3\t\t\t\t==1\t\t==1\t==1\tPathogenic\nRule2\t\t\t\t>=2\t\t\t==1\tPathogenic\nRule1\t\t\t\t\t>=1\t\t==1\tPathogenic\n"  "FinalCallMetaRule\tNumberOfAssertions\tUniqueAssertions\tInference\tExplanation\n49\t5\tLikely Benign,Pathogenic,Likely Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n38\t3\tPathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n27\t2\tPathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n16\t3\tUncertain Significance - Conflicting Evidence,Likely Pathogenic,Benign\tUncertain Significance - Conflicting Evidence\tThree assertions: Likely Pathogenic, Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n5\t1\tLikely Benign\tLikely Benign\tAs the rules only suggest one assertion that is Likely Pathogenic, the final assertion is Likely Benign\n44\t4\tLikely Benign,Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n33\t3\tBenign,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n22\t4\tUncertain Significance - Conflicting Evidence,Pathogenic,Likely Benign,Benign\tUncertain Significance - Conflicting Evidence\tFour assertions: Pathogenic, Likely Benign, Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n11\t2\tUncertain Significance - Conflicting Evidence,Pathogenic\tUncertain Significance - Conflicting Evidence\tTwo assertions: Pathogenic and Uncertain Significance - Conflicting Evidence were made. The final call in this case is Uncertain Significance - Conflicting Evidence.\n50\t6\tBenign,Likely Benign,Pathogenic,Likely Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n39\t3\tLikely Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n28\t2\tLikely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n17\t3\tUncertain Significance - Conflicting Evidence,Pathogenic,Likely Benign\tUncertain Significance - Conflicting Evidence\tThree assertions: Pathogenic, Likely Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n6\t1\tUncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tAs the rules only suggest one assertion that is Uncertain Significance - Insufficient Evidence, the final assertion is Uncertain Significance - Insufficient Evidence\n45\t4\tLikely Benign,Likely Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n34\t3\tLikely Benign,Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n23\t5\tPathogenic,Likely Pathogenic,Benign,Likely Benign,Uncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tFive Assertions: Benign, Pathogenic, Likely Pathogenic, Likely Benign and Uncertain Significance - Conflicting Evidence were made. The final call in such case is Uncertain Significance - Conflicting Evidence.\n12\t2\tUncertain Significance - Conflicting Evidence,Likely Pathogenic\tUncertain Significance - Conflicting Evidence\tTwo assertions: Likely Pathogenic and Uncertain Significance - Conflicting Evidence were made. The final call in this case is Uncertain Significance - Conflicting Evidence.\n1\t0\t\tUncertain Significance - Insufficient Evidence\tGiven set of evidence are not sufficient to make any assertions.\n40\t4\tBenign,Likely Benign,Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n29\t2\tUncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n18\t3\tPathogenic,Benign,Uncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tThree assertions: Pathogenic, Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n7\t2\tPathogenic,Likely Pathogenic\tPathogenic\tTwo assertions: Pathogenic and Likely Pathogenic were made. In such case the final call is the highest strength call, hence the allele is Pathogenic\n46\t4\tPathogenic,Likely Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n35\t3\tLikely Benign,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n24\t1\tBenign - Stand Alone\tBenign - Stand Alone\t\n13\t2\tUncertain Significance - Conflicting Evidence,Benign\tUncertain Significance - Conflicting Evidence\tTwo assertions: Benign and Uncertain Significance - Conflicting Evidence were made. The final call in this case is Uncertain Significance - Conflicting Evidence.\n2\t1\tPathogenic\tPathogenic\tAs the rules only suggest one assertion that is Pathogenic, the final assertion is Pathogenic\n41\t4\tBenign,Likely Benign,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n30\t3\tBenign,Likely Benign,Benign - Stand Alone\tBenign - Stand Alone\t\n19\t4\tUncertain Significance - Conflicting Evidence,Likely Pathogenic,Likely Benign,Pathogenic\tUncertain Significance - Conflicting Evidence\tFour assertions: Likely Pathogenic, Pathogenic, Likely Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n8\t2\tBenign,Likely Benign\tBenign\tTwo assertions: Benign and Likely Benign were made. In such case the final call is the highest strength call, hence the allele is Benign\n47\t5\tBenign,Likely Benign,Pathogenic,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n36\t3\tLikely Benign,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n25\t2\tBenign,Benign - Stand Alone\tBenign - Stand Alone\t\n14\t2\tUncertain Significance - Conflicting Evidence,Likely Benign\tUncertain Significance - Conflicting Evidence\tTwo assertions: Likely Benign and Uncertain Significance - Conflicting Evidence were made. The final call in this case is Uncertain Significance - Conflicting Evidence.\n3\t1\tBenign\tBenign\tAs the rules only suggest one assertion that is Benign, the final assertion is Benign\n42\t4\tBenign,Likely Benign,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n31\t3\tBenign,Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n20\t4\tUncertain Significance - Conflicting Evidence,Likely Pathogenic,Pathogenic,Benign\tUncertain Significance - Conflicting Evidence\tFour assertions: Likely Pathogenic, Pathogenic, Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n9\t3\tPathogenic,Likely Pathogenic,Uncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tThree assertions: Pathogenic, Likely Pathogenic and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n48\t5\tBenign,Likely Benign,Pathogenic,Uncertain Significance - Conflicting Evidence,Benign - Stand Alone\tBenign - Stand Alone\t\n37\t3\tPathogenic,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n26\t2\tLikely Benign,Benign - Stand Alone\tBenign - Stand Alone\t\n15\t3\tLikely Pathogenic,Likely Benign,Uncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tThree assertions: Likely Pathogenic, Likely Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n4\t1\tLikely Pathogenic\tLikely Pathogenic\tAs the rules only suggest one assertion that is Likely Pathogenic, the final assertion is Likely Pathogenic\n43\t4\tLikely Benign,Pathogenic,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n32\t3\tBenign,Likely Pathogenic,Benign - Stand Alone\tBenign - Stand Alone\t\n21\t4\tUncertain Significance - Conflicting Evidence,Likely Pathogenic,Likely Benign,Benign\tUncertain Significance - Conflicting Evidence\tFour assertions: Likely Pathogenic, Likely Benign, Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n10\t3\tBenign,Likely Benign,Uncertain Significance - Conflicting Evidence\tUncertain Significance - Conflicting Evidence\tThree assertions: Benign, Likely Benign and Uncertain Significance - Conflicting Evidence were made. In such cases the final call is Uncertain Significance - Conflicting Evidence.\n"' + '  "' + "#{summary}" + '"'
      abc = %x( #{command} )
      return abc
    end

    def self.tags2assertion in_tags
      #in_tags = ARGV[0]
      puts in_tags.inspect
      tags_array = []
      in_tags = Array(in_tags)
      in_tags.each do |tag|
        tags_array.push(acmgTag2Strength(tag))
      end
      last_arg = score(tags_array)
      return_response = summaryToFinalAssertion last_arg
      puts return_response
      return JSON.parse(return_response)["Reasoner output"]["properties"]["FinalCall"]["value"]
    end
  end
end
