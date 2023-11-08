#' Project breakdown flowchart template
#'
#' Generate a GraphViz flowchart breaking down projects into groupings based on data status.
#' Intended for use as a starting point.
#'
#' @param total Total number.
#' @param available Number available from total.
#' @param reprocessed Number reprocessed, which can come from available or under embargo.
#' @param unreleased Number of unreleased from total.
#' @param under_embargo Number under embargo.
#' @param pending Number where data is still being generated.
#' @param not_expected Number where data not expected.
#' @param direction Chart orientation (defaults to "TD" top-down, alternative is "LR" left-right).
#' @export
#'
project_flowchart_template <- function(
    total,
    available,
    reprocessed,
    unreleased,
    under_embargo,
    pending,
    not_expected,
    direction = c("TD", "LR")) {
  
  direction <- match.arg(direction)
  glue::glue(
    'digraph {

  rankdir={{direction}};

  node [shape="box" fontname="Helvetica" style=filled fontcolor="white"];
  edge [fontname="Helvetica"];
  {rank = same; Available; DataUnreleased; DataNotExpected;}

  Total[label = "Total projects\n(n={{total}})" fillcolor="#392965"]
  Available[label = "Data Partially Available\nor Available\n(n={{available}})" fillcolor="#125e81"]
  Reprocessed[label = "Data Reprocessed\n(n={{reprocessed}})" fillcolor="#00c87a"]
  DataUnreleased[label = "Data Unreleased\n(n={{unreleased}})" fillcolor="#af316c"]
  UnderEmbargo[label = "Data Under Embargo\n(n={{under_embargo}})" fillcolor="#e9b4ce" fontcolor="black"]
  DataPending[label = "Data Pending\n(n={{pending}})" fillcolor="#f2d7a6" fontcolor="black"]
  DataNotExpected[label = "Data Not Expected\n(n={{not_expected}})" fillcolor="#636E83"]

  Total->Available;
  Available->Reprocessed;
  Total->DataUnreleased;
  DataUnreleased->UnderEmbargo;
  DataUnreleased->DataPending;
  Total->DataNotExpected;
  UnderEmbargo->Reprocessed;
  }', .open = "{{", .close = "}}")
  
}


#' Add additional component to flowchart
#'
#' Graphviz partial template for representing a component with
#' qualification, acceptance, and in-preparation states.
#'
#' @param qualify Number for qualification of something.
#' @param accepted Number for accepted.
#' @param in_preparation Summary number for in preparation.
#' @param component Prefix for component id, defaults to "cBP" for cBioPortal
#' @param connector Connecting edge if adding this to an existing plot; use NULL for stand-alone plot.
#' @export
flowchart_component_template <- function(
    qualify,
    accepted,
    in_preparation,
    component = "cBP",
    connector = "Reprocessed->cBP_qualify;"
) {
  
  glue::glue('
  {component}_qualify[label = "Qualify for cBioPortal\n(n={qualify})" fillcolor="black"]
  {component}_accepted[label = "Accepted to\ncBioPortal\n(n={accepted})" fillcolor="#748dcd"]
  {component}_prep[label = "Preparing for\ncBioPortal\n(n={in_preparation})" fillcolor="#748dcd"]

  {connector}
  {component}_qualify->{component}_accepted;
  {component}_qualify->{component}_prep;
  ')
}
