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

include("area_and_edge/edgedensity.jl")
export edgedensity

include("area_and_edge/totaledge.jl")
export totaledge

# Shape
include("shape/paratio.jl")
export paratio, perimeterarearatio
export shapeindex

include("shape/fractal.jl")
export fractaldimensionindex
export fractaldimension

include("shape/contiguityindex.jl")
export contiguityindex

include("shape/relatedcircumscribingcircle.jl")
export relatedcircumscribingcircleindex

# Core Area
include("core_area/corearea.jl")
export core_area
    
include("core_area/coreareaindex.jl")
export core_area_index

include("core_area/totalcorearea.jl")
export total_core_area

include("core_area/Ncore.jl")
export count_core_areas

include("core_area/coreareapercentage.jl")
export core_area_percentage

include("core_area/numberofdisjunctcorearea.jl")
export number_of_disjunct_core_areas

include("core_area/disjunctcoreareadensity.jl")
export disjunct_core_area_density

# Contrast
include("area_and_edge/contrast/contrastweightededgedensity.jl")
export contrast_weighted_edge_density

include("area_and_edge/contrast/edgecontrastindex.jl")
export edge_contrast_index

include("area_and_edge/contrast/totaledgecontrastindex.jl")
export total_edge_contrast_index

# Aggregation
include("aggregation/aggregationindex.jl")
export aggregationindex

include("aggregation/clumpinessindex.jl")
export clumpiness_index

include("aggregation/connectanceindex.jl")
export connectance_index

include("aggregation/effectivemeshsize.jl")
export effective_mesh_size

include("aggregation/euclidiannearestneighbourdistance.jl")
export euclidian_nearest_neighbour_distance

include("aggregation/interspersionjuxtapositionindex.jl")
export interspersion_juxtaposition_index

include("aggregation/landscapedivisionindex.jl")
export landscape_division_index

include("aggregation/landscapeshapeindex.jl")
export landscape_shape_index

include("aggregation/normalizedlandscapeindex.jl")
export normalized_landscape_index

include("aggregation/numberofpatches.jl")
export number_of_patches

include("aggregation/patchcohesionindex.jl")
export patch_cohesion_index

include("aggregation/patchdensity.jl")
export patch_density

include("aggregation/percentageoflikeadjencies.jl")
export percentageoflikeadjacencies

include("aggregation/proximityindex.jl")
export proximity_index

include("aggregation/similarityindex.jl")
export similarity_index

include("aggregation/splittingindex.jl")
export splitting_index

#Diversity
include("diversity/patchrichness.jl")
export patchrichness

include("diversity/shannondiversityindex.jl")
export shannondiversityindex
export shannonevennessindex

include("diversity/simpsondiversityindex.jl")
export simpsondiversityindex

include("diversity/relativepatchrichness.jl")
export relativepatchrichness

include("diversity/patchrichnessdensity.jl")
export patchrichnessdensity

end # module LandscapeMetrics

