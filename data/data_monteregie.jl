using SpeciesDistributionToolkit
const SDT = SpeciesDistributionToolkit
using CairoMakie

# Get the polygon to serve as a BB
pol = getpolygon(PolygonData(OpenStreetMap, Places), place="Montérégie")
bbox = SDT.boundingbox(pol; padding=0.5)

# Get the landcover classes
lc = SDMLayer{Float32}[SDMLayer(RasterData(EarthEnv, LandCover); layer=i, bbox...) for i in 1:12]

# Get the relevant UTM grid proj string
projstring = "EPSG:2031"

# Interpolate the first layers
interpolated = interpolate(lc[12]; dest=projstring)

# Get the correct grid size to have the same number of dimensions
xspan = interpolated.x[2] - interpolated.x[1]
yspan = interpolated.y[2] - interpolated.y[1]
patch_side = 1000.0
nsize = round.(Int64, (xspan / patch_side, yspan / patch_side))

# Interpolate all the layers
ilc = [interpolate(lc[i]; dest=projstring, newsize=nsize) for i in eachindex(lc)]

# Apply the mosaic operation
consensus = mosaic(argmax, ilc)

# Identify the first/last elements to have a full grid

imin = findmin(mapslices(findfirst, consensus.indices, dims=1))[2].I[2]
imax = findmax(mapslices(findlast, consensus.indices, dims=1))[2].I[2]
jmin = findmin(mapslices(findfirst, consensus.indices, dims=2))[2].I[1]
jmax = findmax(mapslices(findlast, consensus.indices, dims=2))[2].I[1]

# Show the final grid
heatmap(consensus.grid[jmax:jmin, imin:imax])

