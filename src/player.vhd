library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity player is
	port(
		fps				: in std_logic;
		reset				: in std_logic;
		state				: in T_STATE;
		speed				: in integer;
		go_left			: in std_logic;
		go_right			: in std_logic;
		scan_x			: in integer;
		scan_y			: in integer;
		color				: out T_COLOR;
		bounds			: out T_RECT
	);
end entity;

architecture player of player is

	constant initial_rect	: T_RECT := (w => PLAYER_WIDTH, h => PLAYER_HEIGHT, x => GAME_WIDTH / 2, y => GAME_HEIGHT - 2 * PLAYER_HEIGHT);

	signal rect					: T_RECT := initial_rect;

	impure function in_bound return boolean is
	begin 
		return in_box(scan_x, scan_y, (w => rect.w / 6, h => rect.h, x => rect.x, y => rect.y))
			or in_box(scan_x, scan_y, (w => rect.w, h => rect.h / 5, x => rect.x, y => rect.y - rect.h / 6))
			or in_box(scan_x, scan_y, (w => rect.w / 2, h => rect.h / 6, x => rect.x, y => rect.y + 4 * rect.h / 12));
	end function;

begin

	process(fps, reset)
	begin
		if reset = '1' then
			rect <= initial_rect;
		elsif rising_edge(fps) then
			if state = RUNNING then
				if go_left = '1' and go_right = '0' then
					rect.w <= 3 * PLAYER_WIDTH / 4;
					rect.x <= rect.x - 2 * speed;
				elsif go_left = '0' and go_right = '1' then
					rect.w <= 3 * PLAYER_WIDTH / 4;
					rect.x <= rect.x + 2 * speed;
				else
					rect.w <= PLAYER_WIDTH;
				end if;
			end if;
		end if;
	end process;

	bounds <= rect;

	color <= "111111110000" when in_bound else
				NO_COLOR;

end architecture;
