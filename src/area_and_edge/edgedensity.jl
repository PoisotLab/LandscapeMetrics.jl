"""
   edgedensity(l::Landscape, class_val::Int)

Returns the edge density of a specific class in the landscape, defined as the total edge length of a class divided by the total area.

"""

function edgedensity(l::Landscape, class_val::Int)
    return totaledge(l, class_val) / totalarea(l)
end


@testitem "We can calculate the edge density for a specific class" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A, )
    @test edgedensity(L, 1) == 13/18
end

"""
    edgedensity(l::Landscape)
Returns the edge density of the landscape.
"""
function edgedensity(l::Landscape)
    return totaledge(l) / totalarea(l)
end

@testitem "We can calculate the edge density of a landscape" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A, )
    @test edgedensity(L) == 13/18
end
