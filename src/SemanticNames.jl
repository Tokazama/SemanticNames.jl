module SemanticNames

using Static
using Static: static, True, False, StaticSymbol

export @defname

struct IsName{name} <: Function
    IsName{name}() where {name} = new{name::Symbol}()
end

(isn::IsName{name})(x::Symbol) where {name} = isn(static(x))
(isn::IsName{name})(x::Tuple{Vararg{Symbol}}) where {name} = isn(static(x))
(isn::IsName{name})(x::Tuple{Vararg{StaticSymbol}}) where {name} = isn(typeof(x))
(isn::IsName{name})(x::StaticSymbol) where {name} = isn(typeof(x))
(isn::IsName{name})(::Type{StaticSymbol{sym}}) where {name,sym} = False()
(isn::IsName{name})(::Type{StaticSymbol{name}}) where {name} = True()
(isn::IsName{name})(::Type{IsName{sym}}) where {name,sym} = isn(static(sym))

macro name_str(s) :(SemanticName{$(Expr(:quote, Symbol(s)))}) end

macro defname(name)
    is_name = esc(Symbol(:is_, name))
    is_not_name = esc(Symbol(:is_not_, name))

    quote
        const $is_name = IsName{$(QuoteNode(name))}()

        macro $is_name(name)
            new_is_name($(QuoteNode(name)), name)
        end

        macro $is_name(name, ns...)
            new_is_name($(QuoteNode(name)), name, ns...)
        end

        macro $is_not_name(name)
            new_is_not_name($(QuoteNode(name)), name)
        end

        macro $is_not_name(name, ns...)
            new_is_not_name($(QuoteNode(name)), name, ns...)
        end

        nothing
    end
end

function new_is_name(is_name, name)
    @eval begin
        (::IsName{$(QuoteNode(is_name))})(::Type{StaticSymbol{$name}}) = True()
        nothing
    end
end

function new_is_name(is_name, name, ns...)
    T = Expr(:curly, :Tuple)
    push!(T.args, Expr(:curly, :StaticSymbol, name))
    for n in ns
        push!(T.args, Expr(:curly, :StaticSymbol, n))
    end
    @eval begin
        (::IsName{$(QuoteNode(is_name))})(::Type{$T}) = True()
        nothing
    end
end

function new_is_not_name(is_name, name)
    @eval begin
        (::IsName{$(QuoteNode(is_name))})(::Type{StaticSymbol{$name}}) = False()
        nothing
    end
end

function new_is_note_name(is_name, name, ns...)
    T = Expr(:curly, :Tuple)
    push!(T.args, Expr(:curly, :StaticSymbol, name))
    for n in ns
        push!(T.args, Expr(:curly, :StaticSymbol, n))
    end
    @eval begin
        (::IsName{$(QuoteNode(is_name))})(::Type{$T}) = False()
        nothing
    end
end


function Base.show(io::IO, ::MIME"text/plain", isn::IsName{name}) where {name}
    fxnname = Symbol(:is_, name)
    nmethods = length(methods(isn))
    if nmethods == 1
        print(io, "$fxnname (generic function with 1 method)")
    else
        print(io, "$fxnname (generic function with $nmethods methods)")
    end
end

end

