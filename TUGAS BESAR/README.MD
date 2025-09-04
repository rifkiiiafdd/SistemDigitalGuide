##  Deskripsi

CORDIC (COordinate Rotation DIgital Computer) adalah algoritma efisien yang digunakan untuk menghitung berbagai fungsi matematika seperti trigonometri (sin, cos, tan), fungsi hiperbolik, eksponensial, logaritma, dan operasi aritmetika lainnya. Algoritma ini hanya memerlukan operasi penjumlahan, pengurangan, pergeseran bit, dan pencarian tabel, sehingga sangat cocok untuk implementasi pada perangkat keras dengan sumber daya terbatas, seperti mikrokontroler dan FPGA. 
Menggunakan algoritma CORDIC (Coordinate Rotation Digital Computer), Kelompok 17 merancang sistem navigasi yang memungkinkan robot untuk bergerak lincah di tengah meja-meja dan pelanggan yang lalu-lalang. Peta dua dimensi tata letak kafe menjadi panduan bagi robot untuk menentukan arah dan jalur terbaik dalam mengantarkan pesanan. Algoritma ini juga memastikan setiap perhitungan dilakukan dengan efisiensi tinggi, sehingga robot bisa melayani sepanjang hari tanpa boros daya.


## Spesifikasi

## Spesifikasi Teknis Sistem

| No | Spesifikasi | Keterangan |
|----|-------------|------------|
| 1  | **Ketelitian** | Ketelitian sudut adalah **0.001 derajat**. Ketelitian besar vektor adalah **0.001 cm** untuk output dan **1 cm** untuk input. |
| 2  | **Input** | Sistem menerima **koordinat kartesian saat ini (X0, Y0)** dan **koordinat tujuan (X1, Y1)**, masing-masing dengan resolusi **10 bit**.<br><br>Sudut saat ini (T0) memiliki ketelitian **0.001 derajat**, dengan resolusi **35 bit** (8 bit untuk integer, 26 bit untuk fractional, dan 1 bit tanda). |
| 3  | **Output** | Sistem menghasilkan koordinat polar berupa **radius (R)** dengan ketelitian **0.001 cm** dan **perubahan sudut (ΔT)** dengan ketelitian **0.001 derajat**. |
| 4  | **Interface** | Input dan output dikirim melalui **UART** yang terhubung ke komputer/laptop, dan data hasil dapat ditampilkan di monitor. |
| 5  | **Blok Fungsi** | Sistem menggunakan komponen seperti:<br> - **UART RX**: Penerima data.<br> - **UART TX**: Pengirim data.<br> - **CORDIC**: Menghitung R dan ΔT.<br> - **Kuadran Detector**: Menentukan kuadran.<br> - **Kuadran Decoder**: Mengatur rotasi sudut.<br> - **Shortest Way**: Menentukan rotasi terkecil.<br> - **Verification**: Memverifikasi input.<br> - **Create Message**: Membuat pesan.<br> - **Binary-to-BCD Converter**: Mengubah data biner ke BCD.<br> - **BCD-to-Binary Converter**: Mengubah data BCD ke biner.<br> - **Fix Point Converter**: Konversi bilangan tetap.<br> - **Right Shifter**: Pembagi 2.<br> - **Penjumlahan (Adder)**<br> - **Pengurangan (Subtractor)** |


## Contributor
- Rifki Afriadi (El'23)
- William Anthony (El'23)