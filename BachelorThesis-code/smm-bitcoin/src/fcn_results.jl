using BlackBoxOptim

include("fcn_data.jl")
include("fcn_moments.jl")
include("fcn_weights.jl")
include("list_models.jl")

"""
    model_fcn(theta, setup, moments_emp, mom_sel, weights)

Calculate weighted differences between (pseudo-)empirical and simulated moments.
"""
function model_fcn(theta, setup, moments_emp, mom_sel, weights, data_sim_len)
    moments_sim = zeros(sum(mom_sel), setup["opt"]["sim"])

    for i in 1:setup["opt"]["sim"]
        data = gen_data(setup["mod"]["model"], data_sim_len, setup["mod"]["burn"], theta, i)
        # println("Data:", data)
        moments_sim[:,i] = gen_moments_sel(data, mom_sel)
        # println("moments_sim:", moments_sim)
        """
        if i==setup["opt"]["sim"]
            println("setup ", i)
        end
        """
    end

    moments_diff = mean(moments_sim, dims=2) - moments_emp
    
    obj = transpose(moments_diff)*weights*moments_diff
    # println("OBJ:", obj)
    return obj[1]
end

"""
    gen_results(data_emp::Array{Float64,1}, setup, mom_sel)

Produce SMM estimation results for a vector of observations.
"""
function gen_results(data::Array{Float64,1}, setup, mom_sel)
    iter = setup["opt"]["iter"]
    search_range = get_model_cons(setup["mod"])

    results_parm = zeros(length(search_range), setup["opt"]["inits"])
    results_j = zeros(setup["opt"]["inits"])
    weights = gen_weights(setup, data, mom_sel)
    
    moments_emp = gen_moments_sel(data, mom_sel)

    # println("moments_emp: ", moments_emp)


    for i in 1:setup["opt"]["inits"]
        optout = bboptimize(theta -> model_fcn(theta, setup, moments_emp, mom_sel, weights, length(data)*setup["smm"]["simfactor"]),
                            SearchRange = search_range,
                            Method = :adaptive_de_rand_1_bin_radiuslimited,
                            NumDimensions = length(search_range),
                            MaxFuncEvals = iter,
                            TraceMode = :silent)

        results_parm[:,i] = best_candidate(optout)
        results_j[i] = best_fitness(optout)
        # println("results_j[i]: ",results_j[i])
    end
    # println("Results_parm:$results_parm,\n results_j: $results_j")
    """
    println("size(results_parm):  ", size(results_parm))
    println("size(results_j)):  ", size(results_j))
    println("size(argmin(results_j)):  ", size(argmin(results_j)))
    println("results_parm[:, argmin(results_j)]", results_parm[:, argmin(results_j)])
    println("size: ", size(results_parm[:, argmin(results_j)]))
    """
    # println(argmin(results_j))
    return results_parm[:, argmin(results_j)], results_j
end
