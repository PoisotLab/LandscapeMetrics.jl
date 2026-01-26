"""
    percentageoflikeadjacencies(l::Landscape, patch)

Calculates the Percentage of Like Adjacencies (PLADJ) for a given patch in the landscape. 

PLADJ is defined as the number of adjencies between cells of the same patch type divided by the total number of adjacencies involving that patch type, multiplied by 100.

Using double counting for adjacencies (i.e., each adjacency is counted for both cells involved). Background edges are added once to the denominator.

"""


# Class-level PLADJ: for a landcover class value
function percentageoflikeadjacencies(l::Landscape, class::Int)
    # Work on the grid directly
    g = l.grid
    fg = foreground(l)

    # Validate class exists in foreground
    if !any(fg .& (g .== class))
        error("class value $class not found in landscape")
    end

    like_adjacencies = 0
    total_adjacencies = 0
    background_edges = 0

    # Von Neumann neighborhood (no self)
    vonneumann = (CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0))

    # Iterate only over foreground cells of this class
    for coordinate in CartesianIndices(g)
        if fg[coordinate] && g[coordinate] == class
            neighbors = (coordinate .+ vonneumann)
            for neighbor in neighbors
                if neighbor in CartesianIndices(g)
                    if fg[neighbor]
                        total_adjacencies += 1
                        if g[neighbor] == class
                            like_adjacencies += 1
                        end
                    else
                        background_edges += 1
                    end
                else
                    background_edges += 1
                end
            end
        end
    end

    total_adjacencies += background_edges

    if total_adjacencies == 0
        return 0.0
    end

    return (like_adjacencies / total_adjacencies) * 100.0
end

@testitem "We can measure the pladj of a patch" begin
    A = [
        1 1 0;
        1 0 0
]
    L = Landscape(A)
    @test round(percentageoflikeadjacencies(L, 1); digits=1) == 33.3
end


"""
    percentageoflikeadjacencies(l::Landscape)

Calculates the Percentage of Like Adjacencies (PLADJ) for all patch types in the landscape. That is the number of joins between cells of the same patch type divided by the total number of joins involving that patch type (based on the double count method), multiplied by 100. Background edges are added once to the denominator.
"""
function percentageoflikeadjacencies(l::Landscape)
    g = l.grid
    fg = foreground(l)

    total_like_adjacencies = 0
    total_adjacencies = 0
    background_edges = 0

    # Von Neumann neighborhood (no self)
    vonneumann = (CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0))

    for coordinate in CartesianIndices(g)
        if fg[coordinate]
            neighbors = (coordinate .+ vonneumann)
            for neighbor in neighbors
                if neighbor in CartesianIndices(g)
                    if fg[neighbor]
                        total_adjacencies += 1
                        if g[neighbor] == g[coordinate]
                            total_like_adjacencies += 1
                        end
                    else
                        background_edges += 1
                    end
                else
                    background_edges += 1
                end
            end
        end
    end

    total_adjacencies += background_edges

    if total_adjacencies == 0
        return 0.0
    end

    return (total_like_adjacencies / total_adjacencies) * 100.0
end

@testitem "We can measure the pladj of all patches" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    @test round(percentageoflikeadjacencies(L); digits=1) == 38.9
end

