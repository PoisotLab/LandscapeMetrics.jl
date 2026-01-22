"""
    percentageoflikeadjacencies(l::Landscape, patch)

Calculates the Percentage of Like Adjacencies (PLADJ) for a given patch in the landscape. 

PLADJ is defined as the number of adjencies between cells of the same patch type divided by the total number of adjacencies involving that patch type, multiplied by 100.

Using double counting for adjacencies (i.e., each adjacency is counted for both cells involved).

"""


# Class-level PLADJ: for a landcover class value
function percentageoflikeadjacencies(l::Landscape, class::Int)
    # Validate class exists
    if !(class in unique(vec(l.grid)))
        error("class value $class not found in landscape")
    end

    # Work on the grid directly
    g = l.grid

    like_adjacencies = 0
    total_adjacencies = 0

    # Von Neumann neighborhood (no self)
    vonneumann = (CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0))

    # Iterate only over cells of this class
    for coordinate in CartesianIndices(g)
        if g[coordinate] == class
            # valid neighbors in bounds
            neighbors = (coordinate .+ vonneumann)
            for neighbor in neighbors
                if neighbor in CartesianIndices(g)
                    total_adjacencies += 1
                    if g[neighbor] == class
                        like_adjacencies += 1
                    end
                end
            end
        end
    end

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
    @test percentageoflikeadjacencies(L, 1) == 4/7 * 100
end


