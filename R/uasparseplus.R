# (c) Jim Vine
# Author: Jim Vine
# Function to parse user-agent strings


#' Parse User-Agent strings, providing extra information
#'
#' \code{uasparseplus} parses User-Agent strings using
#' \code{uaparserjs::ua_parse()} to provide the bulk of its logic.
#' It augments the outputs of \code{uaparserjs::ua_parse()} with an additional
#' variable --- \code{device.type} --- which provides an indication of type of
#' device the User-Agent string represents.
#'
#' The regex for identifying device types is derived almost entirely from the
#' code for Stata's \code{parseuas} package (version 1.4, 2020), with only
#' minor additions to cope with operating systems that are identified
#' differently by \code{uaparserjs::ua_parse()} and \code{parseuas}.
#' (Specifically, \code{uaparserjs::ua_parse()} identifies Ubuntu and Linux
#' as separate OSs, whereas \code{parseuas} classifies both as Linux.)
#'
#' Because the core parsing functionality is provided by
#' \code{uaparserjs::ua_parse()}, which has a different set of regexes to
#' \code{parseuas}, the end results are not guaranteed to be identical
#' to those of \code{parseuas}.
#'
#' @section References:
#'
#' Roßmann, Joss, and Tobias Gummer. 2020.
#'   PARSEUAS: Stata Module to Extract Detailed Information from User Agent
#'   Strings (version Version: 1.4). Chestnut Hill, MA: Boston College.
#'
#' Roßmann, Joss, Tobias Gummer, and Lars Kaczmirek. 2020. ‘Working with User
#'   Agent Strings in Stata: The Parseuas Command’. Journal of Statistical
#'   Software 92 (1): 1–16. https://doi.org/10.18637/jss.v092.c01.
#'
#' Rudis, Bob, Lindsey Simon, and Tobie Langel. 2020. Uaparserjs: Parse
#'   ‘User-Agent’ Strings (version R package version 0.3.5).
#'   https://CRAN.R-project.org/package=uaparserjs.
#'
#'
#' @param user_agents A vector of user-agent strings.
#' @param ... Other parameters, passed to \code{uaparserjs::ua_parse()}.
#'   \code{uaparserjs::ua_parse()} is documented to accept a \code{.progress}
#'   parameter.
#'
#' @examples
#' # Set up some sample data for parsing
#'
#' uastrings <- c(
#'   paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
#'          "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
#'          "Chrome/15.0.874.106 Safari/535.2",
#'          collapse=""),
#'
#'   paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ",
#'          "(KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
#'          collapse=""),
#'
#'   paste0("Mozilla/5.0 (Linux; Android 9; moto g(6)) AppleWebKit/537.36 ",
#'          "(KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
#'          collapse="")
#'
#' )
#'
#'
#' # Parse the User-Agent strings
#'
#' parsed_uastrings <- uasparseplus(uastrings)
#'
#' # Examine the extra variable
#'
#' table(parsed_uastrings$device.type)
#'
#' @export
uasparseplus <- function(user_agents, ...) {

  ua_parsed <- uaparserjs::ua_parse(user_agents, ...)

  # *"Android" without "Mobi" => tablet
  # replace `tempdevice' = "Tablet (Android)" if regexm(`varlist', "Android") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Android", ua_parsed$userAgent),
                                  "Tablet (Android)",
                                  "")

  # *Mobile phone (other)
  # replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "[mM]obi") & `touse'
  # replace `tempdevice' = "Mobile phone (other)" if regexm(`tempos', "BlackBerry") & `touse'
  # replace `tempdevice' = "Mobile phone (other)" if regexm(`tempos', "Symbian") & `touse'
  # replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "GT-S8600") & `touse'
  # replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "SAMSUNG-S8000") & `touse'

  ua_parsed$device.type <- ifelse(grepl("[mM]obi", ua_parsed$userAgent) |
                                    grepl("BlackBerry", ua_parsed$os.family) |
                                    grepl("Symbian", ua_parsed$os.family) |
                                    grepl("GT-S8600", ua_parsed$userAgent) |
                                    grepl("SAMSUNG-S8000", ua_parsed$userAgent),
                                  "Mobile phone (other)",
                                  ua_parsed$device.type)

  # *Mobile phone (Android)
  # replace `tempdevice' = "Mobile phone (Android)" if regexm(`varlist', "Android.*[mM]obi") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Android.*[mM]obi", ua_parsed$userAgent),
                                  "Mobile phone (Android)",
                                  ua_parsed$device.type)


  # *Mobile phone (iPhone)
  # replace `tempdevice' = "Mobile phone (iPhone)" if regexm(`varlist', "iPhone") & `touse'
  # replace `tempdevice' = "Mobile phone (iPhone)" if regexm(`varlist', "iPod") & `touse'


  ua_parsed$device.type <- ifelse(grepl("iPhone", ua_parsed$userAgent) |
                                    grepl("iPod", ua_parsed$userAgent),
                                  "Mobile phone (iPhone)",
                                  ua_parsed$device.type)

  # *Mobile phone (Windows)
  # replace `tempdevice' = "Mobile phone (Windows)" if regexm(`varlist', "Windows Phone") & `touse'
  # replace `tempdevice' = "Mobile phone (Windows)" if regexm(`varlist', "HTC_HD2_T8585") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Windows Phone", ua_parsed$userAgent) |
                                    grepl("HTC_HD2_T8585", ua_parsed$userAgent),
                                  "Mobile phone (Windows)",
                                  ua_parsed$device.type)


  # *Tablet (other)
  # replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "Tablet") & `touse'
  # replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "Kindle") & `touse'
  # replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "PlayBook") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Tablet", ua_parsed$userAgent) |
                                    grepl("Kindle", ua_parsed$userAgent) |
                                    grepl("PlayBook", ua_parsed$userAgent),
                                  "Tablet (other)",
                                  ua_parsed$device.type)


  # *Tablet (Windows)
  # replace `tempdevice' = "Tablet (Windows)" if regexm(`varlist', "Windows.*Tablet") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Windows.*Tablet", ua_parsed$userAgent),
                                  "Tablet (Windows)",
                                  ua_parsed$device.type)


  # *Tablet (Android)
  # replace `tempdevice' = "Tablet (Android)" if regexm(`varlist', "Android.*[tT]ab") & `touse'
  # replace `tempdevice' = "Tablet (Android)" if regexm(`varlist', "GT-P1000") & `touse'

  ua_parsed$device.type <- ifelse(grepl("Android.*[tT]ab", ua_parsed$userAgent) |
                                    grepl("GT-P1000", ua_parsed$userAgent),
                                  "Tablet (Android)",
                                  ua_parsed$device.type)

  # *Tablet (iPad)
  # replace `tempdevice' = "Tablet (iPad)" if regexm(`varlist', "iPad") & `touse'

  ua_parsed$device.type <- ifelse(grepl("iPad", ua_parsed$userAgent),
                                  "Tablet (iPad)",
                                  ua_parsed$device.type)

  # *Video game console
  # replace `tempdevice' = "Video game console" if regexm(`varlist', "[pP][lL][aA][yY][sS][tT][aA][tT]") & `touse'
  # replace `tempdevice' = "Video game console" if regexm(`varlist', "[xX][bB][oO][xX]") & `touse'
  # replace `tempdevice' = "Video game console" if regexm(`varlist', "[nN][iI][nN][tT][eE][nN][dD][oO]") & `touse'

  ua_parsed$device.type <- ifelse(grepl("[pP][lL][aA][yY][sS][tT][aA][tT]", ua_parsed$userAgent) |
                                    grepl("[xX][bB][oO][xX]", ua_parsed$userAgent) |
                                    grepl("[nN][iI][nN][tT][eE][nN][dD][oO]", ua_parsed$userAgent),
                                  "Video game console",
                                  ua_parsed$device.type)


  # *Personal computer
  # replace `tempdevice' = "Personal computer (Windows)" if `tempdevice'=="" & regexm(`tempos', "Windows") & `touse'
  # replace `tempdevice' = "Personal computer (Mac)" if `tempdevice'=="" & regexm(`tempos', "Mac OS X") & `touse'
  # replace `tempdevice' = "Personal computer (Linux)" if `tempdevice'=="" & regexm(`tempos', "Linux") & `touse'
  # replace `tempdevice' = "Personal computer (Chrome OS)" if `tempdevice'=="" & regexm(`tempos', "Chrome OS") & `touse'

  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    grepl("Windows", ua_parsed$os.family),
                                  "Personal computer (Windows)",
                                  ua_parsed$device.type)

  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    grepl("Mac OS X", ua_parsed$os.family),
                                  "Personal computer (Mac)",
                                  ua_parsed$device.type)

  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    grepl("Linux", ua_parsed$os.family),
                                  "Personal computer (Linux)",
                                  ua_parsed$device.type)

  # Added condition, not present in Stata's -parseuas- as some Linux variants
  # tagged differently by `uaparserjs::ua_parse()` (specifically Ubuntu), so
  # there are some cases each of:
  #     os.family == "Linux"
  #     os.family == "Ubuntu"
  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    grepl("Ubuntu", ua_parsed$os.family),
                                  "Personal computer (Linux)",
                                  ua_parsed$device.type)

  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    grepl("Chrome OS", ua_parsed$os.family),
                                  "Personal computer (Chrome OS)",
                                  ua_parsed$device.type)


  # *Device: other
  # replace `tempdevice' = "Device (other)" if `tempdevice'=="" & `varlist'!="" & `touse'

  ua_parsed$device.type <- ifelse(ua_parsed$device.type == "" &
                                    ua_parsed$userAgent != "",
                                  "Device (other)",
                                  ua_parsed$device.type)

  return(ua_parsed)

}
