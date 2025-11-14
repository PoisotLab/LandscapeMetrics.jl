"""
   edgedensity(l::Landscape)

Returns the edge density of each class in the landscape, defined as the total edge length of a class divided by the total area.

"""

function edgedensity(l::Landscape, class_val)
    return totaledge(l, class_val) / totalarea(l)
end


@testitem "We can calculate the edge density of a landscape" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 2 2 2
    ]
    L = Landscape(A)
    @test edgedensity(L) == 5/18
end

"""
    edgedensity(l::Landscape)
Returns the edge density of the landscape.
"""
function edgedensity(l::Landscape)
    return totaledge(l) / totalarea(l)
end
