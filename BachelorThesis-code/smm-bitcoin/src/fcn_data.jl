include("list_models.jl")

# generate data based on a model
function gen_data(model, obs, burn, theta, seed)
    model = MODELS[model] # choose the desired model function
    data = model(obs, burn, theta, seed) # call the model function

    return data
end
