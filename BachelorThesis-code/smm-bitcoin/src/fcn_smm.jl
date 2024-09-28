@everywhere include("fcn_moments.jl")
@everywhere include("fcn_results.jl")
include("list_models.jl")

"""
    smm(data::Array{Float64,2}, setup, mom_sel, seedpart)

Produce SMM estimation results for a matrix of observations.
"""
function smm(data::Array{Float64,2}, setup, mom_sel, seedpart)
    
    par_cnt = length(get_model_cali(setup["mod"])) # number of parameters
    rep_cnt = size(data)[2] # number of repetitions

    results_par = SharedArray{Float64}(par_cnt, rep_cnt) # shared array for resulting parameters to be stored in
    results_j = SharedArray{Float64}(1, rep_cnt) # shared array for resulting parameters to be stored in

    @sync @distributed for i in 1:rep_cnt
        Random.seed!(10000*i+seedpart)
        # optimize the model function
        results_par[:,i], results_j[:,i] = gen_results(data[:,i], setup, mom_sel)
        println("Repetition: ", i, ", j-function value:",results_j[:,i], ", parameters:", round.(results_par[:,i], digits=3))
    end

    return (Array(results_par), mom_sel, results_j)
    
end
