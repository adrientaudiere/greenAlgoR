#' Visualize a `targets` pipeline as a resource-annotated network
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Draw the dependency graph of a \code{targets} pipeline with
#' \code{ggnetwork}, encoding the per-target computational cost as visual
#' aesthetics: node **size** and **color** map to a resource metric (runtime
#' in seconds or output size in bytes) and each edge **width** maps to the
#' runtime of its downstream target. This gives a quick, at-a-glance picture of
#' where a pipeline spends its time and storage, complementing the aggregated
#' figures of \code{\link{ga_targets}()}.
#'
#' The per-target metrics (`seconds`, `bytes`) are taken directly from
#' \code{targets::tar_network()}, so no separate \code{tar_meta()} call is
#' needed.
#'
#' @param store (character, default `targets::tar_config_get("store")`) Path to
#'   the targets data store. See \code{?targets::tar_network()}.
#' @param script (character, default `targets::tar_config_get("script")`) Path to
#'   the target script file (e.g. `_targets.R`). Required by
#'   \code{targets::tar_network()} to build the pipeline graph. See
#'   \code{?targets::tar_network()}.
#' @param tar_network_raw (optional list) A precomputed
#'   \code{targets::tar_network()} result (a list with `$vertices` and
#'   `$edges`). When supplied, `store` is ignored. Useful for tests, custom
#'   analyses, or when the pipeline metadata is already loaded.
#' @param size_by (character, default "seconds") Vertex attribute mapped to node
#'   size. One of "seconds" (runtime) or "bytes" (output size).
#' @param color_by (character, default "bytes") Vertex attribute mapped to node
#'   color. One of "seconds", "bytes" or "status" (the target build status).
#' @param layout (character, default "fruchtermanreingold") A network layout
#'   name passed to \code{ggnetwork::ggnetwork()}.
#' @param label (logical, default TRUE) Draw the target names next to the nodes.
#' @param arrow_gap (numeric, default 0.02) Gap left between the arrow head and
#'   the target node, passed to \code{ggnetwork::ggnetwork()}.
#' @param ... Additional arguments passed on to
#'   \code{ggnetwork::ggnetwork()}.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object showing the pipeline network.
#' @export
#' @author Adrien Taudière
#' @seealso \code{\link{ga_targets}()}, \code{\link{ga_autometric_plot}()}
#' @examples
#' targets::tar_dir({ # tar_dir() runs code from a temp dir for CRAN.
#'   targets::tar_script(
#'     {
#'       list(
#'         targets::tar_target(raw, rnorm(1e5)),
#'         targets::tar_target(scaled, raw * 2),
#'         targets::tar_target(summ, mean(scaled))
#'       )
#'     },
#'     ask = FALSE
#'   )
#'   targets::tar_make(reporter = "silent")
#'   net <- targets::tar_network(targets_only = TRUE)
#'   ga_targets_network(tar_network_raw = net)
#' })
ga_targets_network <- function(
  store = targets::tar_config_get("store"),
  script = targets::tar_config_get("script"),
  tar_network_raw = NULL,
  size_by = "seconds",
  color_by = "bytes",
  layout = "fruchtermanreingold",
  label = TRUE,
  arrow_gap = 0.02,
  ...
) {
  if (!requireNamespace("ggnetwork", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg ggnetwork} is required for {.fn ga_targets_network}.",
      "i" = "Install it with {.code install.packages(\"ggnetwork\")}."
    ))
  }
  if (!requireNamespace("network", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg network} is required for {.fn ga_targets_network}.",
      "i" = "Install it with {.code install.packages(\"network\")}."
    ))
  }
  size_by <- match.arg(size_by, c("seconds", "bytes"))
  color_by <- match.arg(color_by, c("bytes", "seconds", "status"))

  net <- if (is.null(tar_network_raw)) {
    targets::tar_network(targets_only = TRUE, store = store, script = script)
  } else {
    tar_network_raw
  }
  verts <- as.data.frame(net$vertices)
  edges <- as.data.frame(net$edges)

  if (nrow(verts) == 0) {
    cli::cli_abort(
      "The pipeline has no targets to display. Has {.fn targets::tar_make} been run?"
    )
  }

  vert_names <- verts$name
  g <- network::network.initialize(length(vert_names), directed = TRUE)
  network::network.vertex.names(g) <- vert_names
  network::set.vertex.attribute(g, "seconds", as.numeric(verts$seconds))
  network::set.vertex.attribute(g, "bytes", as.numeric(verts$bytes))
  network::set.vertex.attribute(g, "status", as.character(verts$status))

  if (nrow(edges) > 0) {
    tail_id <- match(edges$from, vert_names)
    head_id <- match(edges$to, vert_names)
    network::add.edges(g, tail = as.list(tail_id), head = as.list(head_id))
    # Edge weight = runtime of the downstream (destination) target.
    network::set.edge.attribute(
      g,
      "runtime",
      as.numeric(verts$seconds[head_id])
    )
  }

  net_df <- ggnetwork::ggnetwork(
    g,
    layout = layout,
    arrow.gap = arrow_gap,
    ...
  )

  p <- ggplot2::ggplot(
    net_df,
    ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend)
  )

  if (nrow(edges) > 0) {
    p <- p +
      ggnetwork::geom_edges(
        ggplot2::aes(linewidth = .data$runtime),
        colour = "grey60",
        arrow = ggplot2::arrow(length = ggplot2::unit(6, "pt"), type = "closed")
      ) +
      ggplot2::scale_linewidth_continuous(
        name = "Runtime (s)",
        range = c(0.3, 2)
      )
  }

  p <- p +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        size = .data[[size_by]],
        colour = .data[[color_by]]
      )
    ) +
    ggplot2::scale_size_continuous(
      name = if (size_by == "seconds") {
        "Runtime (s)"
      } else {
        "Output (bytes)"
      },
      range = c(2, 10)
    )

  if (color_by == "status") {
    p <- p + ggplot2::scale_colour_brewer(name = "Status", palette = "Set2")
  } else {
    p <- p +
      ggplot2::scale_colour_viridis_c(
        name = if (color_by == "seconds") {
          "Runtime (s)"
        } else {
          "Output (bytes)"
        }
      )
  }

  if (label) {
    p <- p +
      ggnetwork::geom_nodetext(
        ggplot2::aes(label = .data$vertex.names),
        vjust = -0.8,
        size = 3
      )
  }

  p +
    ggnetwork::theme_blank()
}
