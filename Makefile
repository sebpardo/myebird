all: knit move 

knit:
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("myebird_vignette.Rmd")'

move:
		cp inst/vign/myebird_vignette.md vignettes;\
		cp inst/vign/figure/* vignettes/figure

pandoc:
		cd vignettes;\
		pandoc -H margins.sty myebird_vignette.md -o myebird_vignette.pdf --highlight-style=tango;\
		pandoc -H margins.sty myebird_vignette.md -o myebird_vignette.html --highlight-style=tango

readme:
		Rscript -e 'library(knitr); knit("README.Rmd")'
