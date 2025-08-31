------------------------------------------------------------
---Penulis        : TTA21
---Tanggal        : 08/11/2020 , pembaruan terakhir 01/26/2021
---Modul          : Modul UART sederhana untuk komunikasi serial.
---Deskripsi      : Modul ini mengirim dan menerima 8 bit [1 byte] sekaligus, memungkinkan komunikasi sederhana dengan
---sirkuit eksternal lainnya.
--- PEMBARUAN 01/26/2021 : Menghapus kode redundan dan menambahkan fungsi log.
---Tambahan       : Terima kasih banyak kepada TONI [ https://www.youtube.com/watch?v=fMmcSpgOtJ4 ] untuk tutorialnya tentang komunikasi UART,
---saya belajar banyak darinya. Kode ini hampir sepenuhnya miliknya dengan beberapa perbedaan dan penjelasan,
---karena saya tidak dapat menemukan kode sumbernya, saya memutuskan untuk mengunggah ini.

---Terima kasih kepada TONI [ https://www.youtube.com/user/AntoniusSimplus ].

---Ini dikompilasi untuk " ALTERA DE-10 LITE " dengan prosesor " MAX 10 10M50DAF484C7G ", ubah pinout
---untuk perangkat Anda.
---i_DATA terhubung ke sakelar
---i_SEND terhubung ke tombol
---o_TX terhubung ke pin GPIO
---i_RX terhubung ke pin GPIO
---o_sig_CRRP_DATA dapat tidak terhubung
---o_sig_RX_BUSY dapat tidak terhubung
---o_sig_TX_BUSY dapat tidak terhubung
---o_DATA_OUT terhubung ke LED
---i_log_ADDR terhubung ke sakelar

---Pesan dikirim dan diterima dengan input TX/RX arduino uno dan konsol serial.

------------------------------------------------------------

------------------------------------------------------------
---PEMBARUAN 01/26/2021

--- Menghapus kode redundan dan menambahkan log pesan pada RX, dua modul (RX/TX) sekarang dapat digunakan sendiri tanpa modul TOP
---konektor.
--- Log pada RX bekerja sebagai berikut: Ketika pesan baru diterima dan tidak rusak, itu akan ditambahkan ke bank atom
---(MEM_UART), penghitung yang memilih alamat meningkat setiap pesan mulai dari nol hingga 255 ("11111111"),
---dan mengulang. Sinyal (o_sig_RX_BUSY) dapat dilacak untuk memberi tahu saat alamat berubah.
--- Alamat untuk membaca tidak sama dengan alamat untuk menulis, ini berarti alamat apa pun dapat dibaca, tetapi tidak ada yang
---ditulis oleh pengguna.

---TTA21
------------------------------------------------------------

--------------- Pembaruan oleh: Muhammad Iqbal Arsyad
--- Kode ini sudah diubah dan disesuaikan untuk kegiatan Modul 4 Praktikum Sistem Digital

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	port	(
				i_CLOCK		:	in std_logic							;
					----Apa yang akan dikirim, 8 bit atau 1 byte, berasal dari komponen lain
				i_SEND		:	in std_logic							;	----Sinyal "kirim data", berasal dari komponen lain
				i_DISPLAY	:	in	std_logic							;	----Sinyal "tampilkan data", berasal dari komponen lain
				o_TX		:	out std_logic	:='1'					;	----Garis keluaran
				
				i_RX		:	in std_logic							;	----Garis masukan

				led 	   :   out std_logic_vector(3 downto 0);
					----RX memiliki log 255 register yang terhubung ke DATA_OUT, pilih alamat di sini
				
				o_sig_CRRP_DATA		:	out std_logic					;	----Sinyal data rusak
				o_sig_RX_BUSY		:	out std_logic					;	---	tanda jika RX sibuk atau dalam mode menerima.
				o_sig_TX_BUSY		:	out std_logic					;	---	tanda jika TX sibuk atau dalam mode mengirim.
				
				
				hex1			: 	out std_logic_vector(6 downto 0)		--- Sinyal HEX (7 Segmen).
			);
end uart;


architecture behavior of uart is
	--- SINYAL
	signal r_TX_DATA	:	std_logic_vector(7 downto 0) := (others => '1')	;	---	Register yang menyimpan pesan untuk dikirim
	signal s_TX_START	:	std_logic := '0'								;	---	Sinyal yang disimpan untuk memulai transmisi
	signal s_TX_BUSY	:	std_logic										;	---	Sinyal yang disimpan yang mengingatkan komponen utama bahwa sub komponennya "TX" sedang sibuk
	signal i_DATA		:	std_logic_vector(7 downto 0)	:= "00110010"	;	---	Data yang akan dikirim, 8 bit atau 1 byte, berasal dari komponen lain;
	signal o_DATA_OUT	:   std_logic_vector(7 downto 0)	;	----Pesan dari RX, 8 bit atau 1 byte
	signal i_log_ADDR	:	std_logic_vector(7 downto 0)			;

	signal s_rx_data	:	std_logic_vector	(7 downto 0)				;	--- Data RX yang dibaca dari Buffer RX
	signal s_hex		:	std_logic_vector	(6 downto 0)				;	--- Sinyal HEX (7 Segmen) dari Konverter ASCII-HEX.
	signal s_ascii		:	std_logic_vector	(7 downto 0)				;	--- Data RX yang dibaca dari Buffer RX dan menjadi input Konverter ASCII-HEX.
	
	signal s_log_addr		:	std_logic_vector (7 downto 0)	:= (others => '0')	;
	signal s_button_counter	:	integer range 0 to 50000000	:= 0					;	--- penghitung untuk menunda penekanan tombol.
	signal s_allow_press	: std_logic	:= '0'										;	--- sinyal untuk mengizinkan tombol ditekan.
	--- AKHIR SINYAL
	
	--- KOMPONEN
	component uart_tx is
	port(
	
		i_CLOCK	:	in std_logic							;
		i_START	:	in std_logic							;
		o_BUSY	:	out std_logic							;
		i_DATA	:	in std_logic_vector(7 downto 0)	;
		o_TX_LINE:	out std_logic	:= '1'
	
	);
	end component;
	
	component uart_rx is
	port(

		i_CLOCK			:	in std_logic								;
		i_RX			:	in std_logic								;
		o_DATA			:	out std_logic_vector(7 downto 0)			;
		i_log_ADDR		:	in std_logic_vector( 7 downto 0 )			;
		o_sig_CRRP_DATA:	out std_logic := '0'						;
		o_BUSY			:	out std_logic

	);
	end component;
	
	
	component asciiHex is
		port	(
					i_ascii			:		in		std_logic_vector	(7 downto 0);
					hex1			:		out		std_logic_vector	(6 downto 0)
				);
	end component;
	--- AKHIR KOMPONEN
begin
	led <= "0000";
	--- Modul Pengirim
	u_TX	:	uart_tx port map(
	
		i_CLOCK	=>	i_CLOCK		,
		i_START	=>	s_TX_START	,
		o_BUSY	=>	s_TX_BUSY	,
		i_DATA	=>	r_TX_DATA	,
		
		o_TX_LINE	=>	o_TX
	
	);
	
	--- Modul Penerima
	u_RX	:	uart_rx port map(
	
		i_CLOCK				=>	i_CLOCK				,
		i_RX				=>	i_RX				,
		o_DATA				=>	s_rx_data			,
		i_log_ADDR			=>	s_log_addr			,
		o_sig_CRRP_DATA		=>	o_sig_CRRP_DATA		,
		o_BUSY				=>	o_sig_RX_BUSY
		
	);
	
	
	--- Modul Konverter ASCII ke HEX (7 Segmen)
	a2h	:	asciiHex	port map(
		
		i_ascii	=>	s_ascii	,
		hex1		=>	s_hex
	);
		
	s_ascii <= s_rx_data;		---	data rx yang dibaca dari buffer menjadi input konverter ascii-hex
	o_DATA_OUT <= s_rx_data;	--- data rx yang dibaca dari buffer ditampilkan pada LED[7 .. 0]
	hex1	<= s_hex;			--- data rx yang dibaca dari buffer ditampilkan pada 7 Segmen.
	
	
	------------------------------------------------------------
	--- penundaan untuk menangani bouncing tombol
	p_button		:	process(i_CLOCK) begin
		if(rising_edge(i_CLOCK)) then
			if(s_button_counter = 49999900) then
				s_button_counter <= 0;
				s_allow_press <= '1';
			else
				s_button_counter <= s_button_counter + 1;
				s_allow_press <= '0';
			end if;
		end if;
	end process;
	--- akhir dari proses penundaan

	--- Sub-rutin transmisi memeriksa ketersediaan untuk mengirim sesuatu sebelum mengirimnya,
	---semua hal lain ditangani secara internal.
	--- proses: untuk menampilkan data di Buffer RX. alamat buffer dipilih menggunakan sakelar. perintah display menggunakan tombol key_1.
	p_DISPLAY_RX	:	process	(i_CLOCK) begin
		if(rising_edge(i_CLOCK)) then
			if(
				i_DISPLAY = '0' and				--- Tombol Display ditekan
				s_allow_press = '1'				--- tombol diizinkan untuk ditekan
				) then
				s_log_addr <= i_DATA;			---	setel alamat data yang ingin ditampilkan dari buffer RX. 
			end if;
		end if;
	end process;
	--- akhir dari proses
	
	--- proses: untuk melakukan pengiriman data. input data diatur dari sakelar. perintah pengiriman menggunakan tombol key_0.
	p_TRANSMIT	:	process(i_CLOCK) begin
	
		if(rising_edge(i_CLOCK)) then
			------------------------------------------------------------
		
			--- Jika memungkinkan, kirim byte data di input.
			if( 
				i_SEND = '0' and 		----	Tombol Kirim ditekan
				s_TX_BUSY = '0' and 	----	pengirim tidak sibuk / tidak mengirim
				s_allow_press = '1'		----  	tombol diizinkan untuk ditekan
				) then 					----	Kirim pesan jika subkomponen "TX" tidak sibuk
			
				r_TX_DATA	<=	i_DATA;									----Berikan pesan subkomponen
				s_TX_START	<=	'1';									----Beri tahu untuk mengirim

			else
			
				s_TX_START <= '0';									----Jika Subkomponen "TX" sibuk, atau tombol tidak ditekan, jangan kirim
				
			end if;	---KEY(0) = '0' dan s_TX_BUSY = '0'
			
			------------------------------------------------------------
			
		
		end if;	---rising_edge(i_CLOCK)
	
	end process;
	
	------------------------------------------------------------

end behavior;