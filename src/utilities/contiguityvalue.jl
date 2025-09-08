B = [
    1 2 1;
    2 1 2;
    1 2 1
]

function contiguityvalue(A::AbstractMatrix, B::AbstractMatrix)
    nrows, ncols = size(B)
    T = eltype(A)
    result = zeros(T, nrows, ncols)
    # Pad the matrix with zeros on all sides
    padded = zeros(T, nrows+2, ncols+2)
    padded[2:end-1, 2:end-1] .= A
    for i in 1:nrows
        for j in 1:ncols
            neighborhood = padded[i:i+2, j:j+2]
            result[i, j] = sum(neighborhood .* B)
        end
    end
    return result
end

@testitem "We can calculate the contiguity value of a landscape" begin
    A = [
        1 1;
        1 1
    ]
    B = [
    1 2 1;
    2 1 2;
    1 2 1
]
    expected = [
        6 6;
        6 6
    ]
    @test contiguityvalue(A, B) == expected
end