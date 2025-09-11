module LandscapeMetrics

using TestItems
using Test
using StatsBase
import DelimitedFiles

# Patches, generic utilies, and overloads
include("types.jl")
export Landscape
export background
export foreground
export exteriorbackground, interiorbackground
export area, side

# Some demonstration data
include("demo.jl")
include("utilities/data.jl") # Montérégie

# Functions to identify the patches
include("utilities/patches.jl")
export Moore, VonNeumann
export patches!, patches

# Function to get the center of the cells (in metres)
include("utilities/cellcenters.jl")
export cellcenters

# Function to get the core areas
include("utilities/core.jl")

# Area and edge
include("area_and_edge/perimeter.jl")
export perimeter

include("area_and_edge/area.jl")
export totalarea
export area
export classarea

include("area_and_edge/percentage.jl")
export percentage

include("area_and_edge/largestpatch.jl")
export largestpatchindex

include("area_and_edge/radiusofgyration.jl")
export radiusofgyration

include("area_and_edge/totaledge.jl")
export totaledge

include("area_and_edge/edgedensity.jl")
export edgedensity

# Shape
include("shape/paratio.jl")
export paratio, perimeterarearatio
export shapeindex

include("shape/fractal.jl")
export fractaldimensionindex

include("shape/perimeterareafractal.jl")
export perimeterareafractal

end # module LandscapeMetrics

