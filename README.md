ShinyMongo
========================================================

ShinyMongo is an [R](http://www.r-project.org) based [mongoDB](http://www.mongodb.org) user interface. Using the R packages [shiny](http://www.rstudio.org/shiny/) and [rmongodb](http://cran.r-project.org/package=rmongodb) and less than 200 lines of code you can create a simple mongoDB user-interface to view mongoDB data. Querying mongoDB data is currently running in an experimental mode. It is already working for simple queries.


Installation and Operation
------------------------------------
ShinyMongo is running on the beta shiny-server provided by [RStudio](http://www.rstudio.com/). Press the URL, add your hostname and browse your mongoDB instance: http://spark.rstudio.com/schmidb/ShinyMongo/


You can run ShinyMongo locally on your machine directly from github:
```
library(shiny)
shiny::runGitHub('ShinyMongo', 'comsysto', subdir='ShinyApp')
```
Next the shiny only the package rmongodb will be required.

Or please fell free to clone the repository and go on developing and running ShinyMongo.

Currently, there is only one fix parameter in server.R which defines the maximum number of displayed and queried objects:
```
limit <- 100
```

Roadmap
------------------------------------
* June 2013, release version 1
* July 2013, implement json2bson converter for rmongodb
* August 2013, add quering features to ShinyMongo
* Q4 2013, add simple statistics to ShinyMongo

Contact
------------------------------------
Markus Schmidberger
markus.schmidberger@comsysto.com
