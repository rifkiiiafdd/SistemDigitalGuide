# Resume macro file
onbreak {resume}
# Menghapus library yang telah dibuat jika ada
if [file exists work] {
 vdel -all }
# Membuat library
vlib work
# Compile 
vcom bcdTo7segment.vhd

force -freeze sim:/bcdto7segment/Z(3) 0 0, 1 {200 ps} -r 400
force -freeze sim:/bcdto7segment/Z(2) 0 0, 1 {100 ps} -r 200
force -freeze sim:/bcdto7segment/Z(1) 0 0, 1 {50 ps} -r 100
force -freeze sim:/bcdto7segment/Z(0) 0 0, 1 {25 ps} -r 50