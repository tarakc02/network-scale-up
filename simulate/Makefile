# vim: set ts=4 softtabstop=0 sw=4 si fileencoding=utf-8:
#
# Authors:     TS
# Maintainers: TS
# Copyright:   2020, HRDAG, GPL v2 or later
# =========================================
# simulate/Makefile

.PHONY: all clean

all: output/random-degree-25-resp.rds \
	output/random-degree-50-resp.rds \
	output/random-degree-100-resp.rds

clean: 
		-rm -r output/*

output/random-degree-%-resp.rds: src/sim.R
	Rscript --vanilla $< \
			--population_size=1000000 \
			--n_known=10 \
			--n_unknown=3 \
			--n_respondents=$* \
			--output=$@

# done.
