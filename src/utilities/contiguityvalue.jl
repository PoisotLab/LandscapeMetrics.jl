template = [
    1 2 1;
    2 1 2;
    1 2 1
]

function contiguityvalue(l::landscape, template)
    nrows, ncols = size(template)
    result = zeros(T, nrows, ncols)
    # Pad the matrix with zeros on all sides
    padded = zeros(T, nrows+2, ncols+2)
    padded[2:end-1, 2:end-1] .= matrix
    for i in 1:nrows
        for j in 1:ncols
            neighborhood = padded[i:i+2, j:j+2]
            result[i, j] = sum(neighborhood .* template)
        end
    end
    return result
end

@testitem "We can calculate the contiguity value of a landscape" begin
    A = [
        1 1;
        1 1
    ]
    expected = [
        6 6;
        6 6
    ]
    @test contiguityvalue(A, template) == expected
end