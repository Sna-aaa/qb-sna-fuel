Config = {}


Config.JerryCanCost = 100
Config.JerryCanCapacity = 25

Config.LiterPrice = 1.7
Config.KwPrice = 0.3

Config.RopeLength = 5.0
Config.RopeMaxLength = 30.0

Config.PumpModels = {
    [-2007231801] = {z = 2.3},
    [1339433404] = {z = 2.3},
    [1694452750] = {z = 2.3},
    [1933174915] = {z = 2.3},
    [-462817101] = {z = 1.8},
    [-469694731] = {z = 1.6},
    [-164877493] = {z = 1.6},
    [1467552538] = {z = 1.6, electric = true},       --Tesla supercharger
}

Config.DefaultTankSize = 70.0

Config.TankSizes = {
    ["tug"] = 1000,
    ["winky"] = 50,
}

Config.FuelCaps = {
    ["kamacho"] = {-0.0, 0.55, 0.8},
    ["winky"] = {-0.30, 0.25, 0.65},
}

Config.ElectricVehicles = {
    ["cyclone"] = true,
    ["cyclone2"] = true,
    ["dilettante"] = true,
    ["iwagen"] = true,
    ["imorgon"] = true,
    ["khamelion"] = true,
    ["neon"] = true,
    ["omnisegt"] = true,
    ["raiden"] = true,
    ["surge"] = true,
    ["tezeract"] = true,
    ["virtue"] = true,
    ["voltic"] = true,
}

Config.TimeForCompleteCharge = 40          --Time in minutes for a complete charge in garage for electric vehicles

-- Class multipliers. If you want SUVs to use less fuel, you can change it to anything under 1.0, and vise versa.
Config.ClassFuelUsage = {
    [0] = 1.0, -- Compacts
    [1] = 1.0, -- Sedans
    [2] = 1.0, -- SUVs
    [3] = 1.0, -- Coupes
    [4] = 1.0, -- Muscle
    [5] = 1.0, -- Sports Classics
    [6] = 1.0, -- Sports
    [7] = 1.0, -- Super
    [8] = 1.0, -- Motorcycles
    [9] = 1.0, -- Off-road
    [10] = 1.0, -- Industrial
    [11] = 1.0, -- Utility
    [12] = 1.0, -- Vans
    [13] = 0.0, -- Cycles
    [14] = 1.0, -- Boats
    [15] = 1.0, -- Helicopters
    [16] = 1.0, -- Planes
    [17] = 1.0, -- Service
    [18] = 1.0, -- Emergency
    [19] = 1.0, -- Military
    [20] = 1.0, -- Commercial
    [21] = 0.0 -- Trains
}

-- Model multiplier, if you want any specific model to use more or less fuel, you can change it here
Config.ModelFuelUsage = {
    ["tug"] = 0.1,
    ["winky"] = 1.0,
}

-- Blacklist certain vehicles. Use names. https://wiki.gtanet.work/index.php?title=Vehicle_Models
Config.Blacklist = {
	["airtug"] = true,
    ["caddy"] = true,
    ["caddy2"] = true,
    ["caddy3"] = true,
}

-- The left part is at percentage RPM, and the right is how much fuel (divided by 10) you want to remove from the tank every second
Config.FuelUsage = {
    [1.0] = 1.4,
    [0.9] = 1.2,
    [0.8] = 1.0,
    [0.7] = 0.9,
    [0.6] = 0.8,
    [0.5] = 0.7,
    [0.4] = 0.5,
    [0.3] = 0.4,
    [0.2] = 0.2,
    [0.1] = 0.1,
    [0.0] = 0.0
}

-- Same for electric vehicles
Config.KwUsage = {
    [1.0] = 1.4,
    [0.9] = 1.2,
    [0.8] = 1.0,
    [0.7] = 0.9,
    [0.6] = 0.8,
    [0.5] = 0.7,
    [0.4] = 0.5,
    [0.3] = 0.4,
    [0.2] = 0.001,
    [0.1] = 0.001,
    [0.0] = 0.0
}

Config.GasStations = {
    vector3(49.4187, 2778.793, 58.043), 
    vector3(263.894, 2606.463, 44.983),
    vector3(1039.958, 2671.134, 39.550), 
    vector3(1207.260, 2660.175, 37.899),
    vector3(2539.685, 2594.192, 37.944), 
    vector3(2679.858, 3263.946, 55.240),
    vector3(2005.055, 3773.887, 32.403), 
    vector3(1687.156, 4929.392, 42.078),
    vector3(1701.314, 6416.028, 32.763), 
    vector3(179.857, 6602.839, 31.868),
    vector3(-94.4619, 6419.594, 31.489), 
    vector3(-2554.996, 2334.40, 33.078),
    vector3(-1800.375, 803.661, 138.651), 
    vector3(-1437.622, -276.747, 46.207),
    vector3(-2096.243, -320.286, 13.168), 
    vector3(-724.619, -935.1631, 19.213),
    vector3(-526.019, -1211.003, 18.184), 
    vector3(-70.2148, -1761.792, 29.534),
    vector3(265.648, -1261.309, 29.292), 
    vector3(819.653, -1028.846, 26.403),
    vector3(1208.951, -1402.567, 35.224), 
    vector3(1181.381, -330.847, 69.316),
    vector3(620.843, 269.100, 103.089), 
    vector3(2581.321, 362.039, 108.468),
    vector3(176.631, -1562.025, 29.263), 
    vector3(176.631, -1562.025, 29.263),
    vector3(-319.292, -1471.715, 30.549), 
    vector3(-66.48, -2532.57, 6.14),
    vector3(1784.324, 3330.55, 41.253),
    -- UNCOMMENT THE LINE BELOW IF YOU USE GABZ OTTOS AUTO
    --[[vector3(806.42, -789.94, 26.31)]]
}

Config.SuperchargerStations = {
    vector3(153.4138, 6592.721, 30.8449),
    vector3(2697.205, 3277.662, 54.24057),
    vector3(-2534.736, 2345.22, 32.05991),
    vector3(645.1025, 280.3252, 102.1716),
    vector3(-729.0958, -911.1166, 18.01393),
}

Config.MaxDistance = 2.0 -- distance from pump to use it

Config.ActionKey = 38 -- Key binds can be found here https://docs.fivem.net/docs/game-references/controls/

Config.DrawTextLocation = 'left' -- [left or right]
Config.Texts3d = true               --Texts 3D that shows the fuel cap (can be ms hungry, but only when refill/charge)

-- What keys are disabled while you're fueling with jerrycan.
Config.DisableKeys = {0, 22, 23, 24, 29, 30, 31, 37, 44, 56, 82, 140, 166, 167, 168, 170, 288, 289, 311, 323}

-- Fuel decor - No need to change this, just leave it.
Config.FuelDecor = "_FUEL_LEVEL"
