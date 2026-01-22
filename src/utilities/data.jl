"""
    data(; nodata=12, exterior=0, kwargs...)

Landcover classes for the Montérégie région of Québec, at a 500m x 500m resolution. The default nodata value is 12 (open water), can be set to nothing to have all the values present.

If exterior is set to any value larger than 0, this many cells on the border of the grid will be assigned to the exterior background, and will become negative.

The values are returned as Int8, so the nodata value must be given as an Int8 as well.
"""
function data(; nodata=12, exterior=0, kwargs...)
    datapath = joinpath((dirname ∘ dirname)(pathof(LandscapeMetrics)), "data", "grid.dat")
    grid = DelimitedFiles.readdlm(datapath, '\t', Int8)
    if exterior > 0
        # Remove rows
        grid[1:exterior, :] .*= (-1)
        grid[(end-exterior+1):end, :] .*= (-1)
        # Remove columns, note that we have already switched some of the rows!
        grid[(exterior+1):(end-exterior), 1:exterior] .*= (-1)
        grid[(exterior+1):(end-exterior), (end-exterior+1):end] .*= (-1)
    end
    nd_value = isnothing(nodata) ? typemax(eltype(grid)) : convert(eltype(grid), nodata)
    L = Landscape(grid; nodata=nd_value, area=500.0 * 500.0, kwargs...)
    return L
end

@testitem "We can load the demo data" begin
    L = LandscapeMetrics.data()
    @test L.area ≈ 250_000
    @test eltype(L) === Int8
end

@testitem "We can load the demo data with an exterior background" begin
    ext_size = 5
    L = LandscapeMetrics.data(; nodata=nothing, exterior=ext_size)
    expected_exterior_background = 2 * sum(ext_size .* size(L)) - 4 * (ext_size^2)
    @test sum(background(L)) == expected_exterior_background
end


function valdavid(; exterior=0, kwargs...)
    datapath = joinpath((dirname ∘ dirname)(pathof(LandscapeMetrics)), "data", "valdavid.dat")
    grid = DelimitedFiles.readdlm(datapath, '\t', Int8)
    if exterior > 0
        # Remove rows
        grid[1:exterior, :] .*= (-1)
        grid[(end-exterior+1):end, :] .*= (-1)
        # Remove columns, note that we have already switched some of the rows!
        grid[(exterior+1):(end-exterior), 1:exterior] .*= (-1)
        grid[(exterior+1):(end-exterior), (end-exterior+1):end] .*= (-1)
    end
    nd_value = typemax(eltype(grid))
    L = Landscape(grid; nodata=nd_value, area=110.0 * 110.0, kwargs...)
    return L
end