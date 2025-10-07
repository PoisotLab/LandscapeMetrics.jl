function count_core_areas(core_mask)
    nrows, ncols = size(core_mask)
    labels = zeros(Int, nrows, ncols)
    label = 0

    function flood_fill(i, j, label)
        stack = [(i, j)]
        while !isempty(stack)
            x, y = pop!(stack)
            if 1 <= x <= nrows && 1 <= y <= ncols && core_mask[x, y] && labels[x, y] == 0
                labels[x, y] = label
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


function compute_core_mask(A::Matrix{Int}, depth::Int)
    core_mask = A .== 1
    for d in 1:depth
        boundary = falses(size(core_mask))
        for i in 1:size(core_mask, 1)
            for j in 1:size(core_mask, 2)
                if core_mask[i, j]
                    for (di, dj) in ((-1,0), (1,0), (0,-1), (0,1))
                        ni, nj = i+di, j+dj
                        if 1 <= ni <= size(core_mask,1) && 1 <= nj <= size(core_mask,2)
                            if !core_mask[ni, nj]
                                boundary[i, j] = true
                            end
                        else
                            boundary[i, j] = true
                        end
                    end
                end
            end
        end
        core_mask[boundary] .= false
    end
    return core_mask
end

@testitem "Core area is positive for multi-cell patch with depth 1" begin
    A = [
        1 1 1 0 1 1 1;
        1 1 1 0 1 1 1;
        1 1 1 1 1 1 1;
        0 0 0 0 0 0 0 
    ]
    core_mask = compute_core_mask(A, 1)
    ncore = count_core_areas(core_mask)
    @test ncore == 2
end







