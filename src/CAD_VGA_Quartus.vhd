library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity CAD_VGA_Quartus is
	port(
		CLOCK_50 	: in std_logic;
		CLOCK2_50	: in std_logic;
		CLOCK3_50	: in std_logic;
		CLOCK4_50	: inout std_logic;

		RESET_N	: in std_logic;
		KEY 		: in std_logic_vector(3 downto 0);

		HEX0	: out std_logic_vector(6 downto 0);
		HEX1	: out std_logic_vector(6 downto 0);
		HEX2	: out std_logic_vector(6 downto 0);
		HEX3	: out std_logic_vector(6 downto 0);
		HEX4	: out std_logic_vector(6 downto 0);
		HEX5	: out std_logic_vector(6 downto 0);

		LEDR	: out std_logic_vector(9 downto 0);

		SW : in std_logic_vector(9 downto 0);

		VGA_R		: out std_logic_vector(3 downto 0);
		VGA_G		: out std_logic_vector(3 downto 0);
		VGA_B		: out std_logic_vector(3 downto 0);
		VGA_VS	: out std_logic;
		VGA_HS	: out std_logic
	);
end entity;

architecture CAD_VGA_Quartus of CAD_VGA_Quartus is

	signal seg					: T_SEG;
	signal scan_x, scan_y	: integer;
	signal color_table		: T_COLOR;

begin

	vga_control: entity work.vga_controller(vga_controller)
		port map(
			clk_50		=> CLOCK_50,
			reset			=> not RESET_N,
			vs				=> VGA_VS,
			hs				=> VGA_HS,
			red			=> VGA_R,
			green			=> VGA_G,
			blue			=> VGA_B,
			color_in		=> color_table,
			scan_x		=> scan_x,
			scan_y		=> scan_y
		);

	game_setup: entity work.game(game)
		port map(
			clk				=> CLOCK_50,
			reset				=> not RESET_N,
			scan_x			=> scan_x,
			scan_y			=> scan_y,
			key 				=> KEY,
			sw					=> SW,
			color_table		=> color_table,
			ledr				=> LEDR,
			seven_seg		=> seg
		);

	HEX0 <= int_seg(seg(0));
	HEX1 <= int_seg(seg(1));
	HEX2 <= int_seg(seg(2));
	HEX3 <= int_seg(seg(3));
	HEX4 <= int_seg(seg(4));
	HEX5 <= int_seg(seg(5));

end architecture;
