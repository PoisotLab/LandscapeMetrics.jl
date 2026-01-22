module LandscapeMetrics

using TestItems
using Test
using StatsBase
import DelimitedFiles
using Random

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

#Function to get the contiguity value of the cells
include("utilities/contiguityvalue.jl")
export contiguityvalue
# Function to identify the minimum enclosing circle of a set of points
include("utilities/welzlalgorithm.jl")
export welzl_algorithm
export minimum_enclosing_circle
export Circle
export is_point_in_circle
export distance






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

# Shape
include("shape/paratio.jl")
export paratio, perimeterarearatio
export shapeindex

include("shape/fractal.jl")
export fractaldimensionindex

# Aggregation
include("aggregation/euclidiannearestneighbourdistance.jl")
export euclidian_nearest_neighbour
export euclidian_nearest_neighbour_by_class

include("aggregation/proximityindex.jl")
export proximity_index

include("aggregation/similarityindex.jl")
export similarity_index

include("aggregation/interspersionjuxtapositionindex.jl")  
export interspersion_juxtaposition_index

include("aggregation/percentageoflikeadjencies.jl")
export percentageoflikeadjacencies

include("aggregation/aggregationindex.jl")
export aggregationindex

include("aggregation/clumpinessindex.jl")
export clumpinessindex

include("aggregation/landscapeshapeindex.jl")
export landscapeshapeindex

end # module LandscapeMetrics

