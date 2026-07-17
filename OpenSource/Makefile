SRC = $(filter-out ../rtl/systolic_array_2x2.sv,$(wildcard ../rtl/*.sv))

TB = ../tb/top_systolic_tb.sv
TOP = top_systolic_tb

WORK = obj_dir/V$(TOP)
WAVE = wave.vcd

.PHONY: all sim run view clean

all: sim

sim: $(WORK)

$(WORK): $(SRC) $(TB)
	verilator -Wall -sv --binary --trace \
		--top-module $(TOP) \
		$(SRC) $(TB)

run: $(WORK)
	./$(WORK)

view:
	gtkwave $(WAVE)

clean:
	rm -rf obj_dir *.vcd *.fst