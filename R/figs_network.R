#' Bipartite network connecting users and projects
#'
#' Plot interactions between `user`s and `project`s.
#' User ids are supposed to be random numbers (e.g. 6, 19, 40) and not actual user ids,
#' but to keep the display cleaner when there is potentially *a lot* of users, the ids are hidden by default.
#' Numbers can be confusing (apparent by questions like: "Does '19' mean the number of users?" -- no, that's just the id).
#'
#' Some tips:
#' For scaling, depending on network size, it might be best with experimenting with other `*_node_size` numbers.
#'
#' @inheritParams plot_sankey_status
#' @param hide_user_id Don't label user nodes with their ids. See details.
#' @param project_node_size Node size of porject nodes.
#' @param user_node_size Node size of user nodes.
#' @import igraph
#' @export
plot_bipartite <- function(data,
                           project_node_size = 30,
                           user_node_size = 20,
                           hide_user_id = TRUE) {
  
  project_node_color <- "#6fbeb8"
    user_node_color <- "#af316c"
      g <- graph.data.frame(data, directed = TRUE)
      V(g)$type <- igraph::bipartite.mapping(g)$type
      V(g)$color <- ifelse(V(g)$type,  project_node_color, user_node_color)
      user_node_label <- if(hide_user_id) user_node_color else "white" # obfuscate by using same color as bg
        V(g)$label.color <-  ifelse(V(g)$type, "black", user_node_label)
        V(g)$label.family <- "sans"
        V(g)$size <- ifelse(V(g)$type, project_node_size, user_node_size)
        plot(g, layout = layout_with_fr)
        # return(g)
}
