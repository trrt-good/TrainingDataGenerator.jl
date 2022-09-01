using Random

function indexOf(character::Char, string::String)
    for (i, char) in enumerate(string)
        if char == character
            return i
        end
    end
    return nothing
end

function generateTrainingData()
    println("This program generates training data for linear regression type\nmachine learning models.\n")

    print("use config file (yes: y, no: n)? ")
    if (readline()[1] == 'y')
        if (isfile("trainingDataConfig.txt"))
            file = open("trainingDataConfig.txt", "r")
            lines = readlines(file)
            nInputs = tryparse(Int32, lines[1][1:(indexOf(':', lines[1])-1)])
            nOutputs = tryparse(Int32, lines[2][1:(indexOf(':', lines[2])-1)])
            nTrainingExamples = tryparse(Int32, lines[3][1:(indexOf(':', lines[3])-1)])
            inRanges = Array{Tuple{Float32,Float32},1}(undef, nInputs)
            inWeights = Array{Float32,2}(undef, nOutputs, nInputs)
            outVariance = Array{Float32,1}(undef, nOutputs)
            outRandType = Array{Char,1}(undef, nOutputs)
            for i in 5:2:4+2*nInputs
                setindex!(inRanges, (tryparse(Float32, lines[i][1:(indexOf(':', lines[i])-1)]), tryparse(Float32, lines[i+1][1:(indexOf(':', lines[i+1])-1)])), trunc(Int32, (i-5)/2)+1)
            end
            for i in 6+2*nInputs:5+(2+nOutputs)*nInputs
                nLine = i-6-2*nInputs
                setindex!(inWeights, tryparse(Float32, lines[i][1:(indexOf(':', lines[i])-1)]), trunc(Int32, nLine/nInputs) + 1, mod(nLine, nInputs) + 1)
            end
            for i in 7+(2+nOutputs)*nInputs:2:6+(2+nOutputs)*nInputs + 2*nOutputs
                index = trunc(Int32, (i-(7+(2+nOutputs)*nInputs))/2) +1
                setindex!(outVariance, tryparse(Float32, lines[i][1:(indexOf(':', lines[i])-1)]), index)
                setindex!(outRandType, lines[i+1][1], index)
            end
            fileName = lines[8+(2+nOutputs)*nInputs + 2*nOutputs][1:(indexOf(':', lines[8+(2+nOutputs)*nInputs + 2*nOutputs])-1)]
            format = string(lines[14][end])
        else
            println("ERROR: could not find file \"trainingDataConfig.txt\"")
        end
    else

        print("how many inputs should be generated for each training example?: ")
        nInputs = readline()
        while (isnothing(tryparse(Int32, nInputs)))
            print("please enter an integer number: ")
            nInputs = readline()
        end
        nInputs = parse(Int32, nInputs)

        print("how many outputs should be generated for each training example?: ")
        nOutputs = readline()
        while (isnothing(tryparse(Int32, nOutputs)))
            print("please enter an integer number: ")
            nOutputs = readline()
        end
        nOutputs = parse(Int32, nOutputs)

        print("how many training examples should be generated?: ")
        nTrainingExamples = readline()
        while (isnothing(tryparse(Int32, nTrainingExamples)))
            print("please enter an integer number: ")
            nTrainingExamples = readline()
        end
        nTrainingExamples = parse(Int32, nTrainingExamples)

        inRanges = Array{Tuple{Float32,Float32},1}(undef, nInputs)
        for i in 1:nInputs
            print("range for possible input values  $i:\n\tlower bound: ")
            answer = tryparse(Float32, readline())
            while (isnothing(answer))
                print("\tenter a valid number: ")
                answer = tryparse(Float32, readline())
            end
            print("\trange: ")
            answer1 = tryparse(Float32, readline())
            while (isnothing(answer1))
                print("\tenter a valid number: ")
                answer1 = tryparse(Float32, readline())
            end
            setindex!(inRanges, (answer, answer1), i)
        end

        inWeights = Array{Float32,2}(undef, nOutputs, nInputs)
        for i in 1:nOutputs
            for j in 1:nInputs
                print("Weight for input feature $j with relation to output $i: ")
                answer = tryparse(Float32, readline())
                while (isnothing(answer))
                    print("please enter a valid weight: ")
                    answer = tryparse(Float32, readline())
                end
                setindex!(inWeights, answer, i, j)
            end
        end

        outVariance = Array{Float32,1}(undef, nOutputs)
        outRandType = Array{Char,1}(undef, nOutputs)

        for i in 1:nOutputs
            println("Settings for output $i:")
            print("\tVariance: ")
            answer = tryparse(Float32, readline())
            while (isnothing(answer))
                print("\tenter a valid number: ")
                answer = tryparse(Float32, readline())
            end
            setindex!(outVariance, answer, i)

            print("\tRandomization type (normalDstr: n, randomDstr: r): ")
            answer = readline()
            while (answer[1] != 'n' && answer[1] != 'r')
                print("\tAnswer only \"n\" or \"r\" please: ")
                answer = readline()
            end
            setindex!(outRandType, answer[1], i)
        end

        print("Output file name (don't include file type extension): ")
        fileName = readline()

        print("Should the output be formatted? (yes: y, no: n) ")
        format = readline()
        while (format[1] != 'n' && format[1] != 'y')
                print("\tAnswer only \"n\" or \"y\" please: ")
                format = readline()
            if format == "y"
            end
        end

        print("Save settings as config file? (yes: y, no: n) ")
        if (readline()[1] == 'y')
            config = open("trainingDataConfig.txt", "w")

            println(config, "$nInputs: inputs per training example
$nOutputs: outputs per training example
$nTrainingExamples: number of training examples\n")

            for i in 1:nInputs
                lowerBound = inRanges[i][1]
                range = inRanges[i][2]
                println(config, "$lowerBound: lower bound for input $i
$range: range for input $i")
            end

            print(config, "\n")

            for i in 1:nOutputs
                for j in 1:nInputs
                    weight = inWeights[i, j]
                    println(config, "$weight: weight of input $j for output $i")
                end
            end

            print(config, "\n")

            for i in 1:nOutputs
                variance = outVariance[i] 
                println(config, "$variance: variance for output $i")
                randType = outRandType[i]
                println(config, "$randType: randomization type for output $i")
            end

            print(config, "\n")

            println(config, "$fileName: output file name")
            println(config, "format activated: $format")
            close(config)
        end
    end
    writeTrainingData(nInputs, nOutputs, nTrainingExamples, format, inWeights, inRanges, outVariance, outRandType, fileName)
end

function writeTrainingData(nInputs::Int32, nOutputs::Int32, nTrainingExamples::Int32, format::String, inWeights::Array, inRanges::Array, outVariance::Array, outRandType::Array, fileName::String)
    file = open("$fileName.txt", "w")
    for i in 1:nTrainingExamples
        r = rand(Float32, nInputs)
        randInputVector::Array = Array{Float32, 1}(undef, nInputs)
        for j in 1:nInputs
            randInputVector[j] = r[j]*inRanges[j][2] + inRanges[j][1]
        end
        outputs::Array = inWeights*randInputVector
        if format == "y"
            print(file, "$i. ", randInputVector, "\n")
            if outRandType == 'n'
                r = randn(nOutputs)
            else
                r = rand(Float32, nOutputs)
            outputs = outputs + (outVariance .* r .- outVariance/2)
            println(file, "   ", outputs, "\n ")
            end
        else
            print(file, randInputVector)
            if outRandType == 'n'
                r = randn(nOutputs)
            else
                r = rand(Float32, nOutputs)
            outputs = outputs + (outVariance .* r .- outVariance/2)
            println(file, outputs)
            end
        end
    end
    close(file)
end

generateTrainingData()
