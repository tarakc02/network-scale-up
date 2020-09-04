# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# network-scale-up/fit-model/Makefile

.PHONY: all clean

all: output/fit-rd-25-rd.rds \
	output/fit-rd-100-rd.rds \
	output/fit-rd-25-bfx.rds \
	output/fit-rd-100-bfx.rds \
	output/fit-bfx-25-rd.rds \
	output/fit-bfx-100-rd.rds \
	output/fit-bfx-25-bfx.rds \
	output/fit-bfx-100-bfx.rds

clean: 
		-rm -r output/*

output/fit-rd-%-rd.rds: src/fit.R \
		src/rd.stan \
		input/rd-%.rds
	Rscript --vanilla $< \
			--data=input/rd-$*.rds \
			--model=src/rd.stan \
			--output=$@ > $@.log

output/fit-rd-%-bfx.rds: src/fit.R \
		src/bfx.stan \
		input/rd-%.rds
	Rscript --vanilla $< \
			--data=input/rd-$*.rds \
			--model=src/bfx.stan \
			--output=$@ > $@.log

output/fit-bfx-%-rd.rds: src/fit.R \
		src/rd.stan \
		input/bfx-%.rds
	Rscript --vanilla $< \
			--data=input/bfx-$*.rds \
			--model=src/rd.stan \
			--output=$@ > $@.log

output/fit-bfx-%-bfx.rds: src/fit.R \
		src/bfx.stan \
		input/bfx-%.rds
	Rscript --vanilla $< \
			--data=input/bfx-$*.rds \
			--model=src/bfx.stan \
			--output=$@ > $@.log

# done.
