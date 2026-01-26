"""
    totaledge(l::Landscape)

Total length of edges of a specific class in the landscape. Border edges and background are excluded.
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

    # Foreground mask (exclude background cells)
    fg = foreground(l)

    # Loop through all indices in the landscape but only if its the foreground and the requested class

    for idx in inds
        # consider only cells belonging to the requested class
        if fg[idx] && l[idx] == class_val
            for d in VonNeumann
                nbr = idx + d
                # count only edges between two different foreground classes
                if (nbr in inds) && fg[nbr] && l[nbr] != class_val
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
    @test totaledge(L, 1) == 8
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 3;
        3 3
    ]
    L = Landscape(A)
    @test totaledge(L, 1) == 2
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    @test totaledge(L, 1) == 13
    @test totaledge(L, 2) == 13
end

"""
    totaledge(l::Landscape)

Total length of internal edges that separate different foreground classes. Border edges and background are excluded.
"""
function totaledge(l::Landscape)

    # Get the size of the landscape
    rows, cols = size(l)

    # Get the foreground mask
    fg = foreground(l)

    # Initialize total edge count
    total = 0

    # Loop through each cell in the landscape
    for r in 1:rows
        for c in 1:cols
            # Consider only foreground cells
            if fg[r, c]
                # Check right neighbor
                # If neighbor is foreground and different class, increment edge count
                if c < cols && fg[r, c + 1] && l[r, c] != l[r, c + 1]
                    total += 1
                end
                # Check bottom neighbor
                # If neighbor is foreground and different class, increment edge count
                if r < rows && fg[r + 1, c] && l[r, c] != l[r + 1, c]
                    total += 1
                end
            end
        end
    end

    # Each edge has length equal to the side of a cell
    return total * sqrt(l.area)
end 



@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 1 2;
        1 2 1 2 1 2;
        1 1 1 2 1 2
    ]
    L = Landscape(A)
    @test totaledge(L) == 13
end

@testitem "Measure the total edge of a landscape with single class" begin
    A = [
        1 1 1;
        1 1 1;
        1 1 1
    ]
    L = Landscape(A)
    @test totaledge(L) == 0
end
