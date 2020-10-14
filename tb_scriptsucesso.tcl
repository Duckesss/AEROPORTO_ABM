if {[file exists work]} {
vdel -lib work -all
}
vlib work
vcom -explicit  -93 "funcao.vhd"
vcom -explicit  -93 "tb_funcao.vhd"
vsim -t 1ns   -lib work tb_funcao
add wave sim:/tb_funcao/*
#do {wave.do}
view wave
view structure
view signals
run 350ns

coverage report -file report
#coverage save  report
#quit -force