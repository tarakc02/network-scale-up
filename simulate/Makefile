# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# simulate/Makefile

.PHONY: all clean

all: output/rd-25.rds \
	output/rd-100.rds \
	output/bfx-25.rds \
	output/bfx-100.rds

clean: 
		-rm -r output/*

output/rd-%.rds: src/rand-degree.R
	Rscript --vanilla $< \
			--population_size=1000000 \
			--n_known=10 \
			--n_unknown=3 \
			--mu=5.5 \
			--sigma=1.2 \
			--n_respondents=$* \
			--output=$@

output/bfx-%.rds: src/barrier-fx.R
	Rscript --vanilla $< \
			--population_size=1000000 \
			--n_known=10 \
			--n_unknown=3 \
			--mu=5.5 \
			--sigma=1.2 \
			--n_respondents=$* \
			--output=$@

# done.
