using Pkg
Pkg.add("EzXML")
Pkg.add("TextAnalysis")
Pkg.add("Serialization")

using EzXML
using TextAnalysis
using Serialization

function main()
    #process all files in the 2019 directory
    files = readdir("2019/", join = true)
    name = []
    descriptions = []
    size = []

    #Extract content from files
    for i in files
        extractContent(i, name, descriptions, size)
    end

    #Process the text descriptions
    stringDocuments = []
    
    for i in descriptions 
        if !isnothing(i) 
          doc = StringDocument(i)
          push!(stringDocuments, doc)
        end
    end

    c = Corpus(stringDocuments)
    remove_case!(c)
    prepare!(c, strip_punctuation)
    stem!(c)
    update_lexicon!(c) 
   
    #Create a document term matrix 
    matrix = DocumentTermMatrix(c)
    cols = length(lexicon(c))
    rows = length(c)
    serialize("TermDocumentMatrix.jldata", c)
    println("Created and saved a DocumentTermMatrix $rows rows and $cols columns to TermDocumentMatrix.jldata")    
end

function extractContent(xmlfile, name, desc, size)
    try
        doc = readxml(xmlfile)
        n = findfirst("//BusinessName/BusinessNameLine1Txt/text()", doc)
        s = findfirst("//TotalEmployeeCnt/text()", doc)
        d = findfirst("//MissionDesc/text()", doc)
        if isnothing(d)
            d = findfirst("//Desc/text()", doc)
            if isnothing(d)
                d = findfirst("//Description/text()", doc)
            end
        end
        if !isnothing(n) && !isnothing(s) && !isnothing(d)
            push!(name, nodecontent(n)) 
            push!(desc, nodecontent(d))
            push!(size, nodecontent(s))
        end
    catch
    end
end   

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
