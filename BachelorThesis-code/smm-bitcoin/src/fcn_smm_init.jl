using JLD
using InvertedIndices
using DelimitedFiles

include("fcn_smm.jl")
include("fcn_data.jl")
include("fcn_report.jl")
include("fcn_watson.jl")
include("list_models.jl")

"""
    smm_init(setup)

Prepare dataset and initialize selected estimation procedure.
"""
function smm_init(setup)
    if isnothing(setup["smm"]["emp"])
        data = zeros(setup["mod"]["obs"], setup["smm"]["rep"]) # pseudo-empirical dataset structure
        model_cali = get_model_cali(setup["mod"])

        # produce a pseudo-empirical dataset
        for i in 1:setup["smm"]["rep"]
            data[:,i] = gen_data(setup["mod"]["model"], setup["mod"]["obs"], setup["mod"]["burn"], model_cali, 100000+i)
        end
    else
        emp_series = JLD.load(datadir(setup["smm"]["emp"]), "data") # load vector of empirical observations from JLD file

        data = repeat(emp_series, 1, setup["smm"]["rep"])
    end

    results = []

    foldername = make_foldername(setup["ml"], setup["mod"], setup["opt"], setup["wgt"])

    if isnothing(setup["ml"]["bench"])
        mom_sel = setup["ml"]["set"]
    else
        mom_sel = BENCH[setup["ml"]["bench"]]
    end

    flushln("Producing results for:\n$mom_sel.")

    res = smm(data, setup, mom_sel, length(results))
    
    push!(results, res)

    save_results(results, foldername, 0, "set")

    filepath = joinpath("results/$foldername", "j-values.txt") # use joinpath() to combine the folder path and filename
    writedlm(filepath, results[1][3], ',')

    save_output(foldername, results, theta_l)
    
    return results

    """
    theta_l=theta_length(mod_set["model"])
    save_output(foldername, results, theta_l)

    filepath = joinpath("results/$foldername", "j-values.txt") # use joinpath() to combine the folder path and filename
    writedlm(filepath, results[1][3], ',')

    return results, clean_results
    """
end
