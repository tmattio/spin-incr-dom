(name spin-incr-dom)
(description "Single page application with Js_of_ocaml with Incr_dom")

(config project_name
  (input (prompt "Project name")))

(config project_slug
  (input (prompt "Project slug"))
  (default (slugify :project_name))
  (rules
    ("The project slug must be lowercase and contain ASCII characters and '-' only."
      (eq :project_slug (slugify :project_slug)))))

(config project_snake
  (default (snake_case :project_slug)))

(config project_description
  (input (prompt "Description"))
  (default "A short, but powerful statement about your project")
  (rules
    ("The last character of the description cannot be a \".\" to comply with Opam"
      (neq . (last_char :project_description)))))

(config username
  (input (prompt "Name of the author")))

(config github_username
  (input (prompt "Github username"))
  (default :username))

(config npm_username
  (input (prompt "NPM username"))
  (default :username))

(config syntax
  (select
    (prompt "Which syntax do you use?")
    (values OCaml Reason)))

(config package_manager
  (select
    (prompt "Which package manager do you use?")
    (values Opam Esy))
  (default (if (eq :syntax Reason) Esy Opam)))

(config ci_cd
  (select
    (prompt "Which CI/CD do you use")
    (values Github None))
  (default Github))

(config css_framework
  (select
    (prompt "Which CSS framework do you use?")
    (values TailwindCSS None))
  (default None))

(ignore 
  (files asset/tailwind.config.js)
  (enabled_if (neq :css_framework TailwindCSS)))

(ignore 
  (files asset/static/main.css)
  (enabled_if (eq :css_framework TailwindCSS)))

(ignore 
  (files .ocamlformat)
  (enabled_if (neq :syntax OCaml)))

(ignore
  (files github/*)
  (enabled_if (neq :ci_cd Github)))

(ignore
  (files esy.json)
  (enabled_if (neq :package_manager Esy)))

(ignore
  (files asset/package.json Makefile)
  (enabled_if (neq :package_manager Opam)))

; We need to do this because Dune won't copy .github during build
(post_gen
  (actions 
    (run mv github .github))
  (enabled_if (eq :ci_cd Github)))

(post_gen
  (actions 
    (run esy install)
    (run esy dune build))
  (message "🎁  Installing packages. This might take a couple minutes.")
  (enabled_if (eq :package_manager Esy)))

(post_gen
  (actions 
    (run make dev)
    (run make build))
  (message "🎁  Installing packages. This might take a couple minutes.")
  (enabled_if (eq :package_manager Opam)))

(post_gen
  (actions
    (refmt bin/*.ml bin/*.mli lib/*.ml lib/*.mli test/*.ml test/*.mli bin/*/*.ml bin/*/*.mli))
  (enabled_if (eq :syntax Reason)))

(example_commands
  (commands 
    ("esy install" "Download and lock the dependencies.")
    ("esy build" "Build the dependencies and the project.")
    ("esy test" "Starts the test runner."))
  (enabled_if (eq :package_manager Esy)))

(example_commands
  (commands
    ("make dev" "Download runtime and development dependencies.")
    ("make build" "Build the dependencies and the project.")
    ("make test" "Starts the test runner."))
  (enabled_if (eq :package_manager Opam)))
