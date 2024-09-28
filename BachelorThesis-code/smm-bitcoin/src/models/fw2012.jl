using Distributions
using Random

#=
Franke & Westerhoff (2012) model
Code written by Patrick Herb (2014), Blake LeBaron (2016), Brandeis University
=#
function fw2012(obs, burn, theta, seed, type, switch)
    # given parameters
    p_star = 0         # fundamental value of the market asset
    mu = 0.01          # market impact factor of demand
    v = 0.05           # flexibility parameter (TPA)
    beta = 1           # intensity of choice (DCA)

    # estimated parameters
    phi = 0     # aggressiveness of fundamentalists
    chi = 0     # aggressiveness of chartists
    eta = 0     # memory coefficient
    s_f = 0     # noise in fundamentalist demand
    s_c = 0     # noise in chartist demand
    alpha_0 = 0 # predisposition parameter
    alpha_n = 0 # herding parameter
    alpha_p = 0 # misalignment parameter
    alpha_w = 0 # wealth parameter

    # select switching
    if type == "W"
        phi = theta[1]
        chi = theta[2]
        eta = theta[3]
        s_f = theta[4]
        s_c = theta[5]
        alpha_w = theta[6]
    elseif type == "WP"
        phi = theta[1]
        chi = theta[2]
        eta = theta[3]
        s_f = theta[4]
        s_c = theta[5]
        alpha_0 = theta[6]
        alpha_w = theta[7]
    elseif type == "WHP"
        phi = theta[1]
        chi = theta[2]
        eta = theta[3]
        s_f = theta[4]
        s_c = theta[5]
        alpha_0 = theta[6]
        alpha_n = theta[7]
        alpha_w = theta[8]
    elseif type == "HPM"
        phi = theta[1]
        chi = theta[2]
        s_f = theta[3]
        s_c = theta[4]
        alpha_0 = theta[5]
        alpha_n = theta[6]
        alpha_p = theta[7]
    end

    # simple calculations
    total_day = obs+burn+1

    # data structures
    p = zeros(total_day)     # asset price
    a = zeros(total_day)     # switching parameter

    d_f = zeros(total_day)   # demand of fundamentalists
    d_c = zeros(total_day)   # demand of chartists
    n_f = zeros(total_day) .+ 0.5 # fraction of fundamentalists
    n_c = zeros(total_day) .+ 0.5 # fraction of chartists
    w_f = zeros(total_day)   # wealth of fundamentalists
    w_c = zeros(total_day)   # wealth of chartists

    sch_f = rand(MersenneTwister(seed), Normal(0, s_f^2/10), total_day) # fundamentalist price shock
    sch_c = rand(MersenneTwister(seed), Normal(0, s_c^2/10), total_day) # chartist price shock

    # FW2012 algorithm
    for t in 3:total_day-1
        # portfolio performance
        g_f = (exp(p[t]) - exp(p[t-1]))*d_f[t-2]
        g_c = (exp(p[t]) - exp(p[t-1]))*d_c[t-2]

        # summarize peformance over time
        w_f[t] = eta*w_f[t-1] + (1-eta)*g_f
        w_c[t] = eta*w_c[t-1] + (1-eta)*g_c

        if switch == "DCA"      # discrete choice approach switching
            # type fractions
            n_f[t] = 1 / (1 + exp(-beta*a[t-1]))
            n_c[t] = 1 - n_f[t]
        elseif switch == "TPA"   # transition probabilities approach switching
            # transition probabilities
            pi_cf = min(1, v*exp(a[t-1]))
            pi_fc = min(1, v*exp(-a[t-1]))

            # type fractions
            n_f[t] = n_f[t-1] + n_c[t-1]*pi_cf - n_f[t-1]*pi_fc
            n_c[t] = 1 - n_f[t]
        end

        # The a(t) dynamic is set up to handle several models
        a[t] =  alpha_0 + alpha_n*(n_f[t] - n_c[t]) + alpha_p*(p[t] - p_star)^2 + alpha_w*(w_f[t] - w_c[t])
        
        # demands
        d_f[t] = phi*(p_star - p[t]) + sch_f[t]
        d_c[t] = chi*(p[t] - p[t-1]) + sch_c[t]

        # pricing
        p[t+1] = p[t] + mu*(n_f[t]*d_f[t] + n_c[t]*d_c[t])


    end

    # discard burn-in period
    p = p[(burn+1):total_day]

    # calculate returns -> output series of FW returns
    ret = p[2:(obs+1)]-p[1:obs]

    return ret
end

#=
Franke & Westerhoff (2012) model
DCA switching, wealth
=#
function fw2012wdca(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "W", "DCA")
end

#=
Franke & Westerhoff (2012) model
DCA switching, wealth + predisposition
=#
function fw2012wpdca(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "WP", "DCA")
end

#=
Franke & Westerhoff (2012) model
DCA switching, wealth + herding+ predisposition
=#
function fw2012whpdca(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "WHP", "DCA")
end

#=
Franke & Westerhoff (2012) model
DCA switching, wealth + herding+ predisposition
=#
function fw2012whptpa(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "WHP", "TPA")
end

#=
Franke & Westerhoff (2012) model
DCA switching, herding + predisposition + misalignment
=#
function fw2012hpmdca(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "HPM", "DCA")
end

#=
Franke & Westerhoff (2012) model
TPA switching, wealth
=#
function fw2012wtpa(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "W", "TPA")
end

#=
Franke & Westerhoff (2012) model
TPA switching, wealth + predisposition
=#
function fw2012wptpa(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "WP", "TPA")
end

#=
Franke & Westerhoff (2012) model
TPA switching, herding + predisposition + misalignment
=#
function fw2012hpmtpa(obs, burn, theta, seed)
    return fw2012(obs, burn, theta, seed, "HPM", "TPA")
end

