# ── Structural similarity types ───────────────────────────────────────────────

"""
    AbstractScalingSimilarity

Abstract type for structural similarity assumptions used to predict limb proportions.
"""
abstract type AbstractScalingSimilarity end

"""
    ElasticSimilarity <: AbstractScalingSimilarity

McMahon's (1973) elastic similarity: limb dimensions scale to resist Euler buckling
under self-weight. Predicts:
- diameter ∝ length^(3/2)   (from length)
- diameter ∝ mass^(3/8)     (from mass)
- length   ∝ mass^(1/4)     (from mass)

Reference: McMahon, T. A. (1973). Size and shape in biology.
*Science* 179:1201–1204.
"""
struct ElasticSimilarity <: AbstractScalingSimilarity end

"""
    GeometricSimilarity <: AbstractScalingSimilarity

Geometric (isometric) similarity: all lengths scale as mass^(1/3), proportions constant.
Predicts:
- diameter ∝ length   (constant d/L ratio)
- diameter ∝ mass^(1/3)
- length   ∝ mass^(1/3)

Reference: Thompson, D. W. (1917). *On Growth and Form*. Cambridge University Press.
"""
struct GeometricSimilarity <: AbstractScalingSimilarity end

"""
    DynamicSimilarity <: AbstractScalingSimilarity

Dynamic similarity: stride length, frequency and speed scaled so that the Froude
number (v²/gL) is equal across sizes.
"""
struct DynamicSimilarity <: AbstractScalingSimilarity end

# ── Reference normalisation values (1 kg mammal) ──────────────────────────────
# Calibrated to typical mammal limb proportions at 1 kg body mass.
# At 1 kg (e.g. large squirrel / small rabbit): d ≈ 1.3 cm, L ≈ 17 cm.
# These give a 20 kg dog: d ≈ 4 cm, L ≈ 36 cm — anatomically consistent.
const _REF_MASS       = 1.0u"kg"
const _REF_DIAMETER   = 0.013u"m"  # limb diameter at 1 kg body mass
const _REF_LENGTH     = 0.17u"m"   # limb length at 1 kg body mass
const _REF_LEN_LENGTH = 0.17u"m"   # same baseline for length-based prediction

# ── limb_diameter ─────────────────────────────────────────────────────────────

"""
    limb_diameter(similarity, length) → Length
    limb_diameter(similarity, mass)   → Length

Predict limb diameter under the given structural similarity assumption.

Both dispatch forms accept `Unitful` quantities:
- `length::Unitful.Length` → diameter from limb length (McMahon length-based scaling)
- `mass::Unitful.Mass`     → diameter from body mass

Reference: McMahon, T. A. (1973). Size and shape in biology. *Science* 179:1201–1204.

# Examples
```julia
limb_diameter(ElasticSimilarity(),   0.3u"m")    # from length → m
limb_diameter(ElasticSimilarity(),   20.0u"kg")  # from mass   → m
limb_diameter(GeometricSimilarity(), 20.0u"kg")  # → thinner than elastic
```
"""
function limb_diameter(::ElasticSimilarity, length::Unitful.Length)
    _REF_DIAMETER * (length / _REF_LEN_LENGTH)^(3//2)
end

function limb_diameter(::GeometricSimilarity, length::Unitful.Length)
    # d/L constant; _REF_DIAMETER / _REF_LEN_LENGTH ≈ 0.16
    (_REF_DIAMETER / _REF_LEN_LENGTH) * length
end

function limb_diameter(::ElasticSimilarity, mass::Unitful.Mass)
    _REF_DIAMETER * (ustrip(u"kg", mass) / ustrip(u"kg", _REF_MASS))^(3//8)
end

function limb_diameter(::GeometricSimilarity, mass::Unitful.Mass)
    _REF_DIAMETER * (ustrip(u"kg", mass) / ustrip(u"kg", _REF_MASS))^(1//3)
end

# ── limb_length ───────────────────────────────────────────────────────────────

"""
    limb_length(similarity, mass) → Length

Predict limb length from body mass under the given structural similarity assumption.

- `ElasticSimilarity`:   L ∝ M^(1/4)
- `GeometricSimilarity`: L ∝ M^(1/3)

Reference: McMahon, T. A. (1973). Size and shape in biology. *Science* 179:1201–1204.

# Example
```julia
limb_length(ElasticSimilarity(),   20.0u"kg")  # → ~0.36 m
limb_length(GeometricSimilarity(), 20.0u"kg")  # → ~0.46 m
```
"""
function limb_length(::ElasticSimilarity, mass::Unitful.Mass)
    _REF_LENGTH * (ustrip(u"kg", mass) / ustrip(u"kg", _REF_MASS))^(1//4)
end

function limb_length(::GeometricSimilarity, mass::Unitful.Mass)
    _REF_LENGTH * (ustrip(u"kg", mass) / ustrip(u"kg", _REF_MASS))^(1//3)
end

# ── limb_aspect_ratio ─────────────────────────────────────────────────────────

"""
    limb_aspect_ratio(similarity, mass) → Float64

Return the predicted limb length-to-diameter ratio (L/d, dimensionless) under the
given structural similarity assumption.

This ratio can be passed directly as the `b` parameter to
`BiophysicalGeometry.Cylinder(mass, density, b)`.

Reference: McMahon, T. A. (1973). Size and shape in biology. *Science* 179:1201–1204.

# Example
```julia
b = limb_aspect_ratio(ElasticSimilarity(), 20.0u"kg")
leg = BiophysicalGeometry.Body(BiophysicalGeometry.Cylinder(m_leg, density, b), fur)
```
"""
function limb_aspect_ratio(sim::AbstractScalingSimilarity, mass::Unitful.Mass)
    d = limb_diameter(sim, mass)
    l = limb_length(sim, mass)
    ustrip(u"m", l) / ustrip(u"m", d)
end
