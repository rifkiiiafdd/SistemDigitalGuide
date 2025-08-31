# PERCOBAAN 2A: IMPLEMENTASI BCD-TO-7SEGMENT PADA FPGA BOARD 
Pada percobaan ini Anda akan melakukan implementasi dari hasil rancangan BCD-to-7Segment yang 
telah Anda buat pada tugas pendahuluan. 
## PROSEDUR PERCOBAAN: 
1. Buatlah folder baru untuk melakukan percobaan pada praktikum ini. Folder ini nantinya digunakan sebagai 
direktori kerja, untuk menyimpan file-file yang berhubungan dengan praktikum ini. 
2. Buatlah project baru dan import file VHDL BCD-to-7Segment yang telah Anda buat pada tugas pendahuluan. 
3. Lakukan pemetaan pin input dan output. Input menggunakan slide switch dan output menggunakan 7 segment. Buat tabel pin plannernya! Untuk informasi lebih lengkap, lihat Apendiks. 
4. Implementasikan pada FPGA board. 
5. Mainkan switch dan perhatikan apakah program sudah berjalan dengan benar. Gunakan table pengujian seperti pada Apendiks. 
6. Cata hasil percobaan di BCL.

# PERCOBAAN 2B: MERANCANG BCD-TO-7SEGMENT DENGAN LEVEL ABSTRAKSI BEHAVIORAL 
Pada percobaan kali ini kita akan mengimplementasikan desain dengan level abstraksi yang lebih tinggi. Level abstraksi yang tinggi artinya lebih dekat dengan cara manusia berpikir. Pada percobaan ini ditunjukan bahwa kita sering kali tidak perlu melakukan/mencari persamaan logika untuk setiap signal/variable. Pada contoh ini, praktikan cukup menentukan bentuk keluaran, untuk setiap jenis input yang diinginkan. Proses merubah menjadi persamaan Boolean, meminimisasi, dan membuat rangkaian gerbang logikanya dikerjakan oleh tool/software. Dengan cara ini manusia/engineer dapat membuat rangkaian yang lebih besar/kompleks karena tidak perlu memikirkan detailnya. 
## PROSEDUR PERCOBAAN: 
1. Buatlah folder baru untuk melakukan percobaan pada praktikum ini. Folder ini nantinya digunakan sebagai direktori kerja, untuk menyimpan file-file yang berhubungan dengan praktikum ini. 
2. Buatlah file DUT (Device Under Test) dengan cara mengetikkan script di bawah ini menggunakan text editor, kemudian simpan file tersebut di folder yang telah dibuat pada langkah sebelumnya.

<pre> 
LIBRARY ieee;
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all; 
ENTITY bcd IS PORT ( 
SW   : IN STD_LOGIC_VECTOR (3 DOWNTO 0); 
HEX1 : OUT STD_LOGIC_VECTOR (1 TO 7)); 
END bcd; 
 
ARCHITECTURE behavioral OF bcd IS 
 
 CONSTANT NOL     : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; 
 CONSTANT SATU    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001"; 
 CONSTANT DUA     : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010"; 
 CONSTANT TIGA    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011"; 
 CONSTANT EMPAT   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100"; 
 CONSTANT LIMA    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101"; 
 CONSTANT ENAM    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110"; 
 CONSTANT TUJUH   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111"; 
 CONSTANT DELAPAN : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000"; 
 CONSTANT SEMBILAN: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001"; 
 
BEGIN 
 
 PROCESS(SW) 
 BEGIN 
 CASE SW IS 
 WHEN NOL      => HEX1 <= "1111110"; 
 WHEN SATU     => HEX1 <= "0110000"; 
 WHEN DUA      => HEX1 <= "1101101"; 
 WHEN TIGA     => HEX1 <= "1111001"; 
 WHEN EMPAT    => HEX1 <= "0110011"; 
 WHEN LIMA     => HEX1 <= "1011011"; 
 WHEN ENAM     => HEX1 <= "1011111"; 
 WHEN TUJUH    => HEX1 <= "1110000"; 
 WHEN DELAPAN  => HEX1 <= "1111111"; 
 WHEN SEMBILAN => HEX1 <= "1110011"; 
 WHEN OTHERS   => HEX1 <= "0000000";
END CASE;
END PROCESS; 
 
END behavioral; </pre>

3. Jalankan simulasi. Ambil gambar sinyal hasil simulasi tersebut, kemudian sertakan dalam laporan! Analisis sinyal hasil simulasi tersebut ! 
4. Lakukan pemetaan pin input dan output. Input menggunakan slide switch dan output menggunakan 7 segment. Buat tabel pin plannernya! Untuk informasi lebih lengkap, lihat Apendiks. 
5. Implementasikan pada FPGA board. 
6. Mainkan switch dan perhatikan apakah program sudah berjalan dengan benar. Gunakan table pengujian 
seperti pada Apendiks. 
7. Cata hasil percobaan di BCL.

# PERCOBAAN 2C: MEMBUAT RANGKAIAN 4BIT ADDER WITH 7 SEGMENT 

# Tabel Spesifikasi

|          | Signal               | PIN IN/OUT          |
|----------|----------------------|---------------------|
| **Input** | A (4 bit)            | Slide switch [3-0]  |
|          | B (4 bit)            | Slide switch [7-4]  |
|          | Carry_in (1 bit)     | Slide switch [8]    |
| **Output**| A_out (4 bit)        | LED [3-0]           |
|          | B_out (4 bit)        | LED [7-4]           |
|          | Carry_in_out (1 bit) | LED [8]             |
|          | 7Segment_A0 (7 bit)  | HEX4                |
|           | 7Segment_A1 (7 bit) | HEX5                |
|           | 7Segment_B0 (7 bit) | HEX3                |
|           | 7Segment_B1 (7 bit) | HEX2                |
|           | 7Segment_S0 (7 bit) | HEX1                |
|           | 7Segment_S1 (7 bit) | HEX0                |
| **Fungsi** | Menjumlahkan 2 buah unsigned integer 4 bit dan carry 1 bit. Menampilkan nilai 2 buah bilangan dan hasil penjumlahan dalam decimal. Menampilkan flag nilai carry (0 atau 1). | | |


