"""


    relativepatchrichness(l::Landscape)

"""

function relativepatchrichness(l::Landscape)
    pr = patchrichness(l)
    max_pr = 20 # hypothetical maximum patch richness for normalization
    return (pr / max_pr)*100
end