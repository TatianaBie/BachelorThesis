using DrWatson

resultsdir(args...) = projectdir("results", args...)
benchdir(args...) = projectdir("results", "bench", args...)
modelsdir(args...) = projectdir("src", "models", args...)

"""
    flushln(line)

Print string directly to output file when using computational server.
"""
function flushln(line)
    println(line)
    flush(stdout)
end
