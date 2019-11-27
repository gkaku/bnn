VHDL_ANALYSIS = vhdlan -full64 -vhdl08
ELABORATION   = vcs -full64
SIM_FILE      = simfile
EVCD_OPTIONS  = -debug_access+pp +optconfigfile+evcd_dump.cfg
EVCD_SCRIPT   = evcd_dump.tcl
#SOURCES       = ./sim_file/conv_layer_6_sim.vhd ./sourceFile/layer_6/conv_layer_6.vhd ./sourceFile/layer_6/single_step_conv.vhd ./sourceFile/matmul3x3.vhd
#TOP_ENTITY    = conv_layer_6_tb
ROM_SOURCES       = ./sim_file/rom_sim.vhd ./sourceFile/utilities/rom.vhd
ROM_TOP_ENTITY    = rom_sim
LAYER6_SOURCES       = ./sim_file/layer_6_sim.vhd ./sourceFile/layer_6/layer_6.vhd ./sourceFile/layer_6/conv_layer_6.vhd ./sourceFile/layer_6/single_step_conv.vhd ./sourceFile/utilities/matmul3x3.vhd ./sourceFile/utilities/max_pooling.vhd ./sourceFile/utilities/max.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER6_TOP_ENTITY    = layer_6_sim
LAYER5_SOURCES       = ./sim_file/layer_5_sim.vhd ./sourceFile/layer_5/layer_5.vhd ./sourceFile/layer_5/conv_layer_5.vhd ./sourceFile/layer_5/single_step_conv_5.vhd ./sourceFile/utilities/matmul3x3.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER5_TOP_ENTITY    = layer_5_sim
LAYER4_SOURCES       = ./sim_file/layer_4_sim.vhd ./sourceFile/layer_4/layer_4.vhd ./sourceFile/layer_4/conv_layer_4.vhd ./sourceFile/layer_4/single_step_conv_4.vhd ./sourceFile/utilities/matmul3x3.vhd ./sourceFile/utilities/max_pooling.vhd ./sourceFile/utilities/max.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER4_TOP_ENTITY    = layer_4_sim
LAYER3_SOURCES       = ./sim_file/layer_3_sim.vhd ./sourceFile/layer_3/layer_3.vhd ./sourceFile/layer_3/conv_layer_3.vhd ./sourceFile/layer_3/single_step_conv_3.vhd ./sourceFile/utilities/matmul3x3.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER3_TOP_ENTITY    = layer_3_sim
LAYER2_SOURCES       = ./sim_file/layer_2_sim.vhd ./sourceFile/layer_2/layer_2.vhd ./sourceFile/layer_2/conv_layer_2.vhd ./sourceFile/layer_2/single_step_conv_2.vhd ./sourceFile/utilities/matmul3x3.vhd ./sourceFile/utilities/max_pooling.vhd ./sourceFile/utilities/max.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER2_TOP_ENTITY    = layer_2_sim
LAYER1_SOURCES       = ./sim_file/layer_1_sim.vhd ./sourceFile/layer_1/layer_1.vhd ./sourceFile/layer_1/conv_layer_1.vhd ./sourceFile/layer_1/single_step_conv_1.vhd ./sourceFile/layer_1/matmul3x3_8bits.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
LAYER1_TOP_ENTITY    = layer_1_sim
BN_SOURCES       = ./sim_file/batch_norm_binarize_6_sim.vhd ./sourceFile/utilities/batch_norm_binarize.vhd
BN_TOP_ENTITY    = batch_norm_binarize_6_sim
SING_FC_SOURCES       = ./sim_file/single_step_fc_sim.vhd ./sourceFile/utilities/single_step_fc.vhd
SING_FC_TOP_ENTITY    = single_step_fc_tb
FC1_SOURCES       = ./sim_file/fc_1_sim.vhd ./sourceFile/fully_connected/fc_1.vhd ./sourceFile/utilities/single_step_fc.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
FC1_TOP_ENTITY    = fc_1_sim
FC2_SOURCES       = ./sim_file/fc_2_sim.vhd ./sourceFile/fully_connected/fc_2.vhd ./sourceFile/utilities/single_step_fc.vhd ./sourceFile/utilities/batch_norm_binarize.vhd ./sourceFile/utilities/rom.vhd 
FC2_TOP_ENTITY    = fc_2_sim
FC3_SOURCES       = ./sim_file/fc_3_sim.vhd ./sourceFile/fully_connected/fc_3.vhd ./sourceFile/utilities/single_step_fc.vhd ./sourceFile/utilities/rom.vhd 
FC3_TOP_ENTITY    = fc_3_sim
MATMUL3X3_8BITS_SOURCES    = ./sourceFile/layer_1/matmul3x3_8bits.vhd 
MATMUL3X3_8BITS_TOP_ENTITY    = matmul3x3_8bits
SINGLE_1_SOURCES    = ./sourceFile/layer_1/single_step_conv_1.vhd ./sourceFile/layer_1/matmul3x3_8bits.vhd 
SINGLE_1_TOP_ENTITY    = single_step_conv_1
BNN_SOURCES       = ./sim_file/bnn_sim.vhd ./sourceFile/bnn.vhd $(LAYER1_SOURCES) $(LAYER2_SOURCES) $(LAYER3_SOURCES) $(LAYER4_SOURCES) $(LAYER5_SOURCES) $(LAYER6_SOURCES) $(FC1_SOURCES) $(FC2_SOURCES) $(FC3_SOURCES)
BNN_TOP_ENTITY    = bnn_sim


all:
	$(VHDL_ANALYSIS) $(BNN_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(BNN_TOP_ENTITY)

matmul3x3_8bits:
	$(VHDL_ANALYSIS) $(MATMUL3X3_8BITS_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(MATMUL3X3_8BITS_TOP_ENTITY)

single1:
	$(VHDL_ANALYSIS) $(SINGLE_1_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(SINGLE_1_TOP_ENTITY)


sing_fc:
	$(VHDL_ANALYSIS) $(SING_FC_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(SING_FC_TOP_ENTITY)

fc1:
	$(VHDL_ANALYSIS) $(FC1_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(FC1_TOP_ENTITY)

fc2:
	$(VHDL_ANALYSIS) $(FC2_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(FC2_TOP_ENTITY)

fc3:
	$(VHDL_ANALYSIS) $(FC3_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(FC3_TOP_ENTITY)
	
rom:
	$(VHDL_ANALYSIS) $(ROM_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(ROM_TOP_ENTITY)

layer6:
	$(VHDL_ANALYSIS) $(LAYER6_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER6_TOP_ENTITY)

layer5:
	$(VHDL_ANALYSIS) $(LAYER5_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER5_TOP_ENTITY)

layer4:
	$(VHDL_ANALYSIS) $(LAYER4_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER4_TOP_ENTITY)

layer3:
	$(VHDL_ANALYSIS) $(LAYER3_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER3_TOP_ENTITY)

layer2:
	$(VHDL_ANALYSIS) $(LAYER2_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER2_TOP_ENTITY)

layer1:
	$(VHDL_ANALYSIS) $(LAYER1_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(LAYER1_TOP_ENTITY)

bn6:
	$(VHDL_ANALYSIS) $(BN_SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(BN_TOP_ENTITY)

dump:
	$(VHDL_ANALYSIS) $(SOURCES)
	$(ELABORATION) -o $(SIM_FILE) $(EVCD_OPTIONS) $(TOP_ENTITY)


run:
	./${SIM_FILE}

run_dump:
	./${SIM_FILE} -ucli -i $(EVCD_SCRIPT)

diff:
	diff conv6_z.txt output.txt

clean:
	rm -rf $(SIM_FILE) $(SIM_FILE).daidir 64 csrc ucli.key
