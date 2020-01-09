library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity vga_controller is
	port(
		clk_50			: in std_logic;
		reset				: in std_logic;
		vs					: out std_logic;
		hs					: out std_logic;
		red				: out std_logic_vector(3 downto 0);
		green				: out std_logic_vector(3 downto 0);
		blue				: out std_logic_vector(3 downto 0);
		color_in			: in T_COLOR;
		scan_x			: out integer;
		scan_y			: out integer
	);
end entity;

architecture vga_controller of vga_controller is

	constant h_display_area		: integer := 640;
	constant h_limit				: integer := 800;
	constant h_front_porch		: integer := 16;
	constant h_back_porch		: integer := 48;
	constant h_sync_width		: integer := 96;
	constant v_display_area		: integer := 480;
	constant v_limit				: integer := 525;
	constant v_front_porch		: integer := 10;
	constant v_back_porch		: integer := 33;
	constant v_sync_width		: integer := 2;

	signal clk_25							: std_logic := '0';  
	signal h_blank, v_blank, blank	: std_logic := '0';
	signal current_h_pos					: integer := 0;
	signal current_v_pos					: integer := 0;

begin

	generate_clk_25: process (clk_50)
	begin
		if rising_edge(clk_50) then
			clk_25 <= not clk_25;
		end if;
	end process generate_clk_25;

	vga_position: process (clk_25, reset)
	begin
		if reset = '1' then
			current_h_pos <= 0;
			current_v_pos <= 0;
		elsif rising_edge(clk_25) then
			if current_h_pos < h_limit - 1 then
				current_h_pos <= current_h_pos + 1;
			else
			  if current_v_pos < v_limit - 1 then
					current_v_pos <= current_v_pos + 1;
			  else
					current_v_pos <= 0;
			  end if;
			  current_h_pos <= 0;
			end if;
		end if;
	end process vga_position;

	hs <= '0' when current_h_pos < h_sync_width else '1';

	vs <= '0' when current_v_pos < v_sync_width else '1';

	h_blank <= '0' when (current_h_pos >= h_sync_width + h_front_porch) and (current_h_pos < h_sync_width + h_front_porch + h_display_area) else '1';

	v_blank <= '0' when (current_v_pos >= v_sync_width + v_front_porch) and (current_v_pos < v_sync_width + v_front_porch + v_display_area) else '1';

	blank <= '1' when h_blank = '1' or v_blank = '1' else '0';

	scan_x <= current_h_pos - h_sync_width - h_front_porch when blank = '0' else 0;

	scan_y <= current_v_pos - v_sync_width - v_front_porch when blank = '0' else 0;

	red <= color_in(11 downto 8) when blank = '0' else "0000";

	green	<= color_in(7 downto 4) when blank = '0' else "0000";

	blue	<= color_in(3 downto 0) when blank = '0' else "0000";

end architecture;
