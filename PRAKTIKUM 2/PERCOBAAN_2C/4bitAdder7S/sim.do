# Resume macro file
onbreak {resume}
# Menghapus library yang telah dibuat jika ada
if [file exists work] {
 vdel -all
}
# Membuat library
vlib work
# Compile 
vcom adder4bit7segment.vhd
vcom fulladder.vhd
vcom bcdToSeven.vhd
vcom binaryToBcd.vhd


force -freeze sim:/adder4bit7segment/C_in 0 0, 0 {1600 ps} -r 3200
force -freeze sim:/adder4bit7segment/B(0) 0 0, 1 {25 ps} -r 50
force -freeze sim:/adder4bit7segment/B(1) 0 0, 1 {50 ps} -r 100
force -freeze sim:/adder4bit7segment/B(2) 0 0, 1 {100 ps} -r 200
force -freeze sim:/adder4bit7segment/B(3) 0 0, 1 {200 ps} -r 400
force -freeze sim:/adder4bit7segment/A(0) 0 0, 1 {400 ps} -r 800
force -freeze sim:/adder4bit7segment/A(1) 0 0, 1 {800 ps} -r 1600
force -freeze sim:/adder4bit7segment/A(2) 0 0, 1 {1600 ps} -r 3200
force -freeze sim:/adder4bit7segment/A(3) 0 0, 1 {3200 ps} -r 6400