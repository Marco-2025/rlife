library(ggplot2)
library(caTools)
library(shiny)
library(magick)
library(gifski)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "spacelab"),
  
  tags$style(HTML("
                  img {
                    height: 115%;
                    width: auto;
                  }
                  p {
                    font-size:12px;
                  }
                  ")),
  
  navbarPage("RLife: An R Implementation of Conway's Game of Life"),
  sidebarLayout(
    sidebarPanel(
      p("README: To DEMO simply press Start, you do not need to upload any custom set-up file as there is a pre-loaded default csv."),
      p("Custom Set-Up: The file should have 2 colums, one titled X and one titled Y. Ensure that there isn't another column or a table name. Each coordinate represents a cell that is alive at the start."),
      HTML("<a target='_blank' href='https://github.com/marcodeanda20/rlife/blob/main/template.csv'>Click for template set-up csv file</a>"),
      fileInput("setup",
                "Set-Up CSV:",
                multiple = F,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv"),
                buttonLabel = "Browse",
                placeholder = "default.csv",
                
      ),
      numericInput("generations",
                "Number of Generations: (Min=1, Max=50)",
                5,
                min=1,
                max=50
                ),
      actionButton("play", "Start", icon = icon("play")),
      p("Note: Once you click Start, wait a few seconds (about 1.5s per generation) for the animation to load."),
    ),
    
    #Show animation
    mainPanel(
      plotOutput("image"),
    )
  )
)

# Define server logic

server <- function(input, output) {
  
  output$image <- renderImage({
    list(src = normalizePath(file.path('./image.png')))
  }, deleteFile = F)
  
  observeEvent(input$play, {
    #desired size of game space
    #Maybe allow users to change this
    gameSize <- 20
    setUpCSV <- input$setup

        setUpCSV <- setUpCSV$datapath
    if(is.null(setUpCSV)){
      setUpCSV <- "set-up.csv"
    }
    #working: read uploaded csv
    setup <- read.csv(setUpCSV)
    
    #make all initial cells alive
    Alive <- c()
    for(i in 1:nrow(setup)) {
      Alive <- append(Alive, c(T))
    }
    
    #Add alive column to setup and create the data frame you will use
    life <- cbind(setup, Alive)
    
    #Create data frame with all other values and add them as dead cells
    #Iterate through all possible cells and check if existing initial set-up cells exist
    #If not add to new data frame
    deadX <- c()
    deadY <- c()
    status <- c()
    count <- 0
    
    for (a in 1:gameSize) {
      for (b in 1:gameSize) {
        existing <- F
        for (c in 1:nrow(life)) {
          if (life[c, "X"] == a && life[c, "Y"] == b) {
            existing <- T
            count <- count +1
          }
        }
        if (existing == F) {
          deadX <- append(deadX, c(a))
          deadY <- append(deadY, c(b))
          status <- append(status, c(F))
        }
      }
    }
    
    otherCells <- data.frame(X = deadX, Y = deadY, Alive = status)
    
    #Add new rows to current life data frame
    
    life <- rbind(life, otherCells)
    
    #Create scatter plot
    
    filename<-paste("0.png")
    plot1 <- ggplot(life, aes(x=X, y=Y, color=Alive)) + geom_point(size=5)
    plot1 <- plot1 + scale_x_continuous(limits=c(1,gameSize), breaks=seq(1,gameSize, by=1), minor_breaks = seq(1,gameSize, by=1))
    plot1 <- plot1 + scale_y_continuous(limits=c(1,gameSize), breaks=seq(1,gameSize, by=1), minor_breaks = seq(1,gameSize, by=1))
    plot1 <- plot1 + theme() + scale_color_manual(values=c("#8c8c8c", "blue"))
    ggsave(filename, plot=plot1)
    
    simulations <- input$generations
    if(input$generations<1){
      simulations <- 1
    } else if(input$generations>50){
      simulations <- 50
    }

    
    #Each loop will represent a generation
    for(i in 1:simulations) {
      
      #First iteration: selects row to then compare
      newStatus <- c()
      for(a in 1:nrow(life)) {
        
        neighborCount <- 0
        #Second iteration: scan through other (b) rows for living neighbors of current (a) row
        for(b in 1:nrow(life)) {
          #Ignore dead cells
          if(life[b, "Alive"] == T){
            #Ignore same row
            if(b != a) {
              #Check if on a boundary
              #Not on a boundary
              if(life[a,"X"]-1 > 0 && life[a,"X"]+1 < 11 && life[a,"Y"]-1 > 0 && life[a,"Y"]+1 < 11){
                #Check if row b's X can neighbor row a's X
                if(life[b,"X"] == life[a,"X"]-1 || life[b,"X"] == life[a,"X"] || life[b,"X"] == life[a,"X"]+1) {
                  #Check if row b's Y can neighbor row a's Y
                  if(life[b,"Y"] == life[a,"Y"]-1 || life[b,"Y"] == life[a,"Y"] || life[b,"Y"] == life[a,"Y"]+1) {
                    neighborCount <- neighborCount + 1
                  }
                }
              } else {
                #On a boundary
                #Check X first
                xNeighbour <- F
                #If current row x is below 1
                if (life[a,"X"]-1 < 1 && life[b,"X"] == 10) {
                  xNeighbour <- T
                }
                #If current row x is above 1
                else if (life[a,"X"]+1 > 10 && life[b,"X"] == 1) {
                  xNeighbour <- T
                }
                #If current row x is normal
                else if(life[b,"X"] == life[a,"X"]-1 || life[b,"X"] == life[a,"X"] || life[b,"X"] == life[a,"X"]+1) {
                  xNeighbour <- T
                }
                
                #Now check Y
                yNeighbour <- F
                #If current row y is below 1
                if (life[a,"Y"]-1 < 1 && life[b,"Y"] == 10) {
                  yNeighbour <- T
                  #If current row x is above 1
                } else if (life[a,"Y"]+1 > 10 && life[b,"Y"] == 1) {
                  yNeighbour <- T
                  #If current row x is normal
                } else if (life[b,"Y"] == life[a,"Y"]-1 || life[b,"Y"] == life[a,"Y"] || life[b,"Y"] == life[a,"Y"]+1) {
                  yNeighbour <- T
                }
                
                #Check if neighbor
                if(yNeighbour == T && xNeighbour == T) {
                  neighborCount <- neighborCount + 1
                }
              }
            }
          }
        }
        
        #Alive cell protocol
        if(life[a, "Alive"] == T) {
          #Check for low population
          if (neighborCount < 2) {
            newStatus <- append(newStatus, c(F))
          } else if (neighborCount == 2 || neighborCount == 3) {
            #Check for normal population
            newStatus <- append(newStatus, c(T))
          } else if (neighborCount > 3) {
            #Check for overpopulation
            newStatus <- append(newStatus, c(F))
          }
          
        } else {
          #Dead cell protocol
          if(neighborCount == 3){
            newStatus <- append(newStatus, c(T))
          } else {
            #Must specify what happens to dead cells if reproduction does not occur
            newStatus <- append(newStatus, c(F))
          }
        }
      }
      
      #Change dead or alive status after loop to prevent bug
      life$Alive <- newStatus
      
      filename<-paste(i, ".png", sep="")
      plot1 <- ggplot(life, aes(x=X, y=Y, color=Alive)) + geom_point(size=5)
      plot1 <- plot1 + scale_x_continuous(limits=c(1,gameSize), breaks=seq(1,gameSize, by=1), minor_breaks = seq(1,gameSize, by=1))
      plot1 <- plot1 + scale_y_continuous(limits=c(1,gameSize), breaks=seq(1,gameSize, by=1), minor_breaks = seq(1,gameSize, by=1))
      plot1 <- plot1 + theme() + scale_color_manual(values=c("#8c8c8c", "blue"))
      ggsave(filename, plot=plot1)
      
    }
    
    images <- c()
    for(i in 0:simulations){
      imageName <- paste(i,".png", sep="")
      images <- append(images, image_read(imageName))
    }
    
    animate <- image_animate(images, fps=2)
    image_write_gif(animate, "life.gif", delay = 0.7)
    output$image <- renderImage({
      list(src = normalizePath(file.path('./life.gif')))
    }, deleteFile = F)
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
