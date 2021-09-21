using Documenter, MadNLP

makedocs(
    sitename = "MadNLP.jl",
    modules = [MadNLP],
    authors = "Sungho Shin, Francois Pacaud, and contributors.",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/extra_styles.css","assets/favicon.ico"],
        sidebar_sitename = false,
    ),
    pages = [
        "Home" => "index.md",
        "User Guide" => [
            "Getting Started"=>"guide.md",
            "Interfaces"=>"interfaces.md",
            "Extensions"=>"extensions.md",
            "Options" => "options.md",
            "Outputs" => "outputs.md",
        ],
        "Algorithms" => "algorithms.md",
        "Examples" =>[
            
        ],
        "Citing MadNLP" => "citation.md",
        "Contributing" => "contrib.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/sshin23/MadNLP.jl.git"
)
