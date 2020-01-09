library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity ground is
	port(
		fps				: in std_logic;
		reset				: in std_logic;
		state				: in T_STATE;
		speed				: in integer;
		player			: in T_RECT;
		scan_x			: in integer;
		scan_y			: in integer;
		color				: out T_COLOR;
		bounds			: out T_RECT;
		collision		: out std_logic := '0'
	);
end entity;

architecture ground of ground is

	constant initial_rect	: T_RECT := (w => GAME_WIDTH, h => 7 * GAME_HEIGHT / 3, x => GAME_WIDTH / 2, y => -GAME_HEIGHT / 6);

	signal rect					: T_RECT := initial_rect;

	impure function in_water(box: T_RECT) return boolean is
	begin
		if box.y + box.h / 2 <= rect.y - GAME_HEIGHT / 6 then
			return abs(rect.x - box.x) <= HALF_WATER_MAX - box.w / 2;
		elsif box.y + box.h / 2 >= rect.y + GAME_HEIGHT / 6 then
			return abs(rect.x - box.x) <= HALF_WATER_MIN - box.w / 2;
		else
			return abs(rect.x - box.x) + box.w / 2 <=
			(HALF_WATER_MIN - HALF_WATER_MAX) * (box.y + box.h / 2 - rect.y + GAME_HEIGHT / 6) / (GAME_HEIGHT / 3) + HALF_WATER_MAX;
		end if;
	end function;

begin

	process(fps, reset)
	begin
		if reset = '1' then
			rect <= initial_rect;
			collision <= '0';
		elsif rising_edge(fps) then
			if state = RUNNING then
				if not in_water(player) then
					collision <= '1';
				end if;
				if rect.y < 3 * GAME_HEIGHT / 2 then
					rect.y <= rect.y + speed;
				end if;
			end if;
		end if;
	end process;

	bounds <= rect;

	color <= "000000001111" when in_water((w => 0, h => 0, x => scan_x, y => scan_y)) else
				"000011110000";

end architecture;
