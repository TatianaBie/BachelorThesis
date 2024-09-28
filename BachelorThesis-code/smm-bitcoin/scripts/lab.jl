# DrWatson project
using DrWatson, Pkg
@quickactivate "SMM"
Pkg.instantiate()

include(srcdir("fcn_report.jl"))

folder = "fw2012wtpa_fw9_fw2012dca_wbtc_rep1_obs6750_burn200_inits1_sim1_iter1_fw2012_blocksize250_bootsize5000_blockcount1000_databitcoin_log"
mod_set  = foldername_mod_set_retrieve(folder)

results = load_results(folder, "set")

println(results)

plot_histogram(results, mod_set, 1, folder)

theta_l=theta_length(mod_set["model"])

theta_l=theta_length(mod_set["model"])
dgts=3

println(folder)
for i = 1:theta_l
  println(i,
  ": mean: ", lpad(round(mean(results[1][1][i,:]), digits=3), dgts+3),
  ", median: ", lpad(round(median(results[1][1][i,:]), digits=dgts), dgts+3),
  ", std: ", lpad(round(std(results[1][1][i,:]), digits=dgts), dgts+3),
  ", q025: ", lpad(round(quantile(results[1][1][i,:], 0.025), digits=dgts), dgts+3),
  ", q975: ", lpad(round(quantile(results[1][1][i,:], 0.975), digits=dgts), dgts+3)
  )
end

println("J mean: ", lpad(round(mean(results[1][3][:]), digits=3), dgts+3), 
      ", J median: ", lpad(round(median(results[1][3][:]), digits=dgts), dgts+3),
      ", J std: ", lpad(round(std(results[1][3][:]), digits=dgts), dgts+3),
      ", J q025: ", lpad(round(quantile(results[1][3][:], 0.025), digits=dgts), dgts+3),
      ", J q075: ", lpad(round(quantile(results[1][3][:], 0.975), digits=dgts), dgts+3)
      )
