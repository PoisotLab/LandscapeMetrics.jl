using LandscapeMetrics
using CairoMakie

# Load landscape and build patch labels
L = LandscapeMetrics.data()
labels = patches(L)

# Class to highlight
cls = 1

# Patch IDs belonging to this class (exclude 0 = background)
patch_ids = sort(unique(vec(labels[L.grid .== cls])))
filter!(pid -> pid != 0, patch_ids)

# Select up to 20 patches
selected_ids = first(patch_ids, min(20, length(patch_ids)))
selset = Set(selected_ids)
println("Class $cls has $(length(patch_ids)) patches; showing $(length(selected_ids)).")

# Optional per-selected-patch metrics (keep or remove as you wish)
areas = [area(L, pid) for pid in selected_ids]
perims = [perimeter(L, pid) for pid in selected_ids]

# Classes from the grid (exclude nodata)
classes = sort(unique(vec(L.grid)))
if L.nodata !== nothing
    filter!(c -> c != L.nodata, classes)
end

# Class-level PLADJ values (cast to grid eltype to match method dispatch if needed)
pladj_by_class = [percentageoflikeadjacencies(L, Int(c)) for c in classes]

println("PLADJ by class:")
for (c, v) in zip(classes, pladj_by_class)
    println("  Class $(c): $(round(v, sigdigits=5))")
end

# Bar chart with exact PLADJ values per class
fig_class = Figure(size=(900, 400))
ax_class = Axis(fig_class[1,1], title="PLADJ (%) per class",
                xticks=(1:length(classes), string.(classes)),
                xticklabelrotation=pi/3)
barplot!(ax_class, 1:length(classes), pladj_by_class; color=:seagreen)
for i in 1:length(classes)
    text!(ax_class, Point2f(i, pladj_by_class[i]),
          text=string(round(pladj_by_class[i], sigdigits=4)),
          align=(:center, :bottom), fontsize=10, color=:black)
end
fig_class

# (deferred) PLADJ overlay is added after the figure and ax_map are created

# Prepare overlay mask for selected patches (NaN -> transparent)
overlay = fill(NaN, size(labels))
overlay[in.(labels, Ref(selset))] .= 1.0

# Figure: full map with highlighted patches, plus per-selected-patch area & perimeter bars
fig = Figure(size = (1400, 900))

# Left: full landcover map + highlighted patches overlay
ax_map = Axis(fig[1:3, 1], title = "Full landscape — highlighted patches (class $cls)")
ax_map.aspect = DataAspect()
hm_base = heatmap!(ax_map, L.grid; colormap = :viridis, interpolate = false)
hm_overlay = heatmap!(ax_map, overlay; colormap = :reds, colorrange = (0.0, 1.0),
                      interpolate = false, nan_color = :transparent, alpha = 0.7)
Colorbar(fig[1, 2], hm_base; label = "Class value", width = 18)
Colorbar(fig[2, 2], hm_overlay; label = "Selected patches", height = Relative(0.8), width = 18)

# Compute PLADJ for class 1
pladj_cls1 = percentageoflikeadjacencies(L, Int(cls))

# Always-visible figure-space label (top-right slot)
Label(fig[1, 4],
      "PLADJ (class $cls): $(round(pladj_cls1, sigdigits=5))%",
      color = :black,
      fontsize = 18)

# Optional: overlay label on the map (ensure position is in bounds)
text!(ax_map, Point2f(1, 1),
      text = "PLADJ (class $cls) = $(round(pladj_cls1, sigdigits=5))%",
      align = (:left, :bottom), color = :white, fontsize = 16)

# Inset bar for class-1 PLADJ in a free grid position
ax_pladj1 = Axis(fig[3, 4], title = "PLADJ class $cls",
                 yticks = (0:20:100), ylabel = "Percent",
                 xticks = (1:1, ["$cls"]))
limits!(ax_pladj1, (0.5, 1.5), (0, 100))
barplot!(ax_pladj1, [1], [pladj_cls1]; color = :seagreen, width = 0.6)
text!(ax_pladj1, Point2f(1, pladj_cls1),
      text = string(round(pladj_cls1, sigdigits = 5), "%"),
      align = (:center, :bottom), fontsize = 12, color = :black)

# Right column: exact values as bar charts with labels (area, perimeter)
x = 1:length(selected_ids)
xt = (x, string.(selected_ids))  # patch IDs as x-ticks

ax_b1 = Axis(fig[1, 3], title = "Area per selected patch", xticks = xt, xticklabelrotation = pi/3)
ax_b1.titlegap = 10
ax_b1.titlesize = 16
ax_b1.xticklabelsize = 11
ax_b1.yticklabelsize = 11
limits!(ax_b1, (0.5, length(x) + 0.5), (0, maximum(areas) * 1.15))
barplot!(ax_b1, x, areas; color = :dodgerblue, width = 0.8)
for i in x
    text!(ax_b1, Point2f(i, areas[i]), text = string(round(areas[i], sigdigits = 4)),
          align = (:center, :bottom), fontsize = 11, color = :black)
end

ax_b2 = Axis(fig[2, 3], title = "Perimeter per selected patch", xticks = xt, xticklabelrotation = pi/3)
ax_b2.titlegap = 10
ax_b2.titlesize = 16
ax_b2.xticklabelsize = 11
ax_b2.yticklabelsize = 11
limits!(ax_b2, (0.5, length(x) + 0.5), (0, maximum(perims) * 1.15))
barplot!(ax_b2, x, perims; color = :darkorange, width = 0.8)
for i in x
    text!(ax_b2, Point2f(i, perims[i]), text = string(round(perims[i], sigdigits = 4)),
          align = (:center, :bottom), fontsize = 11, color = :black)
end

# Ensure 'fig' is the last expression to display the main figure
fig