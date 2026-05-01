using BiophysicalAllometry
using Aqua
using SafeTestsets
using Test

@testset "Quality assurance" begin
    Aqua.test_unbound_args(BiophysicalAllometry)
    Aqua.test_stale_deps(BiophysicalAllometry)
    Aqua.test_undefined_exports(BiophysicalAllometry)
    Aqua.test_project_extras(BiophysicalAllometry)
    Aqua.test_deps_compat(BiophysicalAllometry)
end

@safetestset "power_law"              begin include("power_law.jl") end
@safetestset "montgomery_law"         begin include("montgomery_law.jl") end
@safetestset "allometric"             begin include("allometric.jl") end
@safetestset "structural_constraints" begin include("structural_constraints.jl") end
