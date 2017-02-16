# BC Housing Data Challenge



## Running the app

To run the app on your machine, make sure you have [R](https://cran.r-project.org/) installed, then from your terminal:

```shell
git clone https://github.com/cpsievert/bcviz
cd bcviz
make
```

Alternatively, if you don't need/want to clone the github repo, then from your R console:

```r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("cpsievert/bcviz")
bcviz::launch()
```
