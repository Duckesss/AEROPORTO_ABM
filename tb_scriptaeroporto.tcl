if {[file exists work]} {
vdel -lib work -all
}
vlib work
vcom -explicit  -93 "aeroporto.vhd"
vcom -explicit  -93 "tb_aeroporto.vhd"
vsim -t 1ns   -lib work tb_aeroporto
add wave sim:/tb_aeroporto/*
#do {wave.do}
view wave
view structure
view signals
run 350ns