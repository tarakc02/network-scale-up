# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# network-scale-up/assess-fit/Makefile

.PHONY: all clean

all: output/checkfit-rd-100-rd.png \
	output/checkfit-rd-100-bfx.png \
	output/checkfit-bfx-25-bfx.png \
	output/checkfit-rd-25-rd.png \
	output/checkfit-bfx-100-rd.png \
	output/checkfit-bfx-25-rd.png \
	output/checkfit-rd-25-bfx.png \
	output/checkfit-bfx-100-bfx.png

clean: 
		-rm -r output/*

output/checkfit-%-rd.png: src/model-checks.R \
		input/%.rds \
		input/fit-%-rd.rds
	Rscript --vanilla $< \
			--data=input/$*.rds \
			--fit=input/fit-$*-rd.rds \
			--outdir=output

output/checkfit-%-bfx.png: src/model-checks.R \
		input/%.rds \
		input/fit-%-bfx.rds
	Rscript --vanilla $< \
			--data=input/$*.rds \
			--fit=input/fit-$*-bfx.rds \
			--outdir=output

# done.
