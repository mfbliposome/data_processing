(* ::Package:: *)

(* <jschrier@fordham.edu> 18 Oct 2023 *)

parseFile::usage = 
	"parseFile[file] reads a mass spec spreadsheet file and unwraps the outputs"<>
	"into columns, per our discussion on 18 Oct 2023"

(*extract the trial number from the prefix of a filename*)
extractTrial[prefix_String]:=With[
	{trialNumber = Interpreter["Number"]@First@StringCases[DigitCharacter..]@prefix},
	<|"trial"->trialNumber|>
]

(*extract the compositional species from the prefix of a filename*)
extractComponents[prefix_String]:=With[
	{components = StringCases[LetterCharacter]@prefix,
	speciesLabels = {"K","S","P","C"}},
	AssociationMap[Boole@MemberQ[components,#]&,speciesLabels]
]

(*interpet the filename into components and trial number values, as Association*)
parseFilename[str_String]:=With[
	{prefix=First@StringSplit[str,"_"],
	filenameInfo = <|"filename"->str|>},
	Join[filenameInfo ,extractTrial[prefix], extractComponents[prefix]]
]

(*can add other validity checks later*)
(*validBlockQ[block_List]:=StringMatchQ[block[[1,1]],"PEAK LIST"]*)

validBlockQ[block_List]:=ContainsAll[{"Apex RT","Start RT","End RT","Area","%Area","Height","%Height"}]@Flatten@block

(*each block of data is 7 columns wide*)
divideSheetIntoBlocks[sheet_List]:=
	Transpose/@Partition[#,7]&@Transpose@sheet

(*parse each block, retaining only entries with numeric content*)
parseBlock[block_?validBlockQ]:=With[
	{sampleInfo = parseFilename@block[[2,1]],
	data=ResourceFunction["DatasetWithHeaders"]@ block[[5;;,All]]},
	data[Select[NumericQ[#Area]&],Prepend[sampleInfo]]
]
(*if test fails (because of empty block of data, then don't return anything*)
parseBlock[_]:=Nothing

parseSheet[sheetContents_List, sheetName_?weekSheetQ]:=With[
	{data = Join @@ parseBlock/@ divideSheetIntoBlocks[sheetContents],
	weekInfo = parseWeek[sheetName]},
	data[All, Prepend[weekInfo]]]

(*if sheet name is not a valid week, then don't process it*)
parseSheet[_,_]:=Nothing 

weekSheetQ[sheetName_String]:=StringContainsQ["week",IgnoreCase->True]@sheetName
weekSheetQ[_]:=False (*handle being given a non-string gracefully*)

parseWeek[sheetName_String]:=With[
	{week = Interpreter["Number"]@First@StringCases[DigitCharacter..]@sheetName},
	<|"week"->week|>]

(* the main event*)
parseFile[file_?FileExistsQ]:=With[
	{sheetNames =Import[file,"Sheets"], 
	contents=Import[file]},
	Join@@MapThread[parseSheet,{contents,sheetNames}]
]

