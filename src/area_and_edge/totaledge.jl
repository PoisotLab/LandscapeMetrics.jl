"""
    totaledge(l::Landscape)

Total length of edges of a specific class in the landscape.
"""

function totaledge(l::Landscape, class_val::Integer)

   
    # We get the patches
    p = patches(l)   
    
    # We get the indices of the landscape
    inds = CartesianIndices(p)

    # The length of one edge
    side = sqrt(l.area)

    # Initialize total sides count
    total_sides = 0

    # Loop through all indices in the landscape
    for idx in inds
        # consider only cells belonging to the requested class
        if l[idx] == class_val
            for d in VonNeumann
                nbr = idx + d
                # if neighbor is out of bounds, that's an exposed side
                if !(nbr in inds) || l[nbr] != class_val
                    total_sides += 1
                end
            end
        end
    end

    #Calculate the total edge length of the class
    return total_sides * side
end


@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 2 1 2
    ]
    L = Landscape(A)
    @test totaledge(L, 1) == 14
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 3;
        3 3
    ]
    L = Landscape(A)
    @test totaledge(L, 1) == 4
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    @test totaledge(L, 1) == 24
end
