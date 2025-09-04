"""
    totaledge(l::Landscape)

Total length of edge in the landscape.
"""

function totaledge(l::Landscape)
 
    grid = l.grid
    nrows, ncols = size(grid)
    total_edge_length = 0.0

    for i in 1:nrows, j in 1:ncols
        current = grid[i, j]

        if j < ncols && grid[i, j + 1] != current
            total_edge_length += 1.0
        end
        
        if i < nrows && grid[i + 1, j] != current
            total_edge_length += 1.0
        end
    end
    
    return total_edge_length * sqrt(l.area)
end


@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 2 2 2
    ]
    L = Landscape(A)
    @test totaledge(L) == 5
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 3;
        3 3
    ]
    L = Landscape(A)
    @test totaledge(L) == 2
end

@testitem "We can measure the total edge of a landscape" begin
    A = [
        1 1 1 2 2 2;
        1 1 1 2 2 2;
        2 2 2 1 2 2
    ]
    L = Landscape(A)
    @test totaledge(L) == 8
end
