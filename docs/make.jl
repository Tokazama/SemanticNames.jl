using SemanticNames
using Documenter

makedocs(;
    modules=[SemanticNames],
    authors="Zachary P. Christensen <zchristensen7@gmail.com> and contributors",
    repo="https://github.com/Tokazama/SemanticNames.jl/blob/{commit}{path}#L{line}",
    sitename="SemanticNames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Tokazama.github.io/SemanticNames.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Tokazama/SemanticNames.jl",
)
