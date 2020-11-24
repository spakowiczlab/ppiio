
### Find the JSON path information in the appropriate directory.
jinfo <- file.path("C:", "Users", "muni11", "Documents","GitHub", "ppiio", "ppiio.json")
if (!file.exists(jinfo)) stop("Cannot locate file: '", jinfo, "'.\n", sep='')
### parse it
library(rjson)
temp <- fromJSON(file = jinfo)
paths <- temp$paths
detach("package:rjson")
### clean up
rm(jinfo, temp)

