using LandscapeMetrics
using CairoMakie
using Statistics
using ColorSchemes

# Montérégie: carte compacte soulignant les patchs d'une classe.
L = LandscapeMetrics.data()
labels = patches(L)

# Transposition de la matrice pour arranger l'orientation du paysage.
mat = L.grid'

# Filtrer uniquement les classes présentes dans la matrice
classes = sort(unique(vec(L.grid)))
n_classes = length(classes)

# Remapper les classes aux indices entiers consécutifs pour la visualisation
mat_idx = similar(mat, Int)
class_to_idx = Dict(c => i for (i, c) in enumerate(classes))
@inbounds for j in axes(mat, 2), i in axes(mat, 1)
    mat_idx[i, j] = class_to_idx[mat[i, j]]
end

# Palette de couleurs catégorique discrète avec exactement une couleur par classe présente
cmap = cgrad(ColorSchemes.viridis, n_classes; categorical = true)


# Création de la figure et de l'axe
fig = Figure(size = (1200, 1000))
fig.layout.default_rowgap = Fixed(10)
fig.layout.default_colgap = Fixed(10)
ax = Axis(fig[1, 1],
    title = "Classes de couverture terrestre - Montérégie",
    xlabel = "X",
    ylabel = "Y",
    backgroundcolor = :white)

# Heatmap avec des couleurs discrètes (pas d'interpolation), bins centrés
hm = heatmap!(ax, mat_idx; colormap = cmap, interpolate = false, colorrange = (0.5, n_classes + 0.5))

# Ajouter une barre de couleur discrète : ticks centrés avec les étiquettes de classes originales
cb = Colorbar(fig[1, 2], hm; label = "Classe de couverture terrestre", nsteps = n_classes,
    ticks = (collect(1:n_classes), string.(classes)), width = 12, height = Relative(1.0))
colsize!(fig.layout, 1, Relative(1.0))
colsize!(fig.layout, 2, Fixed(12))

fig
display(fig)




# Calcul et affichage du ROG par patch
#
P = patches(L)
begin
    lbl = P
    nrows, ncols = size(lbl)
    cellsize = 500.0 # meters per cell side
    Xc = repeat(reshape(collect(1:ncols), 1, ncols), nrows, 1) .* cellsize
    Yc = repeat(reshape(collect(1:nrows), nrows, 1), 1, ncols) .* cellsize

    patch_ids = sort(unique(vec(lbl)))
    # Exclure les étiquettes nulles si présentes (fond)
    patch_ids = filter(!iszero, patch_ids)
    rog_by_patch = Dict{Int, Float64}()
    for pid in patch_ids
        mask = lbl .== pid
        if any(mask)
            xs = Xc[mask]; ys = Yc[mask]
            cx = mean(xs); cy = mean(ys)
            d2 = (xs .- cx).^2 .+ (ys .- cy).^2
            rog_by_patch[pid] = sqrt(mean(d2))
        else
            rog_by_patch[pid] = NaN
        end
    end

    # Journaliser quelques valeurs et vérifier que les patchs de 1 cellule ont ROG=0
    for pid in patch_ids
        cnt = count(lbl .== pid)
        rogval = rog_by_patch[pid]
        println("Patch $(pid): n_cells=$(cnt), ROG (m)=", rogval)
    end

    rog_map = similar(Float32.(lbl))
    @inbounds for j in axes(lbl, 2), i in axes(lbl, 1)
        rog_map[i, j] = Float32(get(rog_by_patch, lbl[i, j], NaN))
    end

    # Heatmap des valeurs de ROG par patch
    fig_rogpatch = Figure(size = (1200, 1000))
    fig_rogpatch.layout.default_rowgap = Fixed(10)
    fig_rogpatch.layout.default_colgap = Fixed(10)
    ax_rgp = Axis(fig_rogpatch[1, 1], title = "ROG par patch",
                  xlabel = "X", ylabel = "Y", backgroundcolor = :white)
    # Colormap perceptuelle (type viridis) mais autres couleurs: plasma
    rog_cmap = cgrad(ColorSchemes.plasma, 256)
    finite_vals = filter(!isnan, vec(rog_map))
    if !isempty(finite_vals)
        # Ancrer l'échelle à 0 pour que les patchs à une cellule soient clairement au minimum
        cr = (0.0f0, maximum(finite_vals))
        hm_rgp = heatmap!(ax_rgp, rog_map'; colormap = rog_cmap, interpolate = false, colorrange = cr)
    else
        hm_rgp = heatmap!(ax_rgp, rog_map'; colormap = rog_cmap, interpolate = false)
    end
    Colorbar(fig_rogpatch[1, 2], hm_rgp; label = "ROG (m)", width = 12, height = Relative(1.0))
    colsize!(fig_rogpatch.layout, 1, Relative(1.0))
    colsize!(fig_rogpatch.layout, 2, Fixed(12))
    display(fig_rogpatch)
    save("rog_by_patch_monteregie.png", fig_rogpatch)
end


