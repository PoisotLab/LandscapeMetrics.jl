using LandscapeMetrics
using CairoMakie
using Statistics

# Montérégie: carte compacte soulignant les patchs d'une classe
L = LandscapeMetrics.data()
labels = patches(L)
cls = 9

# Patch IDs de la classe 8 (exclut 0 = fond)
patch_ids = sort(unique(vec(labels[L.grid .== cls])))
filter!(pid -> pid != 0, patch_ids)
println("Classe $cls: $(length(patch_ids)) patchs trouvés.")

# Masque overlay (NaN -> transparent) pour tous les patchs de la classe 8
overlay = fill(NaN, size(labels))
overlay[in.(labels, Ref(Set(patch_ids)))] .= 1.0

# Figure carrée et compacte: carte + surbrillance de la classe sélectionnée
fig = Figure(size = (600, 600))
# Étend la carte sur deux colonnes pour lui donner plus d'espace
ax = Axis(fig[1:2, 1:2], title = "Classe $(cls) - $(length(patch_ids)) patchs")
ax.aspect = DataAspect()
hm_base = heatmap!(ax, L.grid'; colormap = :viridis, interpolate = false, colorrange = (1, 12))
hm_overlay = heatmap!(ax, overlay'; colormap = :reds, colorrange = (0.0, 1.0),
                      interpolate = false, nan_color = :transparent, alpha = 0.75)

# Allège l'axe pour une figure plus compacte
hidexdecorations!(ax)
hideydecorations!(ax)
hidespines!(ax)
tightlimits!(ax)

# Colorbars compactes ("sliders" des classes et des patchs sélectionnées)
# Colorbars compactes dans une colonne dédiée (plus petites)
Colorbar(fig[1, 3], hm_base; label = "Classes", width = 8, height = Relative(0.4), ticks = 1:12)
Colorbar(fig[2, 3], hm_overlay; label = "Sélection", width = 8, height = Relative(0.4))

# Affiche la figure
fig

# -----------------------------------------------------------------------------
# Grille de 12 cartes: chaque carte souligne une classe différente (1 à 12)
# -----------------------------------------------------------------------------
fig_grid = Figure(size = (1100, 850))

for i in 1:12
    r = (i - 1) ÷ 4 + 1
    c = (i - 1) % 4 + 1
    axg = Axis(fig_grid[r, c], title = "Classe $(i)")
    axg.aspect = DataAspect()

    # Patches de la classe i
    pids_i = sort(unique(vec(labels[L.grid .== i])))
    filter!(pid -> pid != 0, pids_i)

    # Masque overlay pour cette classe
    ov = fill(NaN, size(labels))
    if !isempty(pids_i)
        ov[in.(labels, Ref(Set(pids_i)))] .= 1.0
        axg.title = "Classe $(i) — $(length(pids_i)) patchs"
    else
        axg.title = "Classe $(i) — 0 patch"
    end

    heatmap!(axg, L.grid'; colormap = :viridis, interpolate = false, colorrange = (1, 12))
    heatmap!(axg, ov'; colormap = :reds, colorrange = (0.0, 1.0),
             interpolate = false, nan_color = :transparent, alpha = 0.75)
    hidexdecorations!(axg)
    hideydecorations!(axg)
    hidespines!(axg)
end

# Affiche la grille de petites cartes
fig_grid

# -----------------------------------------------------------------------------
# Variante avec étiquettes de classes (légende compacte + titres lisibles)
# -----------------------------------------------------------------------------
class_names = [
    "Arbres à aiguilles persistants ou caduc", "Arbres à feuilles larges persistants", "Arbres à feuilles larges caducs", "Arbres mixtes ou autres types d’arbres", "Arbustes", "Végétation herbacée",
    "Végétation cultivée et gérée", "Végétation régulièrement inondée", "Zone urbaine ou bâtie", "Neige / glace", "Sol nu / zone stérile", "Eau libre",
]

fig_grid_named = Figure(size = (1100, 900))

# Utilitaire: renvoie un titre multi-lignes ne dépassant pas ~maxlen caractères par ligne
function wrap_label(s::AbstractString; maxlen::Int=26)
    words = split(s, ' ')
    lines = String[]
    cur = ""
    for w in words
        if isempty(cur)
            cur = w
        elseif length(cur) + 1 + length(w) <= maxlen
            cur *= " " * w
        else
            push!(lines, cur)
            cur = w
        end
    end
    if !isempty(cur)
        push!(lines, cur)
    end
    return join(lines, "\n")
end

for i in 1:12
    r = (i - 1) ÷ 4 + 1
    c = (i - 1) % 4 + 1
    axg = Axis(fig_grid_named[r, c], title = wrap_label(class_names[i]))
    axg.aspect = DataAspect()
    axg.titlesize = 10
    axg.titlegap = 2

    # Patches de la classe i
    pids_i = sort(unique(vec(labels[L.grid .== i])))
    filter!(pid -> pid != 0, pids_i)

    # Masque overlay pour cette classe
    ov = fill(NaN, size(labels))
    if !isempty(pids_i)
        ov[in.(labels, Ref(Set(pids_i)))] .= 1.0
        axg.title = string(wrap_label(class_names[i]), "\n(", length(pids_i), " patchs)")
    else
        axg.title = string(wrap_label(class_names[i]), "\n(0 patch)")
    end

    heatmap!(axg, L.grid'; colormap = :viridis, interpolate = false, colorrange = (1, 12))
    heatmap!(axg, ov'; colormap = :reds, colorrange = (0.0, 1.0),
             interpolate = false, nan_color = :transparent, alpha = 0.75)
    hidexdecorations!(axg)
    hideydecorations!(axg)
    hidespines!(axg)
end

# Légende globale supprimée pour optimiser l'espace; les titres des cartes contiennent les classes

# Affiche la grille nommée
fig_grid_named

# -----------------------------------------------------------------------------
# Calcul: radius of gyration pour tous les patchs de chaque classe (1..12)
# -----------------------------------------------------------------------------
# Regroupe les patchs par classe via une cellule représentative de chaque patch
P_all = patches(L)
all_pids = sort(unique(vec(P_all)))
filter!(pid -> pid != 0, all_pids)

pids_by_class_all = Dict{Int, Vector{Int}}(c => Int[] for c in 1:12)
for pid in all_pids
    idx = findfirst(==(pid), P_all)
    if idx !== nothing
        cval = Int(L.grid[idx])
        if 1 <= cval <= 12
            push!(pids_by_class_all[cval], pid)
        end
    end
end

# Calcule le rayon de giration pour chaque patch et l’agrège par classe
rog_by_class = Dict{Int, Vector{NamedTuple{(:patch, :rog), Tuple{Int, Float64}}}}()
for c in 1:12
    tuples = NamedTuple{(:patch, :rog), Tuple{Int, Float64}}[]
    for pid in pids_by_class_all[c]
        rog = radiusofgyration(L, pid)
        push!(tuples, (patch = pid, rog = rog))
    end
    rog_by_class[c] = tuples
end

# Résumé rapide en console (nb, min, mean, max) par classe
println("\nRésumé radius of gyration par classe:")
for c in 1:12
    vals = [t.rog for t in rog_by_class[c]]
    if isempty(vals)
        println(rpad("Classe $(c)", 10), ": aucun patch")
    else
        mn = minimum(vals); mx = maximum(vals); mu = mean(vals)
        println(rpad("Classe $(c)", 10), ": n=$(length(vals))  min=$(round(mn, sigdigits=4))  mean=$(round(mu, sigdigits=4))  max=$(round(mx, sigdigits=4))")
    end
end

# -----------------------------------------------------------------------------
# Ridgeline lisible (histogramme densité normalisé, amplitude contrôlée)
# -----------------------------------------------------------------------------
nbins_rl = 60
ridge_height = 0.9

# Utilise les ROG déjà calculés dans rog_by_class
all_rog_vals = reduce(vcat, [[t.rog for t in rog_by_class[c]] for c in 1:12 if !isempty(rog_by_class[c])] ; init=Float64[])
global_min_rog = isempty(all_rog_vals) ? 0.0 : minimum(all_rog_vals)
global_max_rog = isempty(all_rog_vals) ? 1.0 : maximum(all_rog_vals)

fig_rog_ridge_clear = Figure(size = (950, 750))
offs = 1:12
ax_rc = Axis(fig_rog_ridge_clear[1, 1],
    title = "Rayon de giration — ridgeline (clair)",
    yticks = (offs, class_names), ylabel = "Classes", xlabel = "Radius of gyration (meters)",
    xticks = (collect(0:100:1500), string.(collect(0:100:1500))))

for i in 1:12
    vals = [t.rog for t in rog_by_class[i]]
    if isempty(vals)
        continue
    end
    lo = global_min_rog
    hi = global_max_rog
    if hi <= lo
        hi = lo + 1e-6
    end
    # Limiter le domaine x à [0, 1500]
    lo = 0.0
    hi = 1500.0
    edges = range(lo, hi; length = nbins_rl + 1)
    counts = zeros(Float64, nbins_rl)
    for v in vals
        if v < lo || v > hi
            continue
        end
        b = clamp(searchsortedlast(collect(edges), v), 1, nbins_rl)
        counts[b] += 1
    end
    binw = step(edges)
    dens = counts ./ max(sum(counts) * binw, eps())
    m = maximum(dens)
    dens_norm = m > 0 ? dens ./ m : dens
    mids_all = [(edges[j] + edges[j+1]) / 2 for j in 1:nbins_rl]
    # Retirer les binnings de densité nulle pour éviter de tracer des segments plats
    keep = findall(d -> d > 0, dens_norm)
    if !isempty(keep)
        mids = mids_all[keep]
        y0 = fill(offs[i], length(keep))
        y1 = y0 .+ ridge_height .* dens_norm[keep]
        band!(ax_rc, mids, y0, y1, color = (:steelblue, 0.35))
        lines!(ax_rc, mids, y1, color = :black, linewidth = 1)
    end
end

ax_rc.ygridvisible = false
hidespines!(ax_rc)
xlims!(ax_rc, 0, 1500)
ylims!(ax_rc, 0, 13.5)



# Affiche la figure ridgeline claire
fig_rog_ridge_clear

# -----------------------------------------------------------------------------
# Calcul: fractal dimension index (FDI) pour tous les patchs de chaque classe
# -----------------------------------------------------------------------------
# Réutilise pids_by_class_all défini plus haut
fdi_by_class = Dict{Int, Vector{NamedTuple{(:patch, :fdi), Tuple{Int, Float64}}}}()
for c in 1:12
    tuples = NamedTuple{(:patch, :fdi), Tuple{Int, Float64}}[]
    for pid in pids_by_class_all[c]
        val = fractaldimensionindex(L, pid)
        if !isnan(val)
            push!(tuples, (patch = pid, fdi = val))
        end
    end
    fdi_by_class[c] = tuples
end

# Résumé rapide en console (nb, min, mean, max) par classe pour FDI
println("\nRésumé fractal dimension index (FDI) par classe:")
for c in 1:12
    vals = [t.fdi for t in fdi_by_class[c]]
    if isempty(vals)
        println(rpad("Classe $(c)", 10), ": aucun patch")
    else
        mn = minimum(vals); mx = maximum(vals); mu = mean(vals)
        println(rpad("Classe $(c)", 10), ": n=$(length(vals))  min=$(round(mn, sigdigits=4))  mean=$(round(mu, sigdigits=4))  max=$(round(mx, sigdigits=4))")
    end
end

# -----------------------------------------------------------------------------
# FDI — Ridgeline "clair" (histogramme densité normalisé, amplitude contrôlée)
# -----------------------------------------------------------------------------
nbins_fdi = 60
ridge_h_fdi = 0.9

all_fdi_vals = reduce(vcat, [[t.fdi for t in fdi_by_class[c]] for c in 1:12 if !isempty(fdi_by_class[c])] ; init=Float64[])
global_min_fdi = isempty(all_fdi_vals) ? 0.0 : minimum(all_fdi_vals)
global_max_fdi = isempty(all_fdi_vals) ? 1.0 : maximum(all_fdi_vals)

fig_fdi_ridge_clear = Figure(size = (950, 750))
offs_fdi = 1:12
ax_fc = Axis(fig_fdi_ridge_clear[1, 1],
    title = "Fractal dimension index — ridgeline (clair)",
    yticks = (offs_fdi, class_names), ylabel = "Classes", xlabel = "Fractal dimension index",
    xticks = (collect(0.0:0.05:0.3), string.(collect(0.0:0.05:0.3))))

for i in 1:12
    vals = [t.fdi for t in fdi_by_class[i]]
    if isempty(vals)
        continue
    end
    lo = global_min_fdi
    hi = global_max_fdi
    if hi <= lo
        hi = lo + 1e-6
    end
    # Domaine FDI borné à [0, 0.3]
    lo = 0.0
    hi = 0.3
    edges = range(lo, hi; length = nbins_fdi + 1)
    counts = zeros(Float64, nbins_fdi)
    for v in vals
        if v < lo || v > hi
            continue
        end
        b = clamp(searchsortedlast(collect(edges), v), 1, nbins_fdi)
        counts[b] += 1
    end
    binw = step(edges)
    dens = counts ./ max(sum(counts) * binw, eps())
    m = maximum(dens)
    dens_norm = m > 0 ? dens ./ m : dens
    mids_all = [(edges[j] + edges[j+1]) / 2 for j in 1:nbins_fdi]
    keep = findall(d -> d > 0, dens_norm)
    if !isempty(keep)
        mids = mids_all[keep]
        y0 = fill(offs_fdi[i], length(keep))
        y1 = y0 .+ ridge_h_fdi .* dens_norm[keep]
        band!(ax_fc, mids, y0, y1, color = (:seagreen, 0.35))
        lines!(ax_fc, mids, y1, color = :black, linewidth = 1)
    end
end

ax_fc.ygridvisible = false
hidespines!(ax_fc)
xlims!(ax_fc, 0, 0.3)
ylims!(ax_fc, 0, 13.5)

# Affiche la figure FDI ridgeline claire
fig_fdi_ridge_clear

# -----------------------------------------------------------------------------
# Calcul: Percentage of Like Adjacencies (PLADJ) par classe (pas par patch)
# -----------------------------------------------------------------------------
class_pladj = Dict{Int, Float64}()
classes_present = Set(unique(vec(L.grid)))
for c in 1:12
    if c in classes_present
        class_pladj[c] = percentageoflikeadjacencies(L, c)
    else
        class_pladj[c] = NaN
    end
end

# Résumé console PLADJ par classe
println("\nRésumé percentage of like adjacencies (PLADJ) par classe (class-level):")
for c in 1:12
    v = class_pladj[c]
    if isnan(v)
        println(rpad("Classe $(c)", 10), ": absente (aucune cellule)")
    else
        println(rpad("Classe $(c)", 10), ": PLADJ=$(round(v, sigdigits=5)) %")
    end
end

# -----------------------------------------------------------------------------
# PLADJ — Diagramme à barres horizontal par classe (0–100 %)
# -----------------------------------------------------------------------------
fig_pladj_class = Figure(size = (950, 750))
offs_plc = 1:12
ax_plc = Axis(fig_pladj_class[1, 1],
    title = "Percentage of like adjacencies — par classe",
    yticks = (offs_plc, class_names), ylabel = "Classes", xlabel = "PLADJ (%)",
    xticks = (collect(0:10:100), string.(collect(0:10:100))))

bar_half_h = 0.35
for i in 1:12
    v = class_pladj[i]
    if isnan(v)
        continue
    end
    x0 = 0.0
    x1 = clamp(v, 0.0, 100.0)
    y = offs_plc[i]
    xs = [x0, x1, x1, x0]
    ys = [y - bar_half_h, y - bar_half_h, y + bar_half_h, y + bar_half_h]
    CairoMakie.poly!(ax_plc, xs, ys, color = (:darkorange, 0.8))
    CairoMakie.lines!(ax_plc, [x1, x1], [y - bar_half_h, y + bar_half_h], color = :black, linewidth = 1)
end

ax_plc.ygridvisible = false
hidespines!(ax_plc)
xlims!(ax_plc, 0, 100)
ylims!(ax_plc, 0, 13.5)

# Affiche la figure PLADJ par classe
fig_pladj_class
