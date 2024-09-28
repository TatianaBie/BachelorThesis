# paralell computing - co to znamena?
using Distributed, SharedArrays, Dates
addprocs(4) # number of CPU cores

# DrWatson project
# @everywhere using Pkg; Pkg.activate("."); Pkg.instantiate(); using DrWatson
# nacitavanie roznych packages
@everywhere using DrWatson, Pkg
@everywhere @quickactivate "SMM"
@everywhere Pkg.instantiate()

#=
Code written by Eric Zila & Jiri Kukacka (2023)
edited to version with eight submodels of Franke & Westerhoff (2012) by Tatiana Bielakova
=#

# nacitavanie pomocnych kodov 
include(srcdir("fcn_smm_init.jl"))
include(srcdir("fcn_report.jl"))

# machine learning setup ~ {options}
ml_set = Dict(
    "method" => "sms", # machine learning method ~ {"sms"}
    "bench" => "fw9",
    "set" => nothing,
) # moment set if "bench" == nothing

# simulated method of moments setup [default] ~ {options}
smm_set = Dict(
    "rep" => 10, # number of repetitions [96]
    "emp" => "bitcoin_log.jld", # source of empirical data ~ {nothing,"data_sp500.jld",...}
    "simfactor" => 1, # 
) # simulated series length factor [1]

# model setup [default] ~ {options}
mod_set = Dict(
    "model" => "fw2012hpmtpa", # model name
    "obs" => 6750, # number of observations [6750]
    "burn" => 200, # burn-in period length [200]
    "cali" => "fw2012tpa", # xmodel calibration
    "cons" => "hpmbtc" ,
) # search constraints

# optimisation setup [default]
opt_set = Dict(
    "inits" => 1, # number of initial points [1]
    "sim" => 10, # number of simulations [100]
    "iter" => 200,
) # number of iterations [4000]

# weighting matrix setup [default] ~ {options}
wgt_set = Dict(
    "method" => "fw2012", # approach to weighting matrix construction ~ {"eye","blockcount","fw2012","fw2012overlap","blocklong","blockavg","nw"}
    "blocksize" => 250, # block size for block-bootstrapped weighting matrix [250]
    "bootsize" => 5000, # repetitions for block-bootstrapped weighting matrix [5000]
    "blockcount" => 1000, 
) # number of pasted blocks for long block-bootstrapped weighting matrix [1000]

# full setup dictionary
setup = Dict(
    "ml" => ml_set, # machine learning setup
    "smm" => smm_set, # simulated method of moments setup
    "mod" => mod_set, # model setup
    "opt" => opt_set, # optimisation setup'§
    "wgt" => wgt_set,
) # weighting matrix setup

@time begin
    println(mod_set["model"], "_", mod_set["cali"],  
            "_", mod_set["cons"], "_", 
            "rep", smm_set["rep"], "_",
            "obs", mod_set["obs"], "_",
            "burn", mod_set["burn"], "_",
            "inits", opt_set["inits"], "_",
            "sim", opt_set["sim"], "_",
            "iter", opt_set["iter"], "_",
            wgt_set["method"], "_",
            "blocksize", wgt_set["blocksize"], "_",
            "bootsize", wgt_set["bootsize"], "_",
            "blockcount", wgt_set["blockcount"], "_",
            smm_set["emp"])
            
    results= smm_init(setup) # estimation initialization  
    println(results)

    theta_l=theta_length(mod_set["model"])
    dgts=3

    for i = 1:theta_l
        println(i,
        ": mean: ", lpad(round(mean(results[1][1][i,:]), digits=dgts), dgts+3),
        ", median: ", lpad(round(median(results[1][1][i,:]), digits=dgts), dgts+3),
        ", std: ", lpad(round(std(results[1][1][i,:]), digits=dgts), dgts+3),
        ", q025: ", lpad(round(quantile(results[1][1][i,:], 0.025), digits=dgts), dgts+3),
        ", q975: ", lpad(round(quantile(results[1][1][i,:], 0.975), digits=dgts), dgts+3)
        )
    end
    println("J mean: ", lpad(round(mean(results[1][3][:]), digits=dgts), dgts+3), 
            ", J median: ", lpad(round(median(results[1][3][:]), digits=dgts), dgts+3),
            ", J std: ", lpad(round(std(results[1][3][:]), digits=dgts), dgts+3),
            ", J q025: ", lpad(round(quantile(results[1][3][:], 0.025), digits=dgts), dgts+3),
            ", J q075: ", lpad(round(quantile(results[1][3][:], 0.975), digits=dgts), dgts+3)
            )
end


