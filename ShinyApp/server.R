#
# ShinyMongo App
# a simple R based MongoDB - Viewer
# 
# Markus Schmidberger, markus.schmidberger@comsysto.com
# June, 2013

library(shiny)
library(rmongodb)
library(rjson)
limit <- 20L

shinyServer(function(input, output) {
  
  connection <- reactive({
    mongo <- mongo.create(input$host, username=input$username, password=input$password)
  })
  
  output$dbs <- renderUI({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      dbs <- mongo.get.databases(mongo)
      selectInput("db_input", "Database", dbs)
    }
  })
  
  output$collections <- renderUI({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      if( !is.null(input$db_input) ){
        collections <- mongo.get.database.collections(mongo, input$db_input)
        selectInput("collections_input", "Collections", c("-",collections))
      }
    }
  })
  
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
  
  
  output$connection <- renderText({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      str <-    mongo.get.primary(mongo)
      paste("Connected to ", str , sep="")
    } else {
      paste("Unable to connect.  Error code:", mongo.get.err(mongo))
    }
  })
  

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
        
      if( !is.null(input$collections_input) ){
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
  
  output$view_collections <- renderTable({
    mongo <- connection()
    if (mongo.is.connected(mongo)) {
      if( !is.null(input$db_input) ){
        coll <- mongo.get.database.collections(mongo, input$db_input)
        
        res <- NULL
        for(i in coll){
          val <- mongo.count(mongo, i)
          tmp <- cbind(i,val)
          res <- rbind(res, tmp)
        }
        colnames(res) <- c("collection", "# documents")
        
        return(res)
      }
    } 
  })

})
