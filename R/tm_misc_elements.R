#' Small multiples
#' 
#' Creates a \code{\link{tmap-element}} that specifies facets (small multiples). Small multiples can be created in two ways: 1) by specifying the \code{by} argument with one or two variable names, by which the data is grouped, 2) by specifying multiple variable names in any of the aesthetic argument of the layer functions (for instance, the argument \code{col} in \code{\link{tm_fill}}). This function further specifies the facets, for instance number of rows and columns, and whether the coordinate and scales are fixed or free (i.e. independent of each other). An overview of the different approaches to create facets is provided in the examples.
#' 
#' The global option \code{limits} controls the limit of the number of facets that are plotted. By default, \code{tmap_options(limits=c(facets.plot=64, facets.view=4))}. The maximum number of interactive facets is set to four since otherwise it may become very slow.
#' 
#' @param by data variable name by which the data is split, or a vector of two variable names to split the data by two variables (where the first is used for the rows and the second for the columns).
#' @param along data variable name by which the data is split and plotted on separate pages. This is especially useful for animations made with \code{\link{tmap_animation}}. The \code{along} argument can be used in combination with the \code{by} argument. It is only supported in \code{"plot"} mode (so not in \code{"view"} mode).
#' @param as.layers logical that determines whether facets are shown as different layers in \code{"view"} mode. By default \code{FALSE}, i.e. facets are drawn as small multiples.
#' @param ncol number of columns of the small multiples grid. Not applicable if \code{by} contains two variable names.
#' @param nrow number of rows of the small multiples grid. Not applicable if \code{by} contains two variable names.
#' @param free.coords logical. If the \code{by} argument is specified, should each map has its own coordinate ranges? By default \code{TRUE}, unless facets are shown in as different layers (\code{as.layers = TRUE})
#' @param drop.units logical. If the \code{by} argument is specified, should non-selected spatial units be dropped? If \code{FALSE}, they are plotted where mapped aesthetics are regarded as missing values. Not applicable for raster shapes. By default \code{TRUE}.
#' @param drop.empty.facets logical. If the \code{by} argument is specified, should empty facets be dropped? Empty facets occur when the \code{by}-variable contains unused levels. When \code{TRUE} and two \code{by}-variables are specified, empty rows and columns are dropped.
#' @param drop.NA.facets logical. If the \code{by} argument is specified, and all values of the defined aesthetic variables (e.g. \code{col} from \code{\link{tm_fill}}) for specific facets, should these facets be dropped? \code{FALSE} by default.
#' @param sync logical. Should the navigation in view mode (zooming and panning) be synchronized? By default \code{TRUE} if the facets have the same bounding box. This is generally the case when rasters are plotted, or when free.coords is \code{FALSE}.
#' @param showNA If the \code{by} argument is specified, should missing values of the \code{by}-variable be shown in a facet? If two \code{by}-variables are specified, should missing values be shown in an additional row and column? If \code{NA}, missing values only are shown if they exist. Similar to the \code{useNA} argument of \code{\link[base:table]{table}}, where \code{TRUE}, \code{FALSE}, and \code{NA} correspond to \code{"always"}, \code{"no"}, and \code{"ifany"} respectively.
#' @param textNA text used for facets of missing values.
#' @param free.scales logical. Should all scales of the plotted data variables be free, i.e. independent of each other? Specific scales can be set with \code{free.scales.x}, where \code{x} is the name of the aesthetic, e.g. \code{"symbol.col"}. By default, \code{free.scales} is \code{TRUE}, unless the \code{by} argument is used, the \code{along} argument is used, or a \code{stars} object with a third dimension is shown.
#' @param free.scales.fill logical. Should the color scale for the choropleth be free?
#' @param free.scales.symbol.size logical. Should the symbol size scale for the symbol map be free?
#' @param free.scales.symbol.col logical. Should the color scale for the symbol map be free?
#' @param free.scales.symbol.shape logical. Should the symbol shape scale for the symbol map be free?
#' @param free.scales.text.size logical. Should the text size scale be free?
#' @param free.scales.text.col logical. Should the text color scale be free?
#' @param free.scales.line.col Should the line color scale be free?
#' @param free.scales.line.lwd Should the line width scale be free?
#' @param free.scales.raster Should the color scale for raster layers be free?
#' @param inside.original.bbox If \code{free.coords}, should the bounding box of each small multiple be inside the original bounding box?
#' @param scale.factor Number that determines how the elements (e.g. font sizes, symbol sizes, line widths) of the small multiples are scaled in relation to the scaling factor of the shapes. The elements are scaled to the \code{scale.factor}th root of the scaling factor of the shapes. So, for \code{scale.factor=1}, they are scaled proportional to the scaling of the shapes. Since elements, especially text, are often too small to read, a higher value is recommended. By default, \code{scale.factor=2}.
#' @param drop.shapes deprecated: renamed to \code{drop.units}
#' @export
#' @example ./examples/tm_facets.R
#' @seealso \href{../doc/tmap-getstarted.html}{\code{vignette("tmap-getstarted")}}
#' @references Tennekes, M., 2018, {tmap}: Thematic Maps in {R}, Journal of Statistical Software, 84(6), 1-39, \doi{10.18637/jss.v084.i06}
#' @return \code{\link{tmap-element}}
tm_facets <- function(by=NULL, 
					  along=NULL,
					  as.layers = FALSE,
					  ncol=NA, nrow=NA, 
					  free.coords=!as.layers,
					  drop.units=TRUE,
					  drop.empty.facets=TRUE,
					  drop.NA.facets=FALSE,
					  sync=NA,
					  showNA=NA,
					  textNA="Missing",
					  free.scales=NULL, #is.null(by) && is.null(along),
					  free.scales.fill=NULL, #free.scales,
					  free.scales.symbol.size=NULL, #free.scales,
					  free.scales.symbol.col=NULL, #free.scales,
					  free.scales.symbol.shape=NULL, #free.scales,
					  free.scales.text.size=NULL, #free.scales,
					  free.scales.text.col=NULL, #free.scales,
					  free.scales.line.col=NULL, #free.scales,
					  free.scales.line.lwd=NULL, #free.scales,
					  free.scales.raster=NULL, #free.scales,
					  inside.original.bbox=FALSE,
					  scale.factor=2,
					  drop.shapes=drop.units) {
	calls <- names(match.call(expand.dots = TRUE)[-1])
	
	if ("drop.shapes" %in% calls && get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("The argument drop.shapes has been renamed to drop.units, and is therefore deprecated", call.=FALSE)
	if ("free.scales" %in% calls) calls <- union(calls, c("free.scales.fill", "free.scales.symbol.size", "free.scales.symbol.col", "free.scales.symbol.shape", "free.scales.line.col", "free.scales.line.lwd"))
	g <- list(tm_facets=c(as.list(environment()), list(call=calls)))
	class(g) <- "tmap"
	#attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	#g$call <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' Coordinate grid / graticule lines
#' 
#' Creates a \code{\link{tmap-element}} that draws coordinate grid lines. It serves as a layer that can be drawn anywhere between other layers. By default, \code{tm_grid} draws horizontal and vertical lines acording to the coordinate system of the (master) shape object. Latitude and longitude graticules are drawn with \code{tm_graticules}.
#' 
#' @param x x coordinates for vertical grid lines. If \code{NA}, it is specified with a pretty scale and \code{n.x}.
#' @param y y coordinates for horizontal grid lines. If \code{NA}, it is specified with a pretty scale and \code{n.y}.
#' @param n.x preferred number of grid lines for the x axis. For the labels, a \code{\link{pretty}} sequence is used, so the number of actual labels may be different than \code{n.x}.
#' @param n.y preferred number of grid lines for the y axis. For the labels, a \code{\link{pretty}} sequence is used, so the number of actual labels may be different than \code{n.y}.
#' @param projection projection character. If specified, the grid lines are projected accordingly. Many world maps are projected, but still have latitude longitude (epsg 4326) grid lines.
#' @param col color of the grid lines.
#' @param lwd line width of the grid lines
#' @param alpha alpha transparency of the grid lines. Number between 0 and 1. By default, the alpha transparency of \code{col} is taken. 
#' @param labels.show show tick labels. Either one value for both \code{x} and \code{y} axis, or a vector two: the first for \code{x} and latter for \code{y}.
#' @param labels.size font size of the tick labels
#' @param labels.col font color of the tick labels
#' @param labels.rot Rotation angles of the labels. Vector of two values: the first is the rotation angle (in degrees) of the tick labels on the x axis and the second is the rotation angle of the tick labels on the y axis. Only \code{0}, \code{90}, \code{180}, and \code{270} are valid values.
#' @param labels.format list of formatting options for the grid labels. Parameters are:
#' \describe{
#' \item{fun}{Function to specify the labels. It should take a numeric vector, and should return a character vector of the same size. By default it is not specified. If specified, the list items \code{scientific}, \code{format}, and \code{digits} (see below) are not used.}
#' \item{scientific}{Should the labels be formatted scientifically? If so, square brackets are used, and the \code{format} of the numbers is \code{"g"}. Otherwise, \code{format="f"}, and \code{text.separator}, \code{text.less.than}, and \code{text.or.more} are used. Also, the numbers are automatically  rounded to millions or billions if applicable.}
#' \item{format}{By default, \code{"f"}, i.e. the standard notation \code{xxx.xxx}, is used. If \code{scientific=TRUE} then \code{"g"}, which means that numbers are formatted scientifically, i.e. \code{n.dddE+nn} if needed to save space.}
#' \item{digits}{Number of digits after the decimal point if \code{format="f"}, and the number of significant digits otherwise.}
#' \item{...}{Other arguments passed on to \code{\link[base:formatC]{formatC}}}
#' }
#' @param labels.cardinal add the four cardinal directions (N, E, S, W) to the labels, instead of using negative coordiantes for west and south (so it assumes that the coordinates are positive in the north-east direction).
#' @param labels.margin.x margin between tick labels of x axis and the frame. Note that when \code{labels.inside.frame == FALSE} and \code{ticks == TRUE}, the ticks will be adjusted accordingly.
#' @param labels.margin.y margin between tick labels of y axis and the frame. Note that when \code{labels.inside.frame == FALSE} and \code{ticks == TRUE}, the ticks will be adjusted accordingly.
#' @param labels.space.x space that is used for the labels and ticks for the x-axis when \code{labels.inside.frame == FALSE}. By default, it is determined automatically using the widths and heights of the tick labels. The unit of this parameter is text line height.
#' @param labels.space.y space that is used for the labels and ticks for the y-axis when \code{labels.inside.frame == FALSE}. By default, it is determined automatically using the widths and heights of the tick labels. The unit of this parameter is text line height.
#' @param labels.inside.frame Show labels inside the frame? By default \code{FALSE}
#' @param ticks If \code{labels.inside.frame = FALSE}, should ticks can be drawn between the labels and the frame? Either one value for both \code{x} and \code{y} axis, or a vector two: the first for \code{x} and latter for \code{y}.
#' @param lines If \code{labels.inside.frame = FALSE}, should grid lines can be drawn?
#' @param ndiscr number of points to discretize a parallel or meridian (only applicable for curved grid lines)
#' @param zindex zindex of the pane in view mode. By default, it is set to the layer number plus 400. By default, the tmap layers will therefore be placed in the custom panes \code{"tmap401"}, \code{"tmap402"}, etc., except for the base tile layers, which are placed in the standard \code{"tile"}. This parameter determines both the name of the pane and the z-index, which determines the pane order from bottom to top. For instance, if \code{zindex} is set to 500, the pane will be named \code{"tmap500"}.
#' @param ... arguments passed on to \code{tm_grid}
#' @export
#' @example ./examples/tm_grid.R
tm_grid <- function(x=NA,
					y=NA,
					n.x=NA,
					n.y=NA,
					projection=NA,
					col=NA,
					lwd=1,
					alpha=NA,
					labels.show=TRUE,
					labels.size=.6,
					labels.col=NA,
					labels.rot = c(0, 0),
					labels.format = list(big.mark = ","),
					labels.cardinal = FALSE,
					labels.margin.x=0,
					labels.margin.y=0,
					labels.space.x=NA,
					labels.space.y=NA,
					labels.inside.frame=FALSE,
					ticks = labels.show & !labels.inside.frame,
					lines = TRUE,
					ndiscr = 100,
					zindex = NA) {
	g <- list(tm_grid=as.list(environment()))
	names(g$tm_grid) <- paste("grid", names(g$tm_grid), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' @name tm_graticules
#' @rdname tm_grid
#' @export
tm_graticules <- function(x=NA,
						 y=NA,
						 n.x=NA,
						 n.y=NA,
						 projection = 4326,
						 labels.format = list(suffix = intToUtf8(176)),
						 labels.cardinal = TRUE,
						 ...) {
	do.call(tm_grid, c(list(x = x, y = y, n.x = n.x, n.y = n.y, projection = projection, labels.format = labels.format, labels.cardinal = labels.cardinal), list(...)))
}


#' Credits text
#' 
#' Creates a text annotation that could be used for credits or acknowledgements.
#' 
#' @param text text. Multiple lines can be created with the line break symbol \code{"\\n"}. Facets can have different texts: in that case a vector of characters is required. Use \code{""} to omit the credits for specific facets.
#' @param size relative text size
#' @param col color of the text. By default equal to the argument \code{attr.color} of \code{\link{tm_layout}}.
#' @param alpha transparency number between 0 (totally transparent) and 1 (not transparent). By default, the alpha value of \code{col} is used (normally 1).
#' @param align horizontal alignment: \code{"left"} (default), \code{"center"}, or \code{"right"}. Only applicable if \code{text} contains multiple lines
#' @param bg.color background color for the text
#' @param bg.alpha Transparency number between 0 (totally transparent) and 1 (not transparent). By default, the alpha value of the \code{bg.color} is used (normally 1).
#' @param fontface font face of the text. By default, determined by the fontface argument of \code{\link{tm_layout}}.
#' @param fontfamily font family of the text. By default, determined by the fontfamily argument of \code{\link{tm_layout}}.
#' @param position position of the text. Vector of two values, specifying the x and y coordinates. Either this vector contains "left", "LEFT", "center", "right", or "RIGHT" for the first value and "top", "TOP", "center", "bottom", or "BOTTOM" for the second value, or this vector contains two numeric values between 0 and 1 that specifies the x and y value of the center of the text. The uppercase values correspond to the position without margins (so tighter to the frame). The default value is controlled by the argument \code{"attr.position"} of \code{\link{tm_layout}}.
#' @param width the width of the credits text box, a numeric value that is relative to the map area (so 1 means the whole map width). By default (\code{NA}), it is determined by the width of the text. Tip: set \code{bg.color} to see the result.
#' @param just Justification of the attribute relative to the point coordinates.  The first value specifies horizontal and the second value vertical justification. Possible values are: \code{"left"} , \code{"right"}, \code{"center"}, \code{"bottom"}, and \code{"top"}. Numeric values of 0 specify left/bottom alignment and 1 right/top alignment. This option is only used, if \code{position} is specified by numeric coordinates. The default value is controlled by the argument \code{"attr.just"} of \code{\link{tm_layout}}.
#' @export
#' @seealso \code{\link{tm_xlab}}
#' @example ./examples/tm_credits.R
tm_credits <- function(text,
					   size=.7,
					   col=NA,
					   alpha=NA,
					   align="left",
					   bg.color=NA,
					   bg.alpha=NA,
					   fontface=NA, fontfamily=NA,
					   position=NA,
					   width=NA,
					   just=NA) {
	g <- list(tm_credits=as.list(environment()))
	names(g$tm_credits) <- paste("credits", names(g$tm_credits), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' Logo
#'
#' Creates a map logo. Multiple logos can be specified which are shown next to each other. Logos placed on top of each other can be specified with stacking \code{tm_logo} elements.
#' 
#' @param file either a filename or url of a png image. If multiple files/urls are provided with a character vector, the logos are placed near each other. To specify logos for small multiples use a list of character values/vectors. In order to stack logos vertically, multiple \code{tm_logo} elements can be stacked.
#' @param height height of the logo in number of text line heights. The width is scaled based the height and the aspect ratio of the logo. If multiple logos are specified by a vector or list, the heights can be specified accordingly.
#' @param halign if logos in one row have different heights, \code{halign} specifies the vertical alignment. Possible values are \code{"top"}, \code{"center"} and \code{"bottom"}.
#' @param margin margin around the logo in number of text line heights.
#' @param position position of the logo. Vector of two values, specifying the x and y coordinates. Either this vector contains "left", "LEFT", "center", "right", or "RIGHT" for the first value and "top", "TOP", "center", "bottom", or "BOTTOM" for the second value, or this vector contains two numeric values between 0 and 1 that specifies the x and y value of the center of the text. The uppercase values correspond to the position without margins (so tighter to the frame). The default value is controlled by the argument \code{"attr.position"} of \code{\link{tm_layout}}.
#' @param just Justification of the attribute relative to the point coordinates.  The first value specifies horizontal and the second value vertical justification. Possible values are: \code{"left"} , \code{"right"}, \code{"center"}, \code{"bottom"}, and \code{"top"}. Numeric values of 0 specify left/bottom alignment and 1 right/top alignment. This option is only used, if \code{position} is specified by numeric coordinates. The default value is controlled by the argument \code{"attr.just"} of \code{\link{tm_layout}}.
#' @example ./examples/tm_logo.R
#' @export
tm_logo <- function(file,
					height=3,
					halign="center",
					margin=0.2,
					position=NA,
					just=NA) {
	g <- list(tm_logo=as.list(environment()))
	names(g$tm_logo) <- paste("logo", names(g$tm_logo), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}


#' Scale bar
#' 
#' Creates a scale bar. By default, the coordinate units are assumed to be meters, and the map units in kilometers. This can be changed in \code{\link{tm_shape}}.
#' 
#' @param breaks breaks of the scale bar. If not specified, breaks will be automatically be chosen given the prefered \code{width} of the scale bar. Not available for view mode.
#' @param width (preferred) width of the scale bar. Only applicable when \code{breaks=NULL}. In plot mode, it corresponds the relative width; the default is 0.25 so one fourth of the map width. In view mode, it corresponds to the width in pixels; the default is 100.
#' @param text.size relative text size (which is upperbound by the available label width)
#' @param text.color color of the text. By default equal to the argument \code{attr.color} of \code{\link{tm_layout}}.
#' @param color.dark color of the dark parts of the scale bar, typically (and by default) black.
#' @param color.light color of the light parts of the scale bar, typically (and by default) white.
#' @param lwd line width of the scale bar
#' @param position position of the scale bar Vector of two values, specifying the x and y coordinates. Either this vector contains "left", "LEFT", "center", "right", or "RIGHT" for the first value and "top", "TOP", "center", "bottom", or "BOTTOM" for the second value, or this vector contains two numeric values between 0 and 1 that specifies the x and y value of the left bottom corner of the scale bar. The uppercase values correspond to the position without margins (so tighter to the frame). The default value is controlled by the argument \code{"attr.position"} of \code{\link{tm_layout}}.
#' @param bg.color Background color
#' @param bg.alpha Transparency of the background color. Number between 0 (totally transparent) and 1 (not transparent). By default, the alpha value of the \code{bg.color} is used (normally 1).
#' @param just Justification of the attribute relative to the point coordinates.  The first value specifies horizontal and the second value vertical justification. Possible values are: \code{"left"} , \code{"right"}, \code{"center"}, \code{"bottom"}, and \code{"top"}. Numeric values of 0 specify left/bottom alignment and 1 right/top alignment. This option is only used, if \code{position} is specified by numeric coordinates. The default value is controlled by the argument \code{"attr.just"} of \code{\link{tm_layout}}.
#' @param size deprecated: renamed to text.size
#' @export
#' @example ./examples/tm_scale_bar.R
tm_scale_bar <- function(breaks=NULL,
						 width=NA, 
						 text.size = .5,
						 text.color=NA,
						 color.dark="black", 
						 color.light="white",
						 lwd=1,
						 position=NA,
						 bg.color=NA,
						 bg.alpha=NA,
						 just=NA,
						 size = NULL) {
	if (!missing(size)) {
		if (get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("The argument size of tm_scale_bar is deprecated. It has been renamed to text.size", call. = FALSE)
		text.size <- size
		size <- NULL
	}
	g <- list(tm_scale_bar=as.list(environment()))
	names(g$tm_scale_bar) <- paste("scale", names(g$tm_scale_bar), sep=".")
	class(g) <- "tmap"
	gcall <- names(match.call(expand.dots = TRUE)[-1])
	g$tm_scale_bar$scale.call <- gcall
	attr(g, "call") <- gcall
	g
}

#' Map compass
#' 
#' Creates a map compass.
#' 
#' @param north north direction in degrees: 0 means up, 90 right, etc.
#' @param type compass type, one of: \code{"arrow"}, \code{"4star"}, \code{"8star"}, \code{"radar"}, \code{"rose"}. The default is controlled by \code{\link{tm_layout}} (which uses \code{"arrow"} for the default style)
#' @param text.size relative font size
#' @param size size of the compass in number of text lines. The default values depend on the \code{type}: for \code{"arrow"} it is 2, for \code{"4star"} and \code{"8star"} it is 4, and for \code{"radar"} and \code{"rose"} it is 6.
#' @param show.labels number that specifies which labels are shown: 0 means no labels, 1 (default) means only north, 2 means all four cardinal directions, and 3 means the four cardinal directions and the four intercardinal directions (e.g. north-east).
#' @param cardinal.directions labels that are used for the cardinal directions north, east, south, and west.
#' @param text.color color of the text. By default equal to the argument \code{attr.color} of \code{\link{tm_layout}}.
#' @param color.dark color of the dark parts of the compass, typically (and by default) black.
#' @param color.light color of the light parts of the compass, typically (and by default) white.
#' @param lwd line width of the compass
#' @param position position of the compass. Vector of two values, specifying the x and y coordinates. Either this vector contains "left", "LEFT", "center", "right", or "RIGHT" for the first value and "top", "TOP", "center", "bottom", or "BOTTOM" for the second value, or this vector contains two numeric values between 0 and 1 that specifies the x and y value of the left bottom corner of the compass. The uppercase values correspond to the position without margins (so tighter to the frame). The default value is controlled by the argument \code{"attr.position"} of \code{\link{tm_layout}}.
#' @param bg.color Background color
#' @param bg.alpha Transparency of the background color. Number between 0 (totally transparent) and 1 (not transparent). By default, the alpha value of the \code{bg.color} is used (normally 1).
#' @param just Justification of the attribute relative to the point coordinates.  The first value specifies horizontal and the second value vertical justification. Possible values are: \code{"left"} , \code{"right"}, \code{"center"}, \code{"bottom"}, and \code{"top"}. Numeric values of 0 specify left/bottom alignment and 1 right/top alignment. This option is only used, if \code{position} is specified by numeric coordinates. The default value is controlled by the argument \code{"attr.just"} of \code{\link{tm_layout}}.
#' @param fontsize deprecated: renamed to text.size
#' @export
#' @example ./examples/tm_compass.R
tm_compass <- function(north=0, 
					   type=NA, 
					   text.size=.8,
					   size=NA,
					   show.labels=1, 
					   cardinal.directions=c("N", "E", "S", "W"), 
					   text.color=NA,
					   color.dark=NA, 
					   color.light=NA,
					   lwd=1,
					   position=NA,
					   bg.color=NA,
					   bg.alpha=NA,
					   just=NA,
					   fontsize = NULL) {
	if (!missing(fontsize)) {
		if (get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("The argument fontsize of tm_compass is deprecated. It has been renamed to text.size", call. = FALSE)
		text.size <- fontsize
		fontsize <- NULL
	}
	g <- list(tm_compass=as.list(environment()))
	names(g$tm_compass) <- paste("compass", names(g$tm_compass), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' Axis labels
#' 
#' Add axis labels
#' 
#' @param text text for the axis
#' @param size fontsize, by default 0.8
#' @param rotation rotation angle in degrees. By default, 0 for the x axis label and 90 for the y axis label.
#' @param space space between labels and the map in numbers of line heights. By default, it is 0, unless grid labels are plotted outside the frame (i.e., \code{\link{tm_grid}} is called with \code{labels.inside.frame = FALSE}). In that case, \code{space} corresponds to the height of one line, taking the grid label size into account.
#' @export
#' @name tm_xlab
#' @rdname axis_labels
#' @example  ./examples/tm_lab.R
tm_xlab <- function(text,
					size=.8,
					rotation=0,
					space = 0) {
	g <- list(tm_xlab=as.list(environment()))
	names(g$tm_xlab) <- paste("xlab", names(g$tm_xlab), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' @name tm_ylab
#' @rdname axis_labels
#' @export
tm_ylab <- function(text,
					size=.8,
					rotation=90,
					space = 0) {
	g <- list(tm_ylab=as.list(environment()))
	names(g$tm_ylab) <- paste("ylab", names(g$tm_ylab), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g
}

#' Minimap
#' 
#' Creates a minimap in view mode. See \code{\link[leaflet:addMiniMap]{addMiniMap}}.
#' 
#' @param server name of the provider or an URL (see \code{\link{tm_tiles}}). By default, it shows the same map as the basemap, and moreover, it will automatically change when the user switches basemaps. Note the latter does not happen when \code{server} is specified.
#' @param position position of the scale bar Vector of two values, specifying the x and y coordinates. The first is either "left" or "right", the second either "top" or "bottom".
#' @param toggle should the minimap have a button to minimise it? By default \code{TRUE}.
#' @param ... arguments passed on to \code{\link[leaflet:addMiniMap]{addMiniMap}}.
#' @seealso \code{\link[leaflet:addMiniMap]{addMiniMap}}
#' @export
tm_minimap <- function(server = NA, position= c("left", "bottom"), toggle = TRUE, ...) {
	g <- list(tm_minimap=c(as.list(environment()), list(...)))
	names(g$tm_minimap) <- paste("minimap", names(g$tm_minimap), sep=".")
	class(g) <- "tmap"
	attr(g, "call") <- names(match.call(expand.dots = TRUE)[-1])
	g	
}


#' Mouse coordinates
#' 
#' Adds mouse coordinates in view mode. See \code{\link[leafem:addMouseCoordinates]{addMouseCoordinates}}.
#' 
#' @seealso \code{\link[leafem:addMouseCoordinates]{addMouseCoordinates}}
#' @export
tm_mouse_coordinates <- function() {
	g <- list(tm_mouse=list(mouse.show = TRUE))
	class(g) = "tmap"
	g	
}



#' Stacking of tmap elements
#' 
#' The plus operator allows you to stack \code{\link{tmap-element}s}, and groups of \code{\link{tmap-element}s}.
#' 
#' @param e1 first \code{\link{tmap-element}}
#' @param e2 second \code{\link{tmap-element}}
#' @seealso \code{\link{tmap-element}} and \href{../doc/tmap-getstarted.html}{\code{vignette("tmap-getstarted")}}
#' @references Tennekes, M., 2018, {tmap}: Thematic Maps in {R}, Journal of Statistical Software, 84(6), 1-39, \doi{10.18637/jss.v084.i06}
#' @export
"+.tmap" <- function(e1, e2) {
	qtm_shortcut1 <- attr(e1, "qtm_shortcut")
	qtm_shortcut2 <- attr(e2, "qtm_shortcut")

	if (identical(qtm_shortcut1, TRUE)) {
		if (get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("qtm called without shape objects cannot be stacked", call. = FALSE)
		g <- e2
	} else if (identical(qtm_shortcut2, TRUE)) {
		if (get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("qtm called without shape objects cannot be stacked", call. = FALSE)
		g <- e1
	} else {
		g <- c(e1,e2)
		class(g) <- "tmap"
	}
	
	assign("last_map_new", match.call(), envir = .TMAP_CACHE)
	g
}


#' Retrieve the last map to be modified or created
#' 
#' Retrieve the last map to be modified or created. Works in the same way as \code{ggplot2}'s \code{\link[ggplot2:last_plot]{last_plot}}, although there is a difference: \code{last_map} returns the last call instead of the stacked \code{\link{tmap-element}s}.
#' 
#' @return call
#' @export
#' @seealso \code{\link{tmap_save}}
tmap_last <- function() {
	.x <- get("last_map", envir = .TMAP_CACHE)
	if (is.null(.x) && get("tmapOptions", envir = .TMAP_CACHE)$show.warnings) warning("A map has not been created yet")
	eval(.x)
}

save_last_map <- function() {
	lt <- get("last_map", envir = .TMAP_CACHE)
	ltnew <- get("last_map_new", envir = .TMAP_CACHE)
	if (!is.null(ltnew)) lt <- replace_last_tmap_by_correct_call(ltnew, lt)
	assign("last_map", lt, envir = .TMAP_CACHE)
	assign("last_map_new", NULL, envir = .TMAP_CACHE)
}


replace_last_tmap_by_correct_call <- function(mc, lt) {
	if (is.symbol(mc)) {
		mc
	} else if (as.character(mc[1])=="last_map") {
		lt
	} else {
		if (as.character(mc[1]) %in% c("+.tmap", "+")) {
			if (!is.null(mc[[2]])) mc[2] <- list(replace_last_tmap_by_correct_call(mc[[2]], lt))
			if (!is.null(mc[[3]])) mc[3] <- list(replace_last_tmap_by_correct_call(mc[[3]], lt))
		}
		mc
	}
}

