#!/usr/local/bin/Rscript --vanilla
suppressMessages(library(jsonlite))

# This is the function to generate document id for reasoner output
generateString <- function(){
 return(paste(sample(c("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"),25,replace=TRUE),collapse=""))
}

# an empty list to store output in json format
abc2 = list()
abc2$`Reasoner output` =  list()
abc2$`Reasoner output`$value =   generateString()
abc2$`Reasoner output`$properties =   list()

# This is a generic function to report error
reportFunction <- function(Name, Message, abc2, error=TRUE){
   Status = list()
   if(error){Status$value = "error"}
   if(!error){Status$value = "warning"}
   Status$properties$Name$value = Name
   Status$properties$Message$value = Message
   abc2$`Reasoner output`$properties$Status =  Status
   return(abc2)
}

# Read command line arguments
 args <- commandArgs(TRUE)

# See if two arguments are provided else stop with error
 if(length(args) != 3){
   stop((toJSON( reportFunction(
                      Name = "Insufficient number of command line arguments.",
                      Message = "Error Parsing Command Line Arguments: I need three arguments and are not provided. First one is ACMG guidelines as a single string. Second argument is for special cases. Third with number of evidence in each category for given variant." ,
                      abc2 = abc2,
                      error = TRUE
                        ),
                   pretty=TRUE,auto_unbox=TRUE)))
 }

# Declare conclusion.list as empty variable. This variable will be used to store the conclusions
 conclusion.list <- NULL

# Read ACMG guidelines
# Replace \t with tabs and \n with newline to convert the single string to data frame
 abc <- gsub(gsub(x=args[1],pattern="\\t",fixed=TRUE,replacement="  "),pattern="\\n",fixed=TRUE,replacement="\n")

# Store the guidelines as data frame in variable input
   input <- try(read.csv(text=abc,sep="\t",row.names=1,fill = FALSE,check.names=FALSE), silent = TRUE)
   if(class(input) == "try-error"){
     stop(print(toJSON(reportFunction(Name = "Guidelines Parse Error.",
                                Message = "Failed to use read.csv function on command line argument",
                                abc2 = abc2,
                                error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
   }

# Some times if fields are not populated by default NA is generated for those cases:
 input[which(is.na(input),arr.ind=TRUE)] <- ""

# Check if guidelines are valid
 if(ncol(input) <= 3){
  stop(print(toJSON(reportFunction(Name = "Guidelines Parse Error.",
                                   Message = "Guidelines not read in. Make sure that proper guidelines are provided enclosed in quotes. Guidelines have less than three column.",abc2 = abc2,error=TRUE), pretty=TRUE,auto_unbox=TRUE)))
 }

# Error if less than two rules are provided
 if(nrow(input) < 2){
   stop(print(toJSON(reportFunction(Name = "Guidelines Parse Error.",
                                    Message = "Need atleast two rules in guidelines to make interpretations",
                                    abc2=abc2, error=TRUE ),pretty=TRUE,auto_unbox=TRUE)))
 }

# Read metaRules for making final call
 final.call.meta.rules  <- gsub(gsub(x=args[2],pattern="\\t",fixed=TRUE,replacement="   "),pattern="\\n",fixed=TRUE,replacement="\n")
 final.call.meta.rules  = try(read.csv(text=final.call.meta.rules,sep="\t",row.names=1,fill = FALSE,check.names=FALSE), silent = TRUE)
   if(class(final.call.meta.rules) == "try-error"){
     stop(print(toJSON(reportFunction(Name = "Metarule Parse Error.",
                                Message = "Failed to use read.csv function on command line argument",
                                abc2 = abc2,
                                error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
   }

# for every row see if NumberOfAssertions = size(UniqueAssertions)
 for(i in 1:nrow(final.call.meta.rules)){
    if(as.numeric(final.call.meta.rules$NumberOfAssertions[i]) !=
           length(strsplit(as.character(final.call.meta.rules$UniqueAssertions[i]),",")[[1]]))
          {
             stop(print(toJSON(reportFunction(Name = "Metarule Parse Error.",
                                Message = paste("The number of assertions and number of unique assertions don't match for meta rule ",i),
                                abc2 = abc2,
                                error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
          }
 }

# You must check if the assertions defined in metarule actually present in the rules
 temp.assert = NULL
 for(i in 1:nrow(final.call.meta.rules)){
   temp.assert = c(temp.assert, as.character(strsplit(as.character(final.call.meta.rules$UniqueAssertions[i]),",")[[1]]))
 }
 # in the below line maximum one mismatched is allowed. This is when there are zero rules satisfied then there is a metarule that says what to do in such cases.
 if(length(setdiff(as.character(unique(temp.assert)),
                      as.character(input[,ncol(input)]))
             ) > 1){

    stop(print(toJSON(reportFunction(Name = "Rules and Metarules insconsistency",
                      Message = paste("The meta-rules are defined based on the assertions that can be generated  by rules. This error occurs when an assertion is refered in metarules but rules can never generate it"),
                      abc2 = abc2,
                      error=TRUE),pretty=TRUE,auto_unbox=TRUE)))

 }


#Read evidence
 evidences = strsplit(args[3],",")[[1]]

# Check validity of Evidences
# First check: Names of Tags
 evidences = matrix(unlist(sapply(evidences,strsplit,"=")),byrow=TRUE,ncol=2)
 temp <- evidences[,2]
 names(temp) <- evidences[,1]
 evidences <- temp
 check <- setdiff(names(evidences),colnames(input))
 if(length(check) > 0){
  stop(print(toJSON(reportFunction(Name = "Evidence Parse Error.",
                                   Message = paste("One or More of evidence tags that you supplied are not known to provided Guidelines! They are listed here: \"",check, "\".",sep=""), abc2=abc2, error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
 }

# Second check: check the number of evidences are positive integers
 if(length(which(is.na(suppressWarnings(as.integer(evidences))))) > 0){
  stop(print(toJSON(reportFunction(Name = "Evidence Parse Error.",
                                   Message = "The provided number of evidences don't look like positive integers",
                                   abc2=abc2, error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
 }
 if(length(which(suppressWarnings(as.integer(evidences)) <= 0)) > 0){
  stop(print(toJSON(reportFunction(Name = "Evidence Parse Error.",
                                   Message = "Really? Zero or Negative Number of Evidences? If zero evidences then no need pass through second argument. Negative number of evidences do not make sense.",
                                    abc2=abc2, error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
 }
 if(length(which(as.numeric(evidences) != as.integer(evidences))) > 0){
  stop(print(toJSON(reportFunction(Name = "Evidence Parse Error.",
                                   Message = "Floating points are provided for evidences!", abc2=abc2, error=TRUE),pretty=TRUE,auto_unbox=TRUE)))
 }

# After the checks Now compare with ACMG guidelines and make interpretations:
 input.row <- nrow(input)
 input.col <- ncol(input)

# Set the found to FALSE. This will be set true if for given envidences, Inference was made.
# If inference is not made then the variant is of uncertain significance
 found=FALSE
 current.rule.satisfied = FALSE

# A small function to convert table in to single string
# e.g table like
# A B
# 2 3
# will be converted to A:2,B:3
table2string <- function(in.table){
 temp1 <- unlist(c(in.table))
 temp2 <- colnames(in.table)
 return(paste(paste(temp2,temp1,sep=" "),collapse=" & "))
}

# Heart of program to match evidences with Guidelines
for(i in 1:nrow(input)){
 Rule = list()
 # assign value of rule
 # Rule$value = paste("Rule-",i,sep="")
 Rule$value = as.character(row.names(input)[i]) #paste("Rule-",i,sep="")

 # Select fields in Guidelines with non empty values, ie that is not ""
 populated <- which(input[i,1:(input.col-1)] != "")

 # Store them as selected
 selected  <- input[i,populated,drop=FALSE]

 # Set matched to zero
 matched.index <- NULL
 matched.index[1:ncol(selected)] = FALSE
 tot.dist = 0
 counter = 0

 # for every condition of the rule
 for(i1 in 1:ncol(selected)){
   # for every evidence provided
   for(j1 in 1:length(evidences)){
      # if their name matches
      if(colnames(selected)[i1] == names(evidences[j1])){
       # increment counter
       counter = counter + 1
       # mark tht index as matched, as there is code to do if indices are not matched
       matched.index[i1] = TRUE
       # Condition satisfied? Do the condition of rule satisfied
       cond.satisfied = eval(parse(text=paste(evidences[j1], selected[1,i1])))
       # What the condition states
       statement      = paste(colnames(selected)[i1],selected[1,i1])
       # What is needed according to condition
       what_is_needed = selected[1,i1]
       # What is given according to condition
       what_is_given  = evidences[j1]
       # How many more needed
       how_many_to_go = max(0,
                            (
                            as.numeric(
                               substr(selected[1,i1],3,.Machine$integer.max)
                            )
                            -
                            as.numeric(evidences[j1])
                            )
                           )
       # update total distance
       tot.dist = tot.dist + how_many_to_go

       # The following code is to generate output in JSON format
       Condition = list()
       Condition$value  = statement
       Condition$properties$Condition$value = what_is_needed
       Condition$properties$Observed$value = unname(what_is_given)
       Condition$properties$PartitionPath$value = colnames(selected)[i1] #names(what_is_needed)
       # The followin line computes the distance but removed due to Andrew Suggestion
       # Condition$properties$HowManyNeeded$value = how_many_to_go
       Condition$properties$Satisfied$value = cond.satisfied
       Rule$properties$Conditions$items[[counter]] = list()
       Rule$properties$Conditions$items[[counter]]$Condition = Condition
      }
   }
   # When evidence in given category is not at all there
 }
 # Here I have data which part of selected is matched
 # Now when not matched
 unmatched.index = which(matched.index == FALSE)
 # for every unmatched index do this
 for(i3 in unmatched.index){
   # increment counter
   counter = counter + 1
   # condition is not satisfied
   cond.satisfied.2 = FALSE
   # what is the statement of condition
   statement.2  = paste(colnames(selected)[i3],selected[1,i3])
   # what is needed to satisfy condition
   what_is_needed.2 = selected[1,i3]
   # what is given, as obviously there is nothing given here it is zero
   what_is_given.2  = 0
   # compute distance
   how_many_to_go.2 = as.numeric(substr(selected[1,i3],3,.Machine$integer.max))
   # update total distance so far
   tot.dist = tot.dist + as.numeric(substr(selected[1,i3],3,.Machine$integer.max))
   # store in json object for output
   Condition = list()
   Condition$value  = statement.2
   Condition$properties$Condition$value = what_is_needed.2
   Condition$properties$Observed$value = unname(what_is_given.2)
   # this is to compute distance but removed due to Andrew's suggestion
   #Condition$properties$HowManyNeeded$value = how_many_to_go.2
   Condition$properties$Satisfied$value = cond.satisfied.2
   Condition$properties$PartitionPath$value = colnames(selected)[i3] #names(what_is_given.2)
   Rule$properties$Conditions$items[[counter]] = list()
   Rule$properties$Conditions$items[[counter]]$Condition = Condition
 }


 # Check all the conditions if all conditions are satisifed then set rule satisfied is true else false

 #print(length(Rule$properties$Conditions$items))
 true_false_condition = NULL
 for(to_check in 1:length(Rule$properties$Conditions$items)){
   #print(Rule$properties$Conditions$items[[to_check]]$Condition$properties$Satisfied$value)
    true_false_condition = c(true_false_condition,Rule$properties$Conditions$items[[to_check]]$Condition$properties$Satisfied$value)
 }

 #Depending upon the conditions satisified, the following lines set rule.satisfied.
 #Please note that in the previous version this was based on tot.dist which led to problem so now it is fixed
 if(length(unique(true_false_condition)) == 1){
    rule.satisfied = unique(true_false_condition)
 }
 if(length(unique(true_false_condition)) != 1){
    rule.satisfied = FALSE
 }

 #print("Assigning Satisfied Rules")
 Rule$properties$Satisfied$value = rule.satisfied
 #print(rule.satisfied)
 #print("-------------------------------")
 Rule$properties$Assertion$value = input[i,ncol(input)]
 # This is total distance for rule
 # Rule$properties$TotalEvidenceNeeded$value = tot.dist
 Rule$properties$RuleStatement$value = table2string(selected)

 abc2$`Reasoner output`$properties$Rules$items[[i]] =  list()
 abc2$`Reasoner output`$properties$Rules$items[[i]]$Rule = Rule
}

# Now apply metarules
no_rules = length(abc2$`Reasoner output`$properties$Rules$items)
assertion.array = NULL
for(i in 1:no_rules){
  if(abc2$`Reasoner output`$properties$Rules$items[[i]]$Rule$properties$Satisfied$value == TRUE){
    assertion.array = c(assertion.array,as.character(abc2$`Reasoner output`$properties$Rules$items[[i]]$Rule$properties$Assertion$value))
  }
}

assertion.array = unique(assertion.array)
#print(".....................................")
finalCall = "Insufficient Metarules"
finalCallText = "Please revise Metarules so that it covers all scenarios to make final call"

for(i in 1:nrow(final.call.meta.rules)){
  if(final.call.meta.rules$NumberOfAssertions[i] == length(assertion.array)){
    if(length(intersect(strsplit(as.character(final.call.meta.rules$UniqueAssertions[i]),",")[[1]], assertion.array)) == length(assertion.array)){
       finalCall     = as.character(final.call.meta.rules$Inference[i])
       finalCallText = as.character(final.call.meta.rules$Explanation[i])
    }
  }
}

abc2$`Reasoner output`$properties$FinalCall$value = finalCall
abc2$`Reasoner output`$properties$FinalCall$properties$Text$value = finalCallText

abc2$`Reasoner output`$properties$Status$value = "ok"
abc2$`Reasoner output`$properties$Status$properties$Name$value = "ok"
abc2$`Reasoner output`$properties$Status$properties$Message$value = "ok"

write(toJSON(abc2,pretty=TRUE,auto_unbox=TRUE),file="")
