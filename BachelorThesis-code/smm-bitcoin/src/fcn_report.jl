using JLD, Plots.PlotMeasures, StatsPlots

include("fcn_watson.jl")
include("fcn_data.jl")
include("list_models.jl")

###############
# FOLDERNAMES #
###############

# concatenate settings into results foldername
function make_foldername(ml_set, mod_set, opt_set, wgt_set)
    alg = ml_set["method"]
    if alg == "sms" && !isnothing(ml_set["bench"])
        alg = ml_set["bench"]
    end

    foldername = string(mod_set["model"], "_",
                        alg, "_",
                        mod_set["cali"], "_",
                        mod_set["cons"], "_",
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
                        "data", smm_set["emp"][begin:end-4])

    return foldername
end

# retrieve model settings from foldername
function foldername_mod_set_retrieve(foldername)
    foldername_split = split(foldername, "_")

    mod_set = Dict("model" => foldername_split[1],
                   "cali" => foldername_split[3],
                   "cons" => foldername_split[4])

    return mod_set
end

# replace algorithm string in foldername for an alternative
function foldername_alg_replace(foldername, newalg)
    foldername_split = split(foldername, "_")
    foldername_split[2] = newalg

    return join(foldername_split, "_")
end

###########
# RESULTS #
###########

# save results to the "results/" folder
function save_results(results, foldername, idx, filename)
    cons = get_model_cons(mod_set)
    for i in eachindex(results)
        save(resultsdir(foldername, "$filename-$(idx+i).jld"),
             "data", results[i][1],
             "model", results[i][2],
             "j-function", results[i][3])
    end
end

# load results from the "results/" folder
function load_results(foldername, filename)
    folder_sets = [SubString(x, 1, 3) for x in readdir(resultsdir(foldername))]
    set_count = sum([x == "set" for x in folder_sets])
    results = []

    for i in 1:set_count
        content = load(resultsdir(foldername, "$filename-1.jld"))
        push!(results, (content["data"], content["model"], content["j-function"]))
    end

    return results
end

# plot histogram of SMM results
function plot_histogram(results, mod_set, i, folder; name=nothing)
    res = results[i][1]
    filename = isnothing(name) ? "set$(i)_$(folder)_.pdf" : "$(name)_$(folder).pdf"

    cali = get_model_cali(mod_set)
    cons = get_model_cons(mod_set)
    gnam = get_model_gnam(mod_set)
    gdim = get_model_gdim(mod_set)
    gord = get_model_gord(mod_set)

    subplot_tot = gdim[1] * gdim[2]
    plots = Vector{Plots.Plot{Plots.GRBackend}}(undef, subplot_tot)

    for i = eachindex(cali)
        res_par = res[i,:]
        plots[i] = density(res_par,
                           legend = :none,
                           title = gnam[i],
                           color = :black,
                           framestyle = :border,
                           xlims = cons[i],
                           xtickfont = font(6),
                           ytickfont = font(6))
        plots[i] = vline!([cali[i]], color = :red)
        plots[i] = vline!([mean(res_par)], color = :black)
        plots[i] = vline!([quantile(res_par, 0.025),
                           quantile(res_par, 0.975)],
                          color = :black, line = :dash)
    end

    for i = (length(cali)+1):subplot_tot
        plots[i] = plot(border = :none)
    end

    graph_dims = (gdim[2]*200, gdim[1]*105)
    plot_res = get_resulting_plot(plots, gdim, graph_dims, gord)

    savefig(plot_res, plotsdir(filename))
end

function plot_model_text(mod_set, obs, burn, type; seed=1, vline=nothing)
    filename = "$(mod_set["model"])_$(type).pdf"
    ylab = latexstring(type)

    cali = get_model_cali(mod_set)
    data = gen_data(mod_set["model"], obs, burn, cali, seed)

    p = plot(data,
             color=:black,
             legend=:none,
             xlab=L"time",
             ylab=ylab,
             size=(500,200))

    if !isnothing(vline)
        vline!([vline], color=:black, line=:dash)
    end

    savefig(p, plotsdir(filename))
end

###############
# PLOTS UTILS #
###############

function get_resulting_plot(p, l, s, o)
    total = length(p)

    if total == 1
        result = plot(p[o[1]],
                      layout=l, size=s, right_margin=2mm)
    elseif total == 2
        result = plot(p[o[1]], p[o[2]],
                      layout=l, size=s)
    elseif total == 3
        result = plot(p[o[1]], p[o[2]], p[o[3]],
                      layout=l, size=s)
    elseif total == 6
        result = plot(p[o[1]], p[o[2]], p[o[3]], p[o[4]], p[o[5]], p[o[6]],
                      layout=l, size=s)
    elseif total == 9
        result = plot(p[o[1]], p[o[2]], p[o[3]], p[o[4]], p[o[5]], p[o[6]], p[o[7]], p[o[8]], p[o[9]],
                      layout=l, size=s)
    elseif total == 12
        result = plot(p[o[1]], p[o[2]], p[o[3]], p[o[4]], p[o[5]], p[o[6]], p[o[7]], p[o[8]], p[o[9]], p[o[10]], p[o[11]], p[o[12]],
                      layout=l, size=s)
    elseif total == 15
        result = plot(p[o[1]], p[o[2]], p[o[3]], p[o[4]], p[o[5]], p[o[6]], p[o[7]], p[o[8]], p[o[9]], p[o[10]], p[o[11]], p[o[12]], p[o[13]], p[o[14]], p[o[15]],
                      layout=l, size=s)
    elseif total == 18
        result = plot(p[o[1]], p[o[2]], p[o[3]], p[o[4]], p[o[5]], p[o[6]], p[o[7]], p[o[8]], p[o[9]], p[o[10]], p[o[11]], p[o[12]], p[o[13]], p[o[14]], p[o[15]], p[o[16]], p[o[17]], p[o[18]],
                      layout=l, size=s)
    else
        println("The generated plot size is undefined in get_resulting_plot().")
    end

    return result
end

function theta_length(model)
    if model=="fw2012whpdca"
        return 8
    elseif model=="fw2012hpmdca"
        return 7
    elseif model=="fw2012hpmtpa"
        return 7
    elseif model=="fw2012wdca"
        return 6
    elseif model=="fw2012wtpa"
        return 6  
    elseif model=="fw2012wpdca"
        return 7
    elseif model=="fw2012wptpa"
        return 7 
    elseif model=="fw2012whptpa"
        return 8 
    end
end

function save_output(foldername, results, theta_l, dgts=3)

    # specify the path and filename for the output file
    output_path = "results/$foldername/results_output.txt"

    # open the file for writing, overwriting any existing content
    output_file = open(output_path, "w")

    println(output_file, foldername)

    println(output_file)

    println(output_file, results)

    println(output_file)

    # loop through the results and write each line to the file
    for i = 1:theta_l
        println(output_file, i,
            ": mean: ", lpad(round(mean(results[1][1][i,:]), digits=dgts), dgts+3),
            ", median: ", lpad(round(median(results[1][1][i,:]), digits=dgts), dgts+3),
            ", std: ", lpad(round(std(results[1][1][i,:]), digits=dgts), dgts+3),
            ", q025: ", lpad(round(quantile(results[1][1][i,:], 0.025), digits=dgts), dgts+3),
            ", q975: ", lpad(round(quantile(results[1][1][i,:], 0.975), digits=dgts), dgts+3)
            )
    end

    println(output_file, "J mean: ", lpad(round(mean(results[1][3][:]), digits=dgts), dgts+3), 
                ", J median: ", lpad(round(median(results[1][3][:]), digits=dgts), dgts+3),
                ", J std: ", lpad(round(std(results[1][3][:]), digits=dgts), dgts+3),
                ", J q025: ", lpad(round(quantile(results[1][3][:], 0.025), digits=dgts), dgts+3),
                ", J q075: ", lpad(round(quantile(results[1][3][:], 0.975), digits=dgts), dgts+3)
                )

    # close the file
    close(output_file)
end




