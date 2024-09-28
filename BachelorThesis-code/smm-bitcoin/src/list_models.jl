using LaTeXStrings

include("fcn_watson.jl")
include(modelsdir("fw2012.jl"))


MODELS = Dict("fw2012wdca" => fw2012wdca,
			  "fw2012wpdca" => fw2012wpdca,
			  "fw2012whpdca" => fw2012whpdca,
              "fw2012whptpa" => fw2012whptpa,
              "fw2012hpmdca" => fw2012hpmdca,
			  "fw2012wtpa" => fw2012wtpa,
			  "fw2012wptpa" => fw2012wptpa,
			  "fw2012hpmtpa" => fw2012hpmtpa)

BENCH = Dict("fw9" =>   [0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0])

FW2012HPM = Dict("cali" => Dict("fw2016" =>     [0.198, 2.263, 0.782, 1.851, -0.155, 1.299, 12.648],
                                "pl2021" =>     [0.12,  1.5,   0.758, 2.087, -0.327, 1.79,  18.43],
                                "zk2022" =>     [0.010, 0.767,   0.870, 4.21, 0.022, 1.74,  24.32],
                                "fw2012dca" =>  [0.12,  1.5,   0.758, 2.087, -0.327, 1.79,  18.43],
                                "fw2012tpa" =>  [0.18,  2.3,   0.790, 1.900, -0.161, 1.30,  12.50]),
            	 "cons" => Dict("fw2016" =>     [(0.0, 1.0),   (0.0, 3.0), (0.0, 1.0),      (0.0, 3.0),     (-1.0, 1.0),    (0.0, 2.0),     (0.0, 15.0)],
                                "pl2021" =>     [(0.0, 4.0),   (0.0, 4.0), (0.0, 1.25),     (0.0, 5.0),     (-1.0, 1.0),    (0.0, 2.0),     (0.0, 20.0)],
                                "zk2022" =>     [(0.0, 0.1),   (0.0, 4.0), (0.5, 1.0),      (2.0, 6.0),     (-0.5, 0.5),    (1.0, 4.0),     (5.0, 35.0)],
                                "hpmbtc" =>     [(0.0, 10.0),  (0.0, 5.0), (0.0, 3.5),      (0.0, 4.0),     (-12.0, 6.0),   (0.0, 8.0),     (40.0, 200.0)]),
                 "gnam" => [L"\phi", L"\chi", L"\sigma_f", L"\sigma_c", L"\alpha_0", L"\alpha_n", L"\alpha_p"],
                 "gdim" => (3, 3),
                 "gord" => [1, 2, 8, 3, 4, 9, 5, 6, 7])

FW2012W = Dict("cali" => Dict("fw2012dca" => [1.0, 1.20, 0.991, 0.681, 1.724, 1580],
                              "fw2012tpa" => [1.15, 0.81, 0.987, 0.715, 1.528, 1041]),
               "cons" => Dict("wbtc"  =>  [(0.0, 10.0),  (0.0, 5.0), (0.8, 1.0),  (0.0, 3.5),   (0.0, 4.0),     (200, 3200)]),
               "gnam" => [L"\phi", L"\chi", L"\eta", L"\sigma_f", L"\sigma_c", L"\alpha_w"],
               "gdim" => (3, 3),
               "gord" => [1, 2, 3, 4, 5, 6, 7, 8 ,9])

FW2012WP = Dict("cali" => Dict("fw2012dca" => [1.0, 0.90, 0.987, 0.752, 1.726,  2.100, 2668],
                               "fw2012tpa" => [1.0, 0.83, 0.987, 0.736, 1.636,  0.376, 1078]),
                "cons" => Dict("wpbtc"  =>  [(0.0, 10.0),(0.0, 5.0), (0.8, 1.0),  (0.0, 3.5),   (0.0, 4.0),     (-12,6),        (200, 3200)]),
                "gnam" => [L"\phi", L"\chi", L"\eta", L"\sigma_f", L"\sigma_c", L"\alpha_0", L"\alpha_w"],
                "gdim" => (3, 3),
                "gord" => [1, 2, 3, 4, 5, 7, 6, 8, 9])

FW2012WHP = Dict("cali" => Dict("fw2012dca" => [1.0, 0.90, 0.987, 0.741, 1.705, 2.100, 1.28, 2668]),
                "cons" => Dict("whpbtc" =>      [(0.0, 10.0), (0.0, 5.0), (0.8, 1.0),  (0.0, 3.5),   (0.0, 4.0), (-12.0, 6.0),  (0.0, 8.0),    (200, 3200)]),
                "gnam" => [L"\phi", L"\chi", L"\eta", L"\sigma_f", L"\sigma_c", L"\alpha_0", L"\alpha_n", L"\alpha_w"],
                "gdim" => (3, 3),
                "gord" => [1, 2, 3, 4, 5, 8, 6, 7, 9])


MODICT = Dict("fw2012wdca" => FW2012W,
			  "fw2012wpdca" => FW2012WP,
			  "fw2012whpdca" => FW2012WHP,
              "fw2012whptpa" => FW2012WHP,
              "fw2012hpmdca" => FW2012HPM,
			  "fw2012wtpa" => FW2012W,
			  "fw2012wptpa" => FW2012WP,
			  "fw2012hpmtpa" => FW2012HPM)

function get_model_cali(mod_set)
    return MODICT[mod_set["model"]]["cali"][mod_set["cali"]]
end

function get_model_cons(mod_set)
    return MODICT[mod_set["model"]]["cons"][mod_set["cons"]]
end

function get_model_gnam(mod_set)
    return MODICT[mod_set["model"]]["gnam"]
end

function get_model_gdim(mod_set)
    return MODICT[mod_set["model"]]["gdim"]
end

function get_model_gord(mod_set)
    return MODICT[mod_set["model"]]["gord"]
end
