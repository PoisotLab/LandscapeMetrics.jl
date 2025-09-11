


function perimeterareafractal(l::Landscape, p::Integer)
    
    @assert p in patches(l)
    pij = perimeter(l, p)
    aij = area(l, p)

    ln_aij = log(aij)
    ln_pij = log(pij)

    mean_ln_aij = mean(ln_aij)
    mean_ln_pij = mean(ln_pij)

    b1 = sum((ln_aij .- mean_ln_aij) .* (ln_pij .- mean_ln_pij)) / sum((ln_aij .- mean_ln_aij).^2)

    return 2/b1
end