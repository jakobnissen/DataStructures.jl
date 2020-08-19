abstract type LinkedList{T} end

Base.eltype(::Type{<:LinkedList{T}}) where T = T

mutable struct Nil{T} <: LinkedList{T}
end
Nil() = Nil{Any}()

mutable struct Cons{T} <: LinkedList{T}
    head::T
    tail::LinkedList{T}
end

head(x::Cons) = x.head
tail(x::Cons) = x.tail

==(x::Nil, y::Nil) = true
==(x::Cons, y::Cons) = (x.head == y.head) && (x.tail == y.tail)

function show(io::IO, l::LinkedList{T}) where T
    if isa(l, Nil)
        if T === Any
            print(io, "Nil()")
        else
            print(io, "Nil{", T, "}()")
        end
    else
        print(io, "list(")
        show(io, head(l))
        for t in tail(l)
            print(io, ", ")
            show(io, t)
        end
        print(io, ")")
    end
end

list() = Nil()

function list(elts...)
    l = Nil()
    for i in length(elts):-1:1
        l = Cons(elts[i],l)
    end
    return l
end

function list(elts::T...) where T
    l = Nil{T}()
    for i in length(elts):-1:1
        l = Cons(elts[i],l)
    end
    return l
end

length(l::Nil) = 0

function length(l::Cons)
    n = 0
    for i in l
        n += 1
    end
    return n
end

map(f::Base.Callable, l::Nil) = l

function map(f::Base.Callable, l::Cons{T}) where T
    first = f(l.head)
    l2 = Cons(first, Nil{typeof(first) <: T ? T : typeof(first)}())
    for h in l.tail
        l2 = Cons(f(h), l2)
    end
    reverse(l2)
end

function filter(f::Function, l::LinkedList{T}) where T
    l2 = Nil{T}()
    for h in l
        if f(h)
            l2 = Cons(h, l2)
        end
    end
    reverse(l2)
end

function reverse(l::LinkedList{T}) where T
    l2 = Nil{T}()
    for h in l
        l2 = Cons(h, l2)
    end
    return l2
end

copy(l::Nil) = l

function copy(l::Cons)
    l2 = reverse(reverse(l))
end

cat(lst::LinkedList) = lst

function cat(lst::LinkedList, lsts::LinkedList...)
    T = typeof(lst).parameters[1]
    n = length(lsts)
    for i = 1:n
        T2 = typeof(lsts[i]).parameters[1]
        T = typejoin(T, T2)
    end

    l2 = Nil{T}()
    for h in lst
        l2 = Cons(h, l2)
    end

    for i = 1:n
        for h in lsts[i]
            l2 = Cons(h, l2)
        end
    end

    reverse(l2)
end

iterate(l::LinkedList, ::Nil) = nothing
function iterate(l::LinkedList, state::Cons = l)
    state.head, state.tail
end
