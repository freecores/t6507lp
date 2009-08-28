#######################################################
#                                                     #
#  Encounter Command Logging File                     #
#  Created on Wed Jul 15 15:54:34                     #
#                                                     #
#######################################################
loadConfig /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/t6507lp_io.conf 0
setUIVar rda_Input ui_gndnet gnd
setUIVar rda_Input ui_pwrnet vdd
commitConfig
fit
setDrawView fplan
loadIoFile /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/extras/iofile/t6507lp_absolute.io
setDrawView place
setDrawView fplan
floorPlan -site core_l -r 2.14232581205 1 0.1 2.0 0.0 6.0
setRoutingStyle -top -style m
uiSetTool select
fit
floorPlan -site core_l -r 1.08982791242 0.330995 0.1 2.0 0.0 9.8
setRoutingStyle -top -style m
uiSetTool select
fit
loadIoFile /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/extras/iofile/t6507lp_absolute.io
setDrawView place
setDrawView fplan
setDrawView ameba
setDrawView place
uiSetTool addPoly
editAddPoly 755.789 1371.149
editAddPoly 1109.842 1291.487
editAddPoly 1092.139 1099.709
editAddPoly 844.302 1146.916
editAddPoly 879.708 1412.455
uiSetTool addWire
uiSetTool select
verifyGeometry
setDrawView fplan
setDrawView ameba
setDrawView place
resizeFP -ySize +1 -proportional
fit
verifyGeometry
saveFPlan /home/nscad/samuel/Desktop/svn_atari/trunk/syn/cadence/results/floorplan/t6507lp_io.fp
setDrawView fplan
addRing -spacing_bottom 1 -width_left 1.2 -width_bottom 1.2 -width_top 1.2 -spacing_top 1 -layer_bottom MET1 -stacked_via_top_layer MET3 -width_right 1.2 -around core -jog_distance 1.15 -offset_bottom 1.15 -layer_top MET1 -threshold 1.15 -offset_left 1.15 -spacing_right 1 -spacing_left 1 -offset_right 1.15 -offset_top 1.15 -layer_right MET2 -nets VDD5R -stacked_via_bottom_layer MET1 -layer_left MET2
checkFPlan -outFile t6507lp_io.checkFPlan
setDrawView fplan
checkFPlan -reportUtil -outFile t6507lp_io.checkFPlan
setDrawView fplan
verifyConnectivity -type all -error 1000 -warning 50
zoomOut
zoomBox 364.554 2227.846 848.658 1808.682
selectMarker 554.5000 1990.4000 639.5000 2075.4000 -1 3 18
deselectAll
selectInst vdd_pad_up
clearDrc
zoomOut
zoomOut
zoomOut
deselectAll
selectInst reset_n_pad
deselectAll
selectInst clk_pad
deselectAll
selectInst vdd_pad_up
deselectAll
addRing -spacing_bottom 1 -width_left 1.2 -width_bottom 1.2 -width_top 1.2 -spacing_top 1 -layer_bottom MET1 -stacked_via_top_layer MET3 -width_right 1.2 -around core -jog_distance 1.15 -offset_bottom 1.15 -layer_top MET1 -threshold 1.15 -offset_left 1.15 -spacing_right 1 -spacing_left 1 -offset_right 1.15 -offset_top 1.15 -layer_right MET2 -nets vdd -stacked_via_bottom_layer MET1 -layer_left MET2
setDrawView place
zoomBox 149.697 1718.492 1962.823 345.352
zoomBox 339.838 561.097 575.250 361.903
zoomBox 417.721 438.576 455.928 422.999
selectWire 427.7500 429.6500 1557.1500 430.8500 1 vdd
zoomOut
deselectAll
selectWire 427.7500 451.7500 428.9500 466.2500 2 vdd
zoomOut
zoomOut
zoomOut
zoomOut
deselectAll
fit
verifyGeometry
selectInst data_in_pad0
zoomBox 377.838 542.336 584.468 338.658
deselectAll
zoomBox 455.037 440.235 526.167 421.862
zoomBox 496.863 431.670 506.275 424.832
selectInst data_in_pad0
deselectAll
selectMarker 497.3000 429.6500 499.9000 430.0000 1 1 6
zoomOut
zoomOut
deselectAll
zoomBox 425.970 432.716 430.247 429.238
selectMarker 427.7500 429.6500 428.9500 430.1000 2 1 1
deselectAll
selectMarker 427.7500 429.6500 428.9500 430.1000 2 1 1
deselectAll
selectWire 427.7500 429.6500 1557.1500 430.8500 1 vdd
deselectAll
selectMarker 427.7500 430.8500 429.6000 431.4000 1 1 2
deselectAll
selectMarker 427.7500 429.6000 428.9500 429.6500 2 1 2
deselectAll
selectMarker 427.7500 429.6500 428.9500 430.1000 2 1 1
deselectAll
selectMarker 427.7500 429.6500 428.9500 430.1000 2 1 1
deselectAll
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomBox 86.331 1781.665 2104.163 152.088
zoomBox 411.300 1679.793 1612.930 1591.623
zoomOut
zoomOut
zoomOut
zoomBox -338.031 1335.676 1942.216 279.561
zoomBox 453.366 443.234 1606.299 372.065
zoomBox 785.860 465.224 876.540 381.741
zoomBox 831.936 430.161 839.634 424.388
selectMarker 833.7000 429.6000 834.1000 429.6500 1 1 2
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
zoomOut
deselectAll
undo
setDrawView ameba
setDrawView fplan
setDrawView place
zoomBox 474.096 1750.997 646.327 1573.844
zoomOut
zoomOut
zoomOut
zoomOut
verifyGeometry
zoomOut
mp::checkFence -clear
setPlanDesignMode -powerAware -createFence -useExistingPowerRail
planDesign
