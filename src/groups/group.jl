@doc raw"""
    AbstractGroupOperation

Abstract type for smooth binary operations $\circ$ on elements of a Lie group $G$:
```math
\circ : G × G → G
```
An operation can be either defined for a specific [`AbstractGroupManifold`](@ref)
or in general, by defining for an operation `Op` the following methods:

    identity!(::AbstractGroupManifold{Op}, q, q)
    identity(::AbstractGroupManifold{Op}, p)
    inv!(::AbstractGroupManifold{Op}, q, p)
    inv(::AbstractGroupManifold{Op}, p)
    compose(::AbstractGroupManifold{Op}, p, q)
    compose!(::AbstractGroupManifold{Op}, x, p, q)

Note that a manifold is connected with an operation by wrapping it with a decorator,
[`AbstractGroupManifold`](@ref). In typical cases the concrete wrapper
[`GroupManifold`](@ref) can be used.
"""
abstract type AbstractGroupOperation end

@doc raw"""
    AbstractGroupManifold{<:AbstractGroupOperation} <: Manifold

Abstract type for a Lie group, a group that is also a smooth manifold with an
[`AbstractGroupOperation`](@ref), a smooth binary operation. `AbstractGroupManifold`s must
implement at least [`inv`](@ref), [`identity`](@ref), [`compose`](@ref), and
[`translate_diff`](@ref).
"""
abstract type AbstractGroupManifold{O<:AbstractGroupOperation} <: Manifold end

"""
    GroupManifold{M<:Manifold,O<:AbstractGroupOperation} <: AbstractGroupManifold{O}

Decorator for a smooth manifold that equips the manifold with a group operation, thus making
it a Lie group. See [`AbstractGroupManifold`](@ref) for more details.

Group manifolds by default forward metric-related operations to the wrapped manifold.

# Constructor

    GroupManifold(manifold, op)
"""
struct GroupManifold{M<:Manifold,O<:AbstractGroupOperation} <: AbstractGroupManifold{O}
    manifold::M
    op::O
end

show(io::IO, G::GroupManifold) = print(io, "GroupManifold($(G.manifold), $(G.op))")

is_decorator_manifold(::GroupManifold) = Val(true)

is_decorator_group(::AbstractGroupManifold) = Val(true)
is_decorator_group(M::Manifold) = is_decorator_group(M, is_decorator_manifold(M))
is_decorator_group(M::Manifold, ::Val{true}) = is_decorator_group(M.manifold)
is_decorator_group(::Manifold, ::Val{false}) = Val(false)

"""
    base_group(M::Manifold) -> AbstractGroupManifold

Undecorate `M` until an `AbstractGroupManifold` is encountered.
Return an error if the [`base_manifold`](@ref) is reached without encountering a group.
"""
function base_group(M::Manifold)
    is_decorator_group(M) === Val(true) && return base_group(M.manifold)
    error("base_group: manifold $(typeof(M)) with base manifold $(typeof(base_manifold(M))) has no base group.")
end
base_group(G::AbstractGroupManifold) = G

# piping syntax for decoration
if VERSION ≥ v"1.3"
    (op::AbstractGroupOperation)(M::Manifold) = GroupManifold(M, op)
    (::Type{T})(M::Manifold) where {T<:AbstractGroupOperation} = GroupManifold(M, T())
end

########################
# GroupManifold forwards
########################

function check_tangent_vector(G::GroupManifold, p, X; kwargs...)
    return check_tangent_vector(G.manifold, p, X; kwargs...)
end
distance(G::GroupManifold, p, q) = distance(G.manifold, p, q)
exp(G::GroupManifold, p, X) = exp(G.manifold, p, X)
exp!(G::GroupManifold, q, p, X) = exp!(G.manifold, q, p, X)
injectivity_radius(G::GroupManifold) = injectivity_radius(G.manifold)
injectivity_radius(G::GroupManifold, p) = injectivity_radius(G.manifold, p)
function injectivity_radius(G::GroupManifold, p, method::AbstractRetractionMethod)
    return injectivity_radius(G.manifold, p, method)
end
inner(G::GroupManifold, p, X, Y) = inner(G.manifold, p, X, Y)
inverse_retract(G::GroupManifold, p, q) = inverse_retract(G.manifold, p, q)
function inverse_retract(G::GroupManifold, p, q, method::AbstractInverseRetractionMethod)
    return inverse_retract(G.manifold, p, q, method)
end
inverse_retract!(G::GroupManifold, X, p, q) = inverse_retract!(G.manifold, X, p, q)
function inverse_retract!(
    G::GroupManifold,
    X,
    p,
    q,
    method::AbstractInverseRetractionMethod,
)
    return inverse_retract!(G.manifold, X, p, q, method)
end
function inverse_retract!(G::GroupManifold, X, p, q, method::LogarithmicInverseRetraction)
    return inverse_retract!(G.manifold, X, p, q, method)
end
isapprox(G::GroupManifold, p, q; kwargs...) = isapprox(G.manifold, p, q; kwargs...)
isapprox(G::GroupManifold, p, X, w; kwargs...) = isapprox(G.manifold, p, X, w; kwargs...)
log(G::GroupManifold, p, q) = log(G.manifold, p, q)
log!(G::GroupManifold, X, p, q) = log!(G.manifold, X, p, q)
norm(G::GroupManifold, p, X) = norm(G.manifold, p, X)
project_point(G::GroupManifold, p) = project_point(G.manifold, p)
project_point!(G::GroupManifold, q, p) = project_point!(G.manifold, q, p)
project_tangent(G::GroupManifold, p, X) = project_tangent(G.manifold, p, X)
project_tangent!(G::GroupManifold, Y, p, X) = project_tangent!(G.manifold, Y, p, X)
retract(G::GroupManifold, p, X) = retract(G.manifold, p, X)
function retract(G::GroupManifold, p, X, method::AbstractRetractionMethod)
    return retract(G.manifold, p, X, method)
end
retract!(G::GroupManifold, q, p, X) = retract!(G.manifold, q, p, X)
function retract!(G::GroupManifold, q, p, X, method::AbstractRetractionMethod)
    return retract!(G.manifold, q, p, X, method)
end
function retract!(G::GroupManifold, q, p, X, method::ExponentialRetraction)
    return retract!(G.manifold, q, p, X, method)
end
function vector_transport_along!(G::GroupManifold, Y, p, X, c, args...)
    return vector_transport_along!(G.manifold, Y, p, X, c, args...)
end
function vector_transport_along(G::GroupManifold, p, X, c, args...)
    return vector_transport_along(G.manifold, p, X, c, args...)
end
function vector_transport_direction!(G::GroupManifold, Y, p, X, V, args...)
    return vector_transport_direction!(G.manifold, Y, p, X, V, args...)
end
function vector_transport_direction(G::GroupManifold, p, X, V, args...)
    return vector_transport_direction(G.manifold, p, X, V, args...)
end
function vector_transport_to!(G::GroupManifold, Y, p, X, q, args...)
    return vector_transport_to!(G.manifold, Y, p, X, q, args...)
end
function vector_transport_to(G::GroupManifold, p, X, q, args...)
    return vector_transport_to(G.manifold, p, X, q, args...)
end
zero_tangent_vector(G::GroupManifold, p) = zero_tangent_vector(G.manifold, p)
zero_tangent_vector!(G::GroupManifold, q, p) = zero_tangent_vector!(G.manifold, q, p)

###################
# Action directions
###################

"""
    ActionDirection

Direction of action on a manifold, either [`LeftAction`](@ref) or [`RightAction`](@ref).
"""
abstract type ActionDirection end

"""
    LeftAction()

Left action of a group on a manifold.
"""
struct LeftAction <: ActionDirection end

"""
    RightAction()

Right action of a group on a manifold.
"""
struct RightAction <: ActionDirection end

"""
    switch_direction(::ActionDirection)

Returns a [`RightAction`](@ref) when given a [`LeftAction`](@ref) and vice versa.
"""
switch_direction(::ActionDirection)
switch_direction(::LeftAction) = RightAction()
switch_direction(::RightAction) = LeftAction()

##################################
# General Identity element methods
##################################

@doc raw"""
    Identity(G::AbstractGroupManifold)

The group identity element $e ∈ G$.
"""
struct Identity{G<:AbstractGroupManifold}
    group::G
end

Identity(M::Manifold) = Identity(M, is_decorator_manifold(M))
Identity(M::Manifold, ::Val{true}) = Identity(M.manifold)
Identity(M::Manifold, ::Val{false}) = error("Identity not implemented for manifold $(M)")

show(io::IO, e::Identity) = print(io, "Identity($(e.group))")

(e::Identity)(p) = identity(e.group, p)

# To ensure allocate_result_type works
number_eltype(e::Identity) = Bool

copyto!(e::TE, ::TE) where {TE<:Identity} = e
copyto!(p, ::TE) where {TE<:Identity} = identity!(e.group, p, e)
copyto!(p::AbstractArray, e::TE) where {TE<:Identity} = identity!(e.group, p, e)

isapprox(p, e::Identity; kwargs...) = isapprox(e::Identity, p; kwargs...)
isapprox(e::Identity, p; kwargs...) = isapprox(e.group, e, p; kwargs...)
isapprox(e::E, ::E; kwargs...) where {E<:Identity} = true

function check_manifold_point(M::Manifold, p::Identity; kwargs...)
    if is_decorator_group(M) === Val(true)
        return check_manifold_point(base_group(M), p; kwargs...)
    end
    return DomainError(p, "The identity element $(p) does not belong to $(M).")
end
function check_manifold_point(G::GroupManifold, p::Identity; kwargs...)
    p === Identity(G) && return nothing
    return DomainError(p, "The identity element $(p) does not belong to $(G).")
end
function check_manifold_point(G::GroupManifold, p; kwargs...)
    return check_manifold_point(G.manifold, p; kwargs...)
end

##########################
# Group-specific functions
##########################

@doc raw"""
    inv(G::AbstractGroupManifold, p)

Inverse $p^{-1} ∈ G$ of an element $p ∈ G$, such that
$p \circ p^{-1} = p^{-1} \circ p = e ∈ G$.
"""
inv(M::Manifold, p) = inv(M, p, is_decorator_manifold(M))
inv(M::Manifold, p, ::Val{true}) = inv(M.manifold, p)
function inv(M::Manifold, p, ::Val{false})
    return error("inv not implemented on $(typeof(M)) for points $(typeof(p))")
end
function inv(G::AbstractGroupManifold, p)
    q = allocate_result(G, inv, p)
    return inv!(G, q, p)
end

inv!(M::Manifold, q, p) = inv!(M, q, p, is_decorator_manifold(M))
inv!(M::Manifold, q, p, ::Val{true}) = inv!(M.manifold, q, p)
function inv!(M::Manifold, q, p, ::Val{false})
    return error("inv! not implemented on $(typeof(M)) for points $(typeof(p))")
end

@doc raw"""
    identity(G::AbstractGroupManifold, p)

Identity element $e ∈ G$, such that for any element $p ∈ G$, $p \circ e = e \circ p = p$.
The returned element is of a similar type to `p`.
"""
identity(M::Manifold, p) = identity(M, p, is_decorator_manifold(M))
identity(M::Manifold, p, ::Val{true}) = identity(M.manifold, p)
function identity(M::Manifold, p, ::Val{false})
    return error("identity not implemented on $(typeof(M)) for points $(typeof(p))")
end
function identity(G::AbstractGroupManifold, p)
    y = allocate_result(G, identity, p)
    return identity!(G, y, p)
end

identity!(M::Manifold, q, p) = identity!(M, q, p, is_decorator_manifold(M))
identity!(M::Manifold, q, p, ::Val{true}) = identity!(M.manifold, q, p)
function identity!(M::Manifold, y, x, ::Val{false})
    return error("identity! not implemented on $(typeof(M)) for points $(typeof(y)) and $(typeof(x))")
end

isapprox(M::Manifold, p, e::Identity; kwargs...) = isapprox(M, e, p; kwargs...)
function isapprox(M::Manifold, e::Identity, p; kwargs...)
    is_decorator_group(M) === Val(true) && return isapprox(base_group(M), e, p; kwargs...)
    error("isapprox not implemented for manifold $(typeof(M)) and points $(typeof(e)) and $(typeof(p))")
end
function isapprox(M::Manifold, e::E, ::E; kwargs...) where {E<:Identity}
    is_decorator_group(M) === Val(true) && return isapprox(base_group(M), e, e; kwargs...)
    error("isapprox not implemented for manifold $(typeof(M)) and points $(typeof(e)) and $(typeof(e))")
end
function isapprox(G::GT, e::Identity{GT}, p; kwargs...) where {GT<:AbstractGroupManifold}
    return isapprox(G, identity(G, p), p; kwargs...)
end
function isapprox(
    ::GT,
    ::E,
    ::E;
    kwargs...,
) where {GT<:AbstractGroupManifold,E<:Identity{GT}}
    return true
end
function isapprox(G::GT, p, e::Identity{GT}; kwargs...) where {GT<:GroupManifold}
    return isapprox(G, e, p; kwargs...)
end
function isapprox(G::GT, e::Identity{GT}, p; kwargs...) where {GT<:GroupManifold}
    return isapprox(G, identity(G, p), p; kwargs...)
end
isapprox(::GT, ::E, ::E; kwargs...) where {GT<:GroupManifold,E<:Identity{GT}} = true

@doc raw"""
    compose(G::AbstractGroupManifold, x, y)

Compose elements $x,y ∈ G$ using the group operation $x \circ y$.
"""
compose(M::Manifold, p, q) = compose(M, p, q, is_decorator_manifold(M))
compose(M::Manifold, p, q, ::Val{true}) = compose(M.manifold, p, q)
function compose(M::Manifold, p, q, ::Val{false})
    return error("compose not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q))")
end
function compose(G::AbstractGroupManifold, p, q)
    x = allocate_result(G, compose, p, q)
    return compose!(G, x, p, q)
end

compose!(M::Manifold, x, p, q) = compose!(M, x, p, q, is_decorator_manifold(M))
compose!(M::Manifold, x, p, q, ::Val{true}) = compose!(M.manifold, x, p, q)
function compose!(M::Manifold, x, p, q, ::Val{false})
    return error("compose! not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q))")
end

_action_order(p, q, conv::LeftAction) = (p, q)
_action_order(p, q, conv::RightAction) = (q, p)

@doc raw"""
    translate(G::AbstractGroupManifold, p, q)
    translate(G::AbstractGroupManifold, p, q, conv::ActionDirection=LeftAction()])

For group elements $p,q ∈ G$, translate $q$ by $p$ with the specified convention, either
left $L_p$ or right $R_q$, defined as
```math
\begin{aligned}
L_p &: q ↦ p \circ q\\
R_p &: q ↦ q \circ p.
\end{aligned}
```
"""
translate(M::Manifold, p, q) = translate(M, p, q, LeftAction())
function translate(M::Manifold, p, q, conv::ActionDirection)
    return translate(M, p, q, conv, is_decorator_manifold(M))
end
function translate(M::Manifold, p, q, conv::ActionDirection, ::Val{true})
    return translate(M.manifold, p, q, conv)
end
function translate(M::Manifold, p, q, conv::ActionDirection, ::Val{false})
    return error("translate not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q)) and direction $(typeof(conv))")
end
function translate(G::AbstractGroupManifold, p, q, conv::ActionDirection)
    return compose(G, _action_order(p, q, conv)...)
end

translate!(M::Manifold, x, p, q) = translate!(M, x, p, q, LeftAction())
function translate!(M::Manifold, x, p, q, conv::ActionDirection)
    return translate!(M, x, p, q, conv, is_decorator_manifold(M))
end
function translate!(M::Manifold, x, p, q, conv::ActionDirection, ::Val{true})
    return translate!(M.manifold, x, p, q, conv)
end
function translate!(M::Manifold, x, p, q, conv::ActionDirection, ::Val{false})
    return error("translate! not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q)) and direction $(typeof(conv))")
end
function translate!(G::AbstractGroupManifold, x, p, q, conv::ActionDirection)
    return compose!(G, x, _action_order(p, q, conv)...)
end

@doc raw"""
    inverse_translate(G::AbstractGroupManifold, p, q)
    inverse_translate(G::AbstractGroupManifold, p, q, conv::ActionDirection=Left())

For group elements $p, q ∈ G$, inverse translate $q$ by $p$ with the specified convention,
either left $L_p^{-1}$ or right $R_p^{-1}$, defined as
```math
\begin{aligned}
L_p^{-1} &: q ↦ p^{-1} \circ q\\
R_p^{-1} &: q ↦ q \circ p^{-1}.
\end{aligned}
```
"""
inverse_translate(M::Manifold, p, q) = inverse_translate(M, p, q, LeftAction())
function inverse_translate(M::Manifold, p, q, conv::ActionDirection)
    return inverse_translate(M, p, q, conv, is_decorator_manifold(M))
end
function inverse_translate(M::Manifold, p, q, conv::ActionDirection, ::Val{true})
    return inverse_translate(M.manifold, p, q, conv)
end
function inverse_translate(M::Manifold, p, q, conv::ActionDirection, ::Val{false})
    return error("inverse_translate not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q)) and direction $(typeof(conv))")
end
function inverse_translate(G::AbstractGroupManifold, p, q, conv::ActionDirection)
    return translate(G, inv(G, p), q, conv)
end

inverse_translate!(M::Manifold, x, p, q) = inverse_translate!(M, x, p, q, LeftAction())
function inverse_translate!(M::Manifold, x, p, q, conv::ActionDirection)
    return inverse_translate!(M, x, p, q, conv, is_decorator_manifold(M))
end
function inverse_translate!(M::Manifold, x, p, q, conv::ActionDirection, ::Val{true})
    return inverse_translate!(M.manifold, x, p, q, conv)
end
function inverse_translate!(M::Manifold, x, p, q, conv::ActionDirection, ::Val{false})
    return error("inverse_translate! not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q)) and direction $(typeof(conv))")
end
function inverse_translate!(G::AbstractGroupManifold, x, p, q, conv::ActionDirection)
    return translate!(G, x, inv(G, p), q, conv)
end

@doc raw"""
    translate_diff(G::AbstractGroupManifold, p, q, X)
    translate_diff(G::AbstractGroupManifold, p, q, X, conv::ActionDirection=LeftAction())

For group elements $p, q ∈ G$ and tangent vector $X ∈ T_q G$, compute the action of the
differential of the translation by $p$ on $X$, written as $(\mathrm{d}τ_p)_q (X)$, with the
specified left or right convention. The differential transports vectors:
```math
\begin{aligned}
(\mathrm{d}L_p)_q (X) &: T_q G → T_{p \circ q} G\\
(\mathrm{d}R_p)_q (X) &: T_q G → T_{q \circ p} G\\
\end{aligned}
```
"""
translate_diff(M::Manifold, p, q, X) = translate_diff(M, p, q, X, LeftAction())
function translate_diff(M::Manifold, p, q, X, conv::ActionDirection)
    return translate_diff(M, p, q, X, conv, is_decorator_manifold(M))
end
function translate_diff(M::Manifold, p, q, X, conv::ActionDirection, ::Val{true})
    return translate_diff(M.manifold, p, q, X, conv)
end
function translate_diff(M::Manifold, p, q, X, conv::ActionDirection, ::Val{false})
    return error("translate_diff not implemented on $(typeof(G)) for elements $(typeof(p)) and $(typeof(q)), vector $(typeof(X)), and direction $(typeof(conv))")
end
function translate_diff(G::AbstractGroupManifold, p, q, X, conv::ActionDirection)
    pq = translate(G, p, q, conv)
    Y = zero_tangent_vector(G, pq)
    translate_diff!(G, Y, p, q, X, conv)
    return Y
end

function translate_diff!(M::Manifold, Y, p, q, X)
    return translate_diff!(M, Y, p, q, X, LeftAction())
end
function translate_diff!(M::Manifold, Y, p, q, X, conv::ActionDirection)
    return translate_diff!(M, Y, p, q, X, conv, is_decorator_manifold(M))
end
function translate_diff!(M::Manifold, Y, p, q, X, conv::ActionDirection, ::Val{true})
    return translate_diff!(M.manifold, Y, p, q, X, conv)
end
function translate_diff!(M::Manifold, Y, p, q, X, conv::ActionDirection, ::Val{false})
    return error("translate_diff! not implemented on $(typeof(M)) for elements $(typeof(Y)), $(typeof(p)) and $(typeof(q)), vector $(typeof(X)), and direction $(typeof(conv))")
end

@doc raw"""
    inverse_translate_diff(G::AbstractGroupManifold, p, q, X)
    inverse_translate_diff(G::AbstractGroupManifold, p, q, X, conv::ActionDirection=Left())

For group elements $p, q ∈ G$ and tangent vector $X ∈ T_q G$, compute the inverse of the
action of the differential of the translation by $p$ on $X$, written as
$((\mathrm{d}τ_p)_q)^{-1} (X) = (\mathrm{d}τ_{p^{-1}})_q (X)$, with the specified left or
right convention. The differential transports vectors as

```math
\begin{aligned}
((\mathrm{d}L_p)_q)^{-1} (X) &: T_q G → T_{p^{-1} \circ q} G\\
((\mathrm{d}R_p)_q)^{-1} (X) &: T_q G → T_{q \circ p^{-1}} G\\
\end{aligned}
```
"""
function inverse_translate_diff(M::Manifold, p, q, X)
    return inverse_translate_diff(M, p, q, X, LeftAction())
end
function inverse_translate_diff(M::Manifold, p, q, X, conv::ActionDirection)
    return inverse_translate_diff(M, p, q, X, conv, is_decorator_manifold(M))
end
function inverse_translate_diff(M::Manifold, p, q, X, conv::ActionDirection, ::Val{true})
    return inverse_translate_diff(M.manifold, p, q, X, conv)
end
function inverse_translate_diff(M::Manifold, p, q, X, conv::ActionDirection, ::Val{false})
    return error("inverse_translate_diff not implemented on $(typeof(M)) for elements $(typeof(p)) and $(typeof(q)), vector $(typeof(X)), and direction $(typeof(conv))")
end
function inverse_translate_diff(G::AbstractGroupManifold, p, q, X, conv::ActionDirection)
    return translate_diff(G, inv(G, p), q, X, conv)
end

function inverse_translate_diff!(M::Manifold, Y, p, q, X)
    return inverse_translate_diff!(M, Y, p, q, X, LeftAction())
end
function inverse_translate_diff!(M::Manifold, Y, p, q, X, conv::ActionDirection)
    return inverse_translate_diff!(M, Y, p, q, X, conv, is_decorator_manifold(M))
end
function inverse_translate_diff!(M::Manifold,
    Y,
    p,
    q,
    X,
    conv::ActionDirection,
    ::Val{true},
)
    return inverse_translate_diff!(M.manifold, Y, p, q, X, conv)
end
function inverse_translate_diff!(
    M::Manifold,
    Y,
    p,
    q,
    X,
    conv::ActionDirection,
    ::Val{false},
)
    return error("inverse_translate_diff! not implemented on $(typeof(M)) for elements $(typeof(Y)), $(typeof(p)) and $(typeof(q)), vector $(typeof(X)), and direction $(typeof(conv))")
end
function inverse_translate_diff!(
    G::AbstractGroupManifold,
    Y,
    p,
    q,
    X,
    conv::ActionDirection,
)
    return translate_diff!(G, Y, inv(G, p), q, X, conv)
end

#################################
# Overloads for AdditionOperation
#################################

"""
    AdditionOperation <: AbstractGroupOperation

Group operation that consists of simple addition.
"""
struct AdditionOperation <: AbstractGroupOperation end

const AdditionGroup = AbstractGroupManifold{AdditionOperation}

+(e::Identity{G}) where {G<:AdditionGroup} = e
+(::Identity{G}, p) where {G<:AdditionGroup} = p
+(p, ::Identity{G}) where {G<:AdditionGroup} = p
+(e::E, ::E) where {G<:AdditionGroup,E<:Identity{G}} = e

-(e::Identity{G}) where {G<:AdditionGroup} = e
-(::Identity{G}, p) where {G<:AdditionGroup} = -p
-(p, ::Identity{G}) where {G<:AdditionGroup} = p
-(e::E, ::E) where {G<:AdditionGroup,E<:Identity{G}} = e

*(e::Identity{G}, p) where {G<:AdditionGroup} = e
*(p, e::Identity{G}) where {G<:AdditionGroup} = e
*(e::E, ::E) where {G<:AdditionGroup,E<:Identity{G}} = e

zero(e::Identity{G}) where {G<:AdditionGroup} = e

identity(::AdditionGroup, p) = zero(p)

identity!(::AdditionGroup, q, p) = fill!(q, 0)

inv(::AdditionGroup, p) = -p

inv!(::AdditionGroup, q, p) = copyto!(q, -p)

compose(::AdditionGroup, p, q) = p + q

function compose!(::GT, x, p, q) where {GT<:AdditionGroup}
    p isa Identity{GT} && return copyto!(x, q)
    q isa Identity{GT} && return copyto!(x, p)
    x .= p .+ q
    return x
end

translate_diff(::AdditionGroup, p, q, X, ::ActionDirection) = X

translate_diff!(::AdditionGroup, Y, p, q, X, ::ActionDirection) = copyto!(Y, X)

inverse_translate_diff(::AdditionGroup, p, q, X, ::ActionDirection) = X

function inverse_translate_diff!(::AdditionGroup, Y, p, q, X, ::ActionDirection)
    return copyto!(Y, X)
end

#######################################
# Overloads for MultiplicationOperation
#######################################

"""
    MultiplicationOperation <: AbstractGroupOperation

Group operation that consists of multiplication.
"""
struct MultiplicationOperation <: AbstractGroupOperation end

const MultiplicationGroup = AbstractGroupManifold{MultiplicationOperation}

*(e::Identity{G}) where {G<:MultiplicationGroup} = e
*(::Identity{G}, p) where {G<:MultiplicationGroup} = p
*(p, ::Identity{G}) where {G<:MultiplicationGroup} = p
*(e::E, ::E) where {G<:MultiplicationGroup,E<:Identity{G}} = e

/(p, ::Identity{G}) where {G<:MultiplicationGroup} = p
/(::Identity{G}, p) where {G<:MultiplicationGroup} = inv(p)
/(e::E, ::E) where {G<:MultiplicationGroup,E<:Identity{G}} = e

\(p, ::Identity{G}) where {G<:MultiplicationGroup} = inv(p)
\(::Identity{G}, p) where {G<:MultiplicationGroup} = p
\(e::E, ::E) where {G<:MultiplicationGroup,E<:Identity{G}} = e

inv(e::Identity{G}) where {G<:MultiplicationGroup} = e

one(e::Identity{G}) where {G<:MultiplicationGroup} = e

transpose(e::Identity{G}) where {G<:MultiplicationGroup} = e

LinearAlgebra.det(::Identity{<:MultiplicationGroup}) = 1

LinearAlgebra.mul!(q, e::Identity{G}, p) where {G<:MultiplicationGroup} = copyto!(q, p)
LinearAlgebra.mul!(q, p, e::Identity{G}) where {G<:MultiplicationGroup} = copyto!(q, p)
function LinearAlgebra.mul!(q, e::E, ::E) where {G<:MultiplicationGroup,E<:Identity{G}}
    return identity!(e.group, q, e)
end

identity(::MultiplicationGroup, p) = one(p)

function identity!(G::GT, q, p) where {GT<:MultiplicationGroup}
    isa(p, Identity{GT}) || return copyto!(q, one(p))
    error("identity! not implemented on $(typeof(G)) for points $(typeof(q)) and $(typeof(p))")
end
identity!(::MultiplicationGroup, q::AbstractMatrix, p) = copyto!(q, I)

inv(::MultiplicationGroup, p) = inv(p)

inv!(G::MultiplicationGroup, q, p) = copyto!(q, inv(G, p))

compose(::MultiplicationGroup, p, q) = p * q

# TODO: z might alias with x or y, we might be able to optimize it if it doesn't.
compose!(::MultiplicationGroup, x, p, q) = copyto!(x, p * q)

inverse_translate(::MultiplicationGroup, p, q, ::LeftAction) = p \ q
inverse_translate(::MultiplicationGroup, p, q, ::RightAction) = q / p

function inverse_translate!(G::MultiplicationGroup, x, p, q, conv::ActionDirection)
    return copyto!(x, inverse_translate(G, p, q, conv))
end