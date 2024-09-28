using StatsBase

function gen_moments_sel(data, mom_sel, data_long_moms=nothing)
    moments = zeros(22)
    moments_sel = zeros(sum(mom_sel))

    acf = autocor(data, 0:3)

    absdata = abs.(data)
    absacf = autocor(absdata, 0:101)

    sqrdata = data.^2
    sqracf = autocor(sqrdata, 0:26)

    moments[1] = var(data) # variance of raw returns [CL]
    moments[2] = kurtosis(data)+3 # kurtosis of raw returns [CL]
    moments[3] = acf[2,1] # 1st lag autocorrelation of raw returns [FW,CL]
    moments[4] = acf[3,1] # 2nd lag autocorrelation of raw returns
    moments[5] = acf[4,1] # 3rd lag autocorrelation of raw returns

    moments[6] = mean(absdata) # mean of absolute returns [FW]
    moments[7] = hill(absdata, 2.5) # Hill estimator (2.5% of the right tail) of absolute returns
    moments[8] = hill(absdata, 5) # Hill estimator (5% of the right tail) of absolute returns [FW]

    moments[9] = mean(absacf[2:3,1]) # 1st lag autocorrelation of absolute returns [FW,CL]
    moments[10] = mean(absacf[5:7,1]) # 5th lag autocorrelation of absolute returns [FW,CL]
    moments[11] = mean(absacf[10:12,1]) # 10th lag autocorrelation of absolute returns [FW,CL]
    moments[12] = mean(absacf[15:17,1]) # 15th lag autocorrelation of absolute returns [CL]
    moments[13] = mean(absacf[20:22,1]) # 20th lag autocorrelation of absolute returns [CL]
    moments[14] = mean(absacf[25:27,1]) # 25th lag autocorrelation of absolute returns [FW,CL]
    moments[15] = mean(absacf[50:52,1]) # 50th lag autocorrelation of absolute returns [FW]
    moments[16] = mean(absacf[100:102,1]) # 100th lag autocorrelation of absolute returns [FW]

    moments[17] = mean(sqracf[2:3,1]) # 1st lag autocorrelation of squared returns [CL]
    moments[18] = mean(sqracf[5:7,1]) # 5th lag autocorrelation of squared returns [CL]
    moments[19] = mean(sqracf[10:12,1]) # 10th lag autocorrelation of squared returns [CL]
    moments[20] = mean(sqracf[15:17,1]) # 15th lag autocorrelation of squared returns [CL]
    moments[21] = mean(sqracf[20:22,1]) # 20th lag autocorrelation of squared returns [CL]
    moments[22] = mean(sqracf[25:27,1]) # 25th lag autocorrelation of squared returns [CL]

    if !isnothing(data_long_moms)
        absdata_long_moms = abs.(data_long_moms)
        absacf_long_moms = autocor(absdata_long_moms, 0:101)

        sqrdata_long_moms = data_long_moms.^2
        sqracf_long_moms = autocor(sqrdata_long_moms, 0:26)

        moments[11] = mean(absacf_long_moms[10:12,1]) # 10th lag autocorrelation of absolute returns [FW,CL]
        moments[12] = mean(absacf_long_moms[15:17,1]) # 15th lag autocorrelation of absolute returns [CL]
        moments[13] = mean(absacf_long_moms[20:22,1]) # 20th lag autocorrelation of absolute returns [CL]
        moments[14] = mean(absacf_long_moms[25:27,1]) # 25th lag autocorrelation of absolute returns [FW,CL]
        moments[15] = mean(absacf_long_moms[50:52,1]) # 50th lag autocorrelation of absolute returns [FW]
        moments[16] = mean(absacf_long_moms[100:102,1]) # 100th lag autocorrelation of absolute returns [FW]

        moments[19] = mean(sqracf_long_moms[10:12,1]) # 10th lag autocorrelation of squared returns [CL]
        moments[20] = mean(sqracf_long_moms[15:17,1]) # 15th lag autocorrelation of squared returns [CL]
        moments[21] = mean(sqracf_long_moms[20:22,1]) # 20th lag autocorrelation of squared returns [CL]
        moments[22] = mean(sqracf_long_moms[25:27,1]) # 25th lag autocorrelation of squared returns [CL]
    end

    wanted = findall(isone, mom_sel)
    for i in 1:sum(mom_sel)
        moments_sel[i] = moments[wanted[i]]
    end

    return(moments_sel)
end

function hill(data, pct)
    k = floor(Int, length(data)/100*pct)

    sorted = sort(data, rev=true)
    res = sorted[1:k]/sorted[k+1]

    return(((1/k)*sum(log.(res)))^-1)
end
