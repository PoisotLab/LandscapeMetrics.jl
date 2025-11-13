"""
    count_core_areas(A::Matrix{Int}, depth::Int=0)

Count the number of core areas in a binary matrix A after eroding it by the specified depth.

"""


function count_core_areas(l::Landscape, patch, depth::Int=0)

    # Create a mask for the specified patch
    core_mask = patches(l) .== patch

    # Erode the core mask by the specified depth
    nrows, ncols = size(core_mask)
    for _ in 1:depth
        up    = vcat(falses(1, ncols), core_mask[1:end-1, :])
        down  = vcat(core_mask[2:end, :], falses(1, ncols))
        left  = hcat(falses(nrows, 1), core_mask[:, 1:end-1])
        right = hcat(core_mask[:, 2:end], falses(nrows, 1))
        core_mask = core_mask .& up .& down .& left .& right
    end

    # Now we need to count the number of connected components in core_mask
    labels = zeros(Int, nrows, ncols)
    label = 0

    """
        flood_fill(i, j, lab)

        Flood fill algorithm to label connected components in the core_mask.
    """
    function flood_fill(i, j, lab)
        stack = [(i, j)]
        while !isempty(stack)
            x, y = pop!(stack)
            if 1 <= x <= nrows && 1 <= y <= ncols && core_mask[x, y] && labels[x, y] == 0
                labels[x, y] = lab
                for (dx, dy) in ((-1,0), (1,0), (0,-1), (0,1))
                    push!(stack, (x + dx, y + dy))
                end
            end
        end
    end

    for i in 1:nrows
        for j in 1:ncols
            if core_mask[i, j] && labels[i, j] == 0
                label += 1
                flood_fill(i, j, label)
            end
        end
    end
    return label
end

@testitem "Core area is positive for multi-cell patch with depth 1" begin
    A = [
        1 1 1 0 0 0 0;
        1 1 1 0 2 2 2;
        1 1 1 1 1 1 2;
        0 0 0 1 1 1 2; 
        0 0 0 1 1 1 0;
        0 0 0 0 0 0 0;
        0 0 0 0 0 0 0
    ]
    L = Landscape(A)

    @test count_core_areas(L, 2, 1) == 2
end