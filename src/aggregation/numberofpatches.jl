"""
    numberofpatches(l::Landscape, class::Int)

Returns the number of patches for a given class in the landscape.
"""

function numberofpatches(l::Landscape, class::Int)
    # We get the patches
    p = patches(l)

    # Find unique patches belonging to the given class
    unique_patches = Set{Int}()
    for coordinate in CartesianIndices(p)
        if l[coordinate] == class
            push!(unique_patches, p[coordinate])
        end
    end

    return length(unique_patches)
end


function numberofpatches(l::Landscape)
    # We get the patches
    p = patches(l)

    # Find unique patches in the landscape
    unique_patches = unique(p)

    return length(unique_patches)
end


@testitem "We can measure the patch cohesion index" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2]
    L = Landscape(A)
    @test numberofpatches(L) == 5
end