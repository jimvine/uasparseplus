# uasparseplus

The goal of uasparseplus is to derive additional variables based on the parsing
of User-Agent strings (UASs). The actual parsing of the UASs is handled by the
`uaparserjs` package. The definitions for the additional derived variables are
from the Stata package `-parseuas-`.

## Installation

You can install uasparseplus from github with:

```R
# install.packages("devtools")
devtools::install_github("jimvine/uasparseplus")
```

## Example


This is a basic example which shows you how to solve a common problem:


```R
# Set up some sample data for parsing

uastrings <- c(
  paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
         "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
         "Chrome/15.0.874.106 Safari/535.2", 
         collapse=""),
  
  paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ",
         "(KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36", 
         collapse=""),
  
  paste0("Mozilla/5.0 (Linux; Android 9; moto g(6)) AppleWebKit/537.36 ",
         "(KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36", 
         collapse="")

)


# Parse the User-Agent strings

parsed_uastrings <- uasparseplus(uastrings)

# Examine the extra variable

table(parsed_uastrings$device.type)

```
