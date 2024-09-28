using LinearAlgebra
using Distributions
using Random

include("fcn_watson.jl")
include("fcn_moments.jl")
include("fcn_data.jl")

function gen_weights(setup, data, mom_sel, theta=nothing)
    if setup["wgt"]["method"] == "fw2012"
        weights = fw2012_weights(data, setup["wgt"]["bootsize"], mom_sel)
    else
        flushln("The chosen method of computing weighting matrix is unknown.")
    end
    return weights
end


#=
Franke & Westerhoff (2012) weighting matrix. Blocks of 250 observations for
short moments, blocks of 750 observations for long moments.
=#
function fw2012_weights(data, bootsize, mom_sel)
    moments_bt = zeros(sum(mom_sel), bootsize)

    blockcount_250 = floor(Int, length(data)/250) # non-overlapping blocks of 250 observations
    blockcount_750 = floor(Int, length(data)/750) # non-overlapping blocks of 750 observations

    for i in 1:bootsize
        init_250 = rand(MersenneTwister(1000000+i), DiscreteUniform(0, blockcount_250-1), blockcount_250)
        init_750 = rand(MersenneTwister(1000000+i), DiscreteUniform(0, blockcount_750-1), blockcount_750)

        cur_data_250 = Float64[]
        cur_data_750 = Float64[]

        for j in init_250
            append!(cur_data_250, data[j*250+1:j*250+250])
        end

        for j in init_750
            append!(cur_data_750, data[j*750+1:j*750+750])
        end

        moments_bt[:,i] = gen_moments_sel(cur_data_250, mom_sel, cur_data_750)
    end
    return inv(cov(transpose(moments_bt)))
end


