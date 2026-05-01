module BiophysicalAllometryMakieExt

using Makie
using Unitful
using BiophysicalAllometry

import BiophysicalAllometry: plot_allometric_scaling, plot_structural_constraints

# ── Helpers ───────────────────────────────────────────────────────────────────

function _ylabel(v::AbstractAllometricVariable)
    v isa BasalMetabolicRate  && return "Basal metabolic rate (W)"
    v isa FieldMetabolicRate  && return "Field metabolic rate (W)"
    v isa SurfaceArea         && return "Surface area (m²)"
    v isa SkinArea            && return "Skin area (cm²)"
    v isa PlumageArea         && return "Plumage area (cm²)"
    v isa SkeletonMass        && return "Skeleton mass (kg)"
    v isa BrainMass           && return "Brain mass (kg)"
    v isa StrideFrequency     && return "Stride frequency (Hz)"
    v isa CostOfTransport     && return "Cost of transport (J kg⁻¹ m⁻¹)"
    v isa HeartRate           && return "Heart rate (min⁻¹)"
    v isa LungVolume          && return "Lung volume (mL)"
    v isa TidalVolume         && return "Tidal volume (mL)"
    v isa Lifespan            && return "Lifespan (yr)"
    v isa GenerationTime      && return "Generation time (yr)"
    return "Value"
end

_linestyle(::ElasticSimilarity)   = :solid
_linestyle(::GeometricSimilarity) = :dash
_linestyle(::DynamicSimilarity)   = :dot

# ── plot_allometric_scaling ───────────────────────────────────────────────────

"""
    plot_allometric_scaling(variable, pairs; mass_range, n_points, data_points) → Figure

Log-log plot of an allometric variable against body mass for one or more taxon groups.

# Arguments
- `variable::AbstractAllometricVariable` — the quantity to predict
- `pairs` — iterable of `(taxon, label, color)` 3-tuples

# Keywords
- `mass_range` — 2-element vector of `Unitful` masses, default `[0.001u"kg", 1000.0u"kg"]`
- `n_points`   — number of points per line (default 200)
- `data_points` — optional vector of `(mass, value, label)` for observed data overlays

# Example
```julia
using CairoMakie, BiophysicalAllometry
plot_allometric_scaling(
    BasalMetabolicRate(),
    [(EutherianMammal(), "Eutherian", :royalblue),
     (Marsupial(),       "Marsupial", :tomato),
     (PasserineBird(),   "Passerine", :forestgreen)];
    mass_range = [0.002u"kg", 200.0u"kg"]
)
```
"""
function BiophysicalAllometry.plot_allometric_scaling(
        variable,
        pairs;
        mass_range   = [0.001u"kg", 1000.0u"kg"],
        n_points     = 200,
        data_points  = nothing)

    m_lo   = ustrip(u"kg", mass_range[1])
    m_hi   = ustrip(u"kg", mass_range[2])
    masses = 10 .^ range(log10(m_lo), log10(m_hi); length=n_points)

    fig = Figure(size=(680, 500), backgroundcolor=:white)
    ax  = Axis(fig[1, 1];
               xscale=log10, yscale=log10,
               xlabel="Body mass (kg)",
               ylabel=_ylabel(variable),
               xminorticksvisible=true, yminorticksvisible=true,
               title="Allometric scaling: $(nameof(typeof(variable)))")

    legend_elems  = []
    legend_labels = String[]

    for (taxon, label, color) in pairs
        pl = power_law(variable, taxon)
        ys = [ustrip(pl(m * u"kg")) for m in masses]
        ln = lines!(ax, masses, ys; color=color, linewidth=2)
        # annotate exponent near the midpoint of the line
        mid = n_points ÷ 2
        text!(ax, masses[mid], ys[mid];
              text=" α=$(round(pl.exponent; digits=3))",
              fontsize=9, color=color,
              align=(:left, :bottom))
        push!(legend_elems, ln)
        push!(legend_labels, label)
    end

    if !isnothing(data_points)
        for (m, v, lbl) in data_points
            scatter!(ax, [ustrip(u"kg", m)], [ustrip(v)];
                     color=:black, markersize=7, marker=:circle)
        end
    end

    Legend(fig[2, 1], legend_elems, legend_labels;
           orientation=:horizontal, framevisible=false)
    rowgap!(fig.layout, 8)
    return fig
end

# ── plot_structural_constraints ───────────────────────────────────────────────

"""
    plot_structural_constraints(pairs; mass_range, target, n_points) → Figure

Compare limb dimension predictions across structural similarity assumptions on a
log-log axis.

# Arguments
- `pairs` — iterable of `(similarity, label, color)` 3-tuples

# Keywords
- `mass_range` — 2-element vector of `Unitful` masses
- `target`     — `:diameter` (default) or `:length`
- `n_points`   — number of points per line

# Example
```julia
using CairoMakie, BiophysicalAllometry
plot_structural_constraints(
    [(ElasticSimilarity(),   "Elastic",   :royalblue),
     (GeometricSimilarity(), "Geometric", :tomato)];
    target=:diameter
)
```
"""
function BiophysicalAllometry.plot_structural_constraints(
        pairs;
        mass_range = [0.01u"kg", 10_000.0u"kg"],
        target     = :diameter,
        n_points   = 200)

    m_lo   = ustrip(u"kg", mass_range[1])
    m_hi   = ustrip(u"kg", mass_range[2])
    masses = 10 .^ range(log10(m_lo), log10(m_hi); length=n_points)

    fn     = target === :diameter ? limb_diameter : limb_length
    ylabel = target === :diameter ? "Limb diameter (m)" : "Limb length (m)"

    fig = Figure(size=(680, 500), backgroundcolor=:white)
    ax  = Axis(fig[1, 1];
               xscale=log10, yscale=log10,
               xlabel="Body mass (kg)",
               ylabel=ylabel,
               xminorticksvisible=true, yminorticksvisible=true,
               title="Structural constraint comparison")

    legend_elems  = []
    legend_labels = String[]

    for (sim, label, color) in pairs
        ys = [ustrip(u"m", fn(sim, m * u"kg")) for m in masses]
        ln = lines!(ax, masses, ys;
                    color=color, linewidth=2, linestyle=_linestyle(sim))
        push!(legend_elems, ln)
        push!(legend_labels, label)
    end

    Legend(fig[2, 1], legend_elems, legend_labels;
           orientation=:horizontal, framevisible=false)
    rowgap!(fig.layout, 8)
    return fig
end

end # module BiophysicalAllometryMakieExt
