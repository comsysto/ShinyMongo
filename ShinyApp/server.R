#
# ShinyMongo App
# a simple R based MongoDB - Viewer
# 
# Markus Schmidberger, markus.schmidberger@comsysto.com
# June, 2013

library(shiny)
library(rmongodb)
library(rjson)
#RJSONJO gets problems with big JSON objects )-:

# parameter to set the maximum queyering and displaying lentgth
limit <- 100L


shinyServer(function(input, output) {
  
  # create mongo connection
  connection <- reactive({
    mongo <- mongo.create(input$host, username=input$username, password=input$password)
  })
  
  ####################
  # sidebar rendering
  ####################
  
  # render database input field
  output$dbs <- renderUI({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      dbs <- mongo.get.databases(mongo)
      selectInput("db_input", "Database", dbs)
    }
  })
  
  # render collection input field
  output$collections <- renderUI({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      if( !is.null(input$db_input) ){
        collections <- mongo.get.database.collections(mongo, input$db_input)
        selectInput("collections_input", "Collections", c("-",collections))
      }
    }
  })
  
  # render query input field
  output$query <- renderUI({  
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      if( !is.null(input$collections_input)){
        if( !is.null(input$db_input) && input$collections_input!="-" ){
          textInput("query", "JSON Query - experimental:", "")
        }
      }
    }
  })
  
  
  ####################
  # output / main window rendering
  ####################
  
  # display text for connection information / error
  output$connection <- renderText({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      str <- mongo.get.primary(mongo)
      paste("Connected to ", str , sep="")
    } else {
      # ToDo: more detailed errors
      paste("Unable to connect.  Error code:", mongo.get.err(mongo))
    }
  })
  
  # display collection data as JSON output
  output$view <- renderText({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
    
      if( !is.null(input$query) ){
        if( input$query !="" ){
          Rquery <- fromJSON(input$query)
          query <- mongo.bson.from.list(Rquery)
        } else {
          buf <- mongo.bson.buffer.create()
          query <- mongo.bson.from.buffer(buf)
        }
      }
        
      if( !is.null(input$collections_input) && !is.null(input$query) ){
        cursor <- mongo.find(mongo, input$collections_input, query, limit=limit)
        res_list <- list()
        tmp_all <- NULL
        i <- 1
       while (mongo.cursor.next(cursor)){
         tmp <- mongo.cursor.value(cursor)
         res_list[[i]] <- mongo.bson.to.list(tmp)
         i <- i+1
       }
       mongo.cursor.destroy(cursor)
        json <- toJSON(res_list)
        json <- gsub("\\},\\{", "},<br><br>{", json)
       return( json )
      }
    }
  })
  
  # display Headline for collection data output
  output$view_head <- renderText({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      if( !is.null(input$collections_input) && input$collections_input != "-" ){
        count <- mongo.count(mongo, input$collections_input)
        if (count < limit)
          limit <- count
        paste("Documents (", limit, " out of ",count,")", sep="")
      }
    }
  })
  
  # display table with collection overview
  output$view_collections <- renderTable({
    mongo <- connection()
    if( mongo.is.connected(mongo) ) {
      if( !is.null(input$db_input) ){
        coll <- mongo.get.database.collections(mongo, input$db_input)
        
        res <- NULL
        for(i in coll){
          val <- mongo.count(mongo, i)
          tmp <- cbind(i,val)
          res <- rbind(res, tmp)
        }
        if( !is.null(res) )
          colnames(res) <- c("collection", "# documents")
        
        return(res)
      }
    } 
  })

})
