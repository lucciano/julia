# module Pkg2

function parse_requires(readable)
    reqs = Requires()
    for line in eachline(readable)
        ismatch(r"^\s*(?:#|$)", line) && continue
        fields = split(replace(line, r"#.*$", ""))
        pkg = shift!(fields)
        if !all(_->ismatch(Base.VERSION_REGEX,_), fields)
            error("invalid requires entry for $pkg: $fields")
        end
        vers = [convert(VersionNumber,_) for _ in fields]
        if !issorted(vers)
            error("invalid requires entry for $pkg: $vers")
        end
        ivals = VersionInterval[]
        if isempty(vers)
            push!(ivals, VersionInterval(typemin(VersionNumber),typemax(VersionNumber)))
        else
            isodd(length(vers)) && push!(vers, typemax(VersionNumber))
            while !isempty(vers)
                push!(ivals, VersionInterval(shift!(vers), shift!(vers)))
            end
        end
        vset = VersionSet(ivals)
        reqs[pkg] = haskey(reqs,pkg) ? intersect(reqs[pkg],vset) : vset
    end
    return reqs
end
parse_requires(file::String) = isfile(file) ? open(parse_requires,file) : Requires()

function merge_requires!(A::Requires, B::Requires)
    for (pkg,vers) in B
        A[pkg] = haskey(A,pkg) ? intersect(A[pkg],vers) : vers
    end
    return A
end

function available(names=readdir("METADATA"))
    pkgs = Dict{ByteString,Dict{VersionNumber,Available}}()
    for pkg in names
        isfile("METADATA", pkg, "url") || continue
        versdir = joinpath("METADATA", pkg, "versions")
        isdir(versdir) || continue
        for ver in readdir(versdir)
            ismatch(Base.VERSION_REGEX, ver) || continue
            isfile(versdir, ver, "sha1") || continue
            haskey(pkgs,pkg) || (pkgs[pkg] = eltype(pkgs)[2]())
            pkgs[pkg][convert(VersionNumber,ver)] = Available(
                readchomp(joinpath(versdir, ver, "sha1")),
                parse_requires(joinpath(versdir, ver, "requires"))
            )
        end
    end
    return pkgs
end
available(pkg::String) = available([pkg])[pkg]

isinstalled(pkg::String) =
    pkg != "METADATA" && pkg != "REQUIRE" && isfile(pkg, "src", "$pkg.jl")

function isfixed(pkg::String, avail::Dict=available(pkg))
    isinstalled(pkg) || error("$pkg is not an installed package.")
    isfile("METADATA", pkg, "url") || return true
    ispath(pkg, ".git") || return true
    cd(pkg) do
        Git.dirty() && return true
        Git.attached() && return true
        head = Git.head()
        for (ver,info) in avail
            Git.is_ancestor_of(head, info.sha1) && return false
        end
        return true
    end
end

function installed_version(pkg::String, avail::Dict=available(pkg))
    head = cd(Git.head,pkg)
    lo = typemin(VersionNumber)
    hi = typemin(VersionNumber)
    for (ver,info) in avail
        head == info.sha1 && return ver
        base = cd(()->readchomp(`git merge-base $head $(info.sha1)`), pkg)
        if base == head # Git.is_ancestor_of(head, info.sha1)
            lo = max(lo,ver)
        elseif base == info.sha1 # Git.is_ancestor_of(info.sha1, head)
            hi = max(hi,ver)
        end
    end
    typemin(VersionNumber) < lo ?
        VersionNumber(lo.major, lo.minor, lo.patch, ("",), ()) :
        VersionNumber(hi.major, hi.minor, hi.patch, (), ("",))
end

function requires_path(pkg::String, avail::Dict=available(pkg))
    cd(pkg) do
        Git.dirty("REQUIRE") && return joinpath(pkg, "REQUIRE")
        head = Git.head()
        for (ver,info) in avail
            if head == info.sha1
                return joinpath("METADATA", pkg, "versions", string(ver), "requires")
            end
        end
        return joinpath(pkg, "REQUIRE")
    end
end
requires_dict(pkg::String, avail::Dict=available(pkg)) =
    parse_requires(requires_path(pkg,avail))

function installed(avail::Dict=available())
    pkgs = Dict{ByteString,Installed}()
    for pkg in readdir()
        isinstalled(pkg) || continue
        availpkg = avail[pkg]
        pkgs[pkg] = !isfixed(pkg,availpkg) ? Free() :
            Fixed(installed_version(pkg,availpkg), requires_dict(pkg,availpkg))
    end
    pkgs["julia"] = Fixed(VERSION)
    return pkgs
end

function requirements(reqs::Dict, inst::Dict)
    fixed = filter((p,f)->isa(f,Fixed), inst)
    for (p1,f1) in fixed
        if !satisfies(p1, f1.version, reqs)
            warn("$p1 is fixed at $(f1.version) conflicting with top-level requirement: $(reqs[p1])")
        end
        for (p2,f2) in fixed
            if !satisfies(p1, f1.version, f2.requires)
                warn("$p1 is fixed at $(f1.version) conflicting with requirement for $p2: $(f2.requires[p1])")
            end
            merge_requires!(reqs,f2.requires)
        end
        delete!(reqs,p1)
    end
    reqs
end
requirements() = requirements(parse_requires("REQUIRE"), installed())

function dependencies(avail::Dict, inst::Dict)
    fixed = filter((p,f)->isa(f,Fixed), inst)
    for (pkg,vers) in avail
        for (ver,avail) in vers
            
        end
    end
end

# end # module
