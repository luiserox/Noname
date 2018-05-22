#=======================================================================
# Makefile for Noname Project
# Anderson Contreras
#-----------------------------------------------------------------------

#--------------------------------------------------------------------
# Directories
#--------------------------------------------------------------------
OBJ_DIR = sim_obj
SRC_DIR = rtl
TESTS_DIR = tests
BUILD_DIR = build

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------
objs_basename = $(basename $(notdir $(wildcard $(SRC_DIR)/*.v)))
objs_no_test  = $(patsubst %_tb.cpp, %, $(notdir $(filter-out $(objs_basename), $(wildcard $(TESTS_DIR)/*_tb.cpp))))
objs_verilate = $(addsuffix .verilate, $(objs_basename))
objs_compile  = $(addprefix V, $(addsuffix .compile, $(objs_no_test)))
objs_run  	  = $(addprefix V, $(addsuffix .run, $(objs_no_test)))

#--------------------------------------------------------------------
# Build Rules
#--------------------------------------------------------------------
VERILATOR_CFLAGS = -CFLAGS "-std=c++11 -O3"
VERILATOR_OPTS = --Mdir $(OBJ_DIR) -Wno-lint --trace --exe 

#--------------------------------------------------------------------
# Default
#--------------------------------------------------------------------
default: run

#--------------------------------------------------------------------
# Build, compile and run Testbenchs
#--------------------------------------------------------------------
verilate: $(objs_verilate)

compile: verilate $(objs_compile)

run: compile $(objs_run)

#--------------------------------------------------------------------

$(objs_verilate): %.verilate: $(SRC_DIR)/%.v
	@verilator -Wall $(VERILATOR_CFLAGS) $(VERILATOR_OPTS) --cc $< $(patsubst %.verilate, $(TESTS_DIR)/%_tb.cpp, $@)

$(objs_compile): %.compile: $(OBJ_DIR)/%.mk
	@make -C $(OBJ_DIR) -j -f $(patsubst %.compile, %.mk, $@) $(patsubst %.compile, %, $@)

$(objs_run): %.run: $(OBJ_DIR)/%.exe
	@$< | head

#--------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------
clean:
	@rm -rf $(OBJ_DIR) *.vcd