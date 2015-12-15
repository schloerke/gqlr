

build_js_file_location <- function() {
  file.path("JS", "build.js")
}

clean_npm <- function() {
  unlink("node_modules", recursive = TRUE)
}
clean_js_build <- function() {
  file.remove(build_js_file_location())
}

build_js <- function(force = FALSE) {

  if (force || !file.exists(build_js_file_location())) {
    if (length(system("which node", intern = TRUE)) == 0) {
      stop("install node.js")
    }

    if (!dir.exists(file.path("node_modules", "browserify"))) {
      cat("installing browserify...\n\n")
      system("npm install browserify")
      cat("\n\nbrowserify installed!\n")
    }
    if (!dir.exists(file.path("node_modules", "graphql"))) {
      cat("installing graphql...\n\n")
      system("npm install graphql")
      cat("\n\ngraphql installed!\n")
    }

    cat("building graphqlr.js\n")
    system(
      paste(
        file.path("node_modules", ".bin", "browserify"),
        file.path("JS", "graphqlr.js"),
        "-o",
        build_js_file_location(),
        sep = " "
      )
    )
    cat("built!\n")
  }

  return(build_js_file_location())
}
# build_js()

eval_json <- function(str = test_string()) {
  ct <- javascript_context()
  ret <- ct$call("stringify", str)
  rjson::fromJSON(ret)
}

# eval_json()
# eval_json(test_string("kitchen"))


#' @export
javascript_context <- #memoise::memoise(
  function() {
    ct <- V8::new_context(global = "window")

    build_js()
    ct$source(build_js_file_location())

    ct
  }
#)
