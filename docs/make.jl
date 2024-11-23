using StreamCallbacksExt
using Documenter

DocMeta.setdocmeta!(StreamCallbacksExt, :DocTestSetup, :(using StreamCallbacksExt); recursive=true)

makedocs(;
    modules=[StreamCallbacksExt],
    authors="SixZero <havliktomi@hotmail.com> and contributors",
    repo="https://github.com/SixZero/StreamCallbacksExt.jl/blob/{commit}{path}#{line}",
    sitename="StreamCallbacksExt.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SixZero.github.io/StreamCallbacksExt.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SixZero/StreamCallbacksExt.jl",
    devbranch="master",
)
