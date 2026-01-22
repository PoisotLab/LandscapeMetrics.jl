"""

    patchrichnessdensity(l::Landscape)

"""

function patchrichnessdensity(l::Landscape)
    pr = patchrichness(l)
    area = totalarea(l)
    return pr / area
end