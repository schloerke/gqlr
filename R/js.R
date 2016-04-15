

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
      system("npm install browserify@13.0.0")
      cat("\n\nbrowserify installed!\n")
    }
    if (!dir.exists(file.path("node_modules", "graphql"))) {
      cat("installing graphql...\n\n")
      system("npm install graphql@0.5.0")
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



#' @export
javascript_context <- #memoise::memoise(
  function() {
    ct <- V8::new_context(global = "window")

    build_js()
    ct$source(build_js_file_location())

    ct
  }
#)


# load_all(); test_string() %>% eval_json()
clean_json <- function(obj, ...) {
  UseMethod("clean_json")
}

clean_json.list <- function(obj, ...) {
  # remove all "loc" variables.  take up space
  obj$loc <- NULL
  kind <- obj$kind
  ret <- lapply(obj, clean_json)
  if (! is.null(kind)) {
    class(ret) <- kind
  }
  ret
}
clean_json.default <- function(obj, ...) {
  obj
}

eval_json <- function(str = test_string()) {
  ct <- javascript_context()
  ct$call("stringify", str) %>%
    rjson::fromJSON() %>%
    clean_json()
}


# eval_json()
# eval_json(test_string("kitchen"))
