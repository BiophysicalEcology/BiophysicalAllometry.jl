using BiologicalScaling
using Aqua
using SafeTestsets
using Test

@testset "Quality assurance" begin
    Aqua.test_unbound_args(BiologicalScaling)
    Aqua.test_stale_deps(BiologicalScaling)
    Aqua.test_undefined_exports(BiologicalScaling)
    Aqua.test_project_extras(BiologicalScaling)
    Aqua.test_deps_compat(BiologicalScaling)
end

@safetestset "power_law"              begin include("power_law.jl") end
@safetestset "montgomery_law"         begin include("montgomery_law.jl") end
@safetestset "allometric"             begin include("allometric.jl") end
@safetestset "structural_constraints" begin include("structural_constraints.jl") end
