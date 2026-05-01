"""
    MontgomeryLaw{C}

Callable struct encoding the Montgomery leaf area model: `A = coefficient × L × W`.

The *Montgomery parameter* (coefficient, `a₁`) represents the fraction of the bounding
rectangle `L × W` occupied by the leaf. It ranges from 0.5 (perfectly triangular leaf)
to `π/4 ≈ 0.785` (perfectly elliptical leaf). Empirical values for broad-leaved plants
typically fall between 0.57 and 0.74 (Shi et al. 2019).

# Fields
- `coefficient` — Montgomery parameter a₁ (dimensionless)
- `reference`   — full citation string — **mandatory for all equation constants**

# Example
```julia
ml = MontgomeryLaw(0.65; reference="Shi et al. 2019 Trees 33:1073–1085")
ml(0.08u"m", 0.04u"m")   # → 0.00208 m²
ml(8.0u"cm", 4.0u"cm")   # → same, units handled automatically
```

# Reference
Montgomery, E. G. (1911). Correlation studies in corn.
*Nebraska Agricultural Experiment Station Annual Report* 24:108–159.
"""
struct MontgomeryLaw{C}
    coefficient::C
    reference::String
end

MontgomeryLaw(coefficient; reference="") = MontgomeryLaw(coefficient, reference)

"""
    (ml::MontgomeryLaw)(length, width) → Unitful area

Evaluate the Montgomery model. Both `length` and `width` must be `Unitful` lengths;
the returned area carries the product unit (e.g. `m²` if inputs are in `m`).
"""
(ml::MontgomeryLaw)(length::Unitful.Length, width::Unitful.Length) =
    ml.coefficient * length * width

"""
    reference(ml::MontgomeryLaw) → String

Return the literature citation for this Montgomery law equation.
"""
reference(ml::MontgomeryLaw) = ml.reference
