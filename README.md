# RLife
![RLife Website](website.png)

## Inspiration
R is a language that is mainly used for statistics, however, as shown today, its use cases can include game development.

## What it does
RLife is an R language implementation of Conway's Game of Life.

Users can customize the game by uploading CSV files with coordinates (X,Y) where each coordinate represents a cell that is alive at the start of the game. Users can also edit the number of generations they wish to simulate. When users press Start, a gif of the simulation will be generated.

For a collection of fun, ready-to-use Set-Up CSV files go to: [Github Set-Up File Collection](https://github.com/marcodeanda20/rlife/tree/main/Set-Up%20File%20Collection)

**How to try it:**
1. Go to: [RLife](https://marcoprojects.shinyapps.io/rlife/)
2. Press Start (No need to change any of the settings)
Note: Once you click Start, wait a few seconds (about 1.5s per generation) for the animation to load.

**Custom Set-Up:**
1. Go to:  [Github Template.csv](https://github.com/marcodeanda20/rlife/blob/main/template.csv)
2. Download the template.csv file and edit as you wish
4. Go to: [RLife](https://marcoprojects.shinyapps.io/rlife/)
5. Upload your csv file
6. Enter the number of generations you want to simulate (min=1, max=50)

## How it was built
- R
- R Shiny
- Referenced the following source to understand the game of life and its rules: 
[Wikipedia Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

## Challenges
- Creating a game with R given that it is not usually used for this purpose
- The program worked well locally, but it was difficult to get it launched
- Creating animations
- Many bugs

## Accomplishments
- Most of the identified bugs were fixed
- Generating animated gifs
- Launching it successfully
