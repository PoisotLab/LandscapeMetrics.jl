using SpeciesDistributionToolkit
const SDT = SpeciesDistributionToolkit
using CairoMakie

# Get the polygon to serve as a BB
pol = getpolygon(PolygonData(OpenStreetMap, Places), place="Val-David")
bbox = SDT.boundingbox(pol; padding=0.08)

lines(pol)

# Get the landcover classes
lc = convert(SDMLayer{Int64}, SDMLayer(RasterData(Copernicus, LandCover); layer="Classification", bbox...))
reinter = Vector{Int64}(indexin(lc, unique(lc)))
burnin!(lc, reinter)

heatmap(lc)

# Get the relevant UTM grid proj string
projstring = "EPSG:2031"

# Interpolate the first layers
interpolated = interpolate(lc; dest=projstring)

# Get the correct grid size to have the same number of dimensions
xspan = interpolated.x[2] - interpolated.x[1]
yspan = interpolated.y[2] - interpolated.y[1]
patch_side = 110.0
nsize = round.(Int64, (xspan / patch_side, yspan / patch_side))

# Interpolate all the layers
ilc = interpolate(lc; dest=projstring, newsize=nsize)
ilc = (x -> round(Int64, x)).(ilc)

ilc |> heatmap

# Identify the first/last elements to have a full grid

imin = findmin(mapslices(findfirst, ilc.indices, dims=1))[2].I[2]
imax = findmax(mapslices(findlast, ilc.indices, dims=1))[2].I[2]
jmin = findmin(mapslices(findfirst, ilc.indices, dims=2))[2].I[1]
jmax = findmax(mapslices(findlast, ilc.indices, dims=2))[2].I[1]

# Show the final grid
heatmap(permutedims(ilc.grid[jmax:jmin, imin:imax]); axis=(aspect=DataAspect(), ))

using DelimitedFiles
writedlm("data/granby.dat", ilc.grid[jmax:jmin, imin:imax])