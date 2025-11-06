"""
   edgedensity(l::Landscape)

Returns the edge density of the landscape, defined as the total edge length divided by the total area.

"""

function edgedensity(l::Landscape)
    return totaledge(l) / totalarea(l)
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