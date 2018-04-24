ScCSVs = threads_1.csv threads_2.csv threads_4.csv threads_8.csv threads_16.csv
LnCSVs = threads_1_avg.csv threads_2_avg.csv threads_4_avg.csv threads_8_avg.csv threads_16_avg.csv
BarCSVs = threads_spd.csv
CSVs = $(ScCSVs) $(LnCSVs) $(BarCSVs)

ScPlots = threads_1.eps threads_1.tex threads_2.eps threads_2.tex threads_4.eps threads_4.tex threads_8.eps threads_8.tex threads_16.eps threads_16.tex
LnPlots = threads_avg.eps threads_avg.tex 
BarPlots = threads_spd.eps threads_spd.tex threads_spd_err.eps threads_spd_err.tex
Plots = $(ScPlots) $(LnPlots) $(BarPlots)

all: report
report: report.pdf
plot: $(Plots)
analyse: $(CSVs)
runtest: log.txt
App: app

report.pdf: report.tex $(Plots)
	pdflatex report.tex
$(LnPlots): line.p $(LnCSVs)
	gnuplot line.p
$(BarPlots): bar.p $(BarCSVs)
	gnuplot bar.p
$(ScPlots): scatter.p $(ScCSVs)
	gnuplot scatter.p
$(CSVs): analyse.py log.txt
	python2 analyse.py
log.txt: runtest.py app threads.txt params.txt
	python2 runtest.py
app: common.h prog.c thread_function.c
	gcc -o app prog.c thread_function.c -lm -lpthread

clean:
	rm -f $(CSVs) $(Plots) threads_*-eps-converted-to.pdf app report.aux report.log report.pdf log.txt
