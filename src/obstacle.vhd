library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity obstacle is
	port(
		fps				: in std_logic;
		reset				: in std_logic;
		state				: in T_STATE;
		speed				: in integer;
		destroy			: in std_logic;
		index				: in integer;
		random			: in T_RAND;
		scan_x			: in integer;
		scan_y			: in integer;
		color				: out T_COLOR;
		bounds			: out T_RECT
	);
end entity;

architecture obstacle of obstacle is

	constant initial_rect	: T_RECT := (w => 0, h => 0, x => 0, y => 0);

	signal first_time			: std_logic := '1';
	signal visible				: std_logic := '1';
	signal rect					: T_RECT := initial_rect;

	impure function respawn return T_RECT is
		variable w, y: integer;
	begin
		visible <= '1';
		w := get_rand(random(2 * index), GAME_WIDTH / 10, GAME_WIDTH / 4);
		if first_time = '1' then
			y := -index * OBSTACLES_DISTANCE - GAME_HEIGHT / 3;
		else
			y := 0;
		end if;
		return (
			w => w,
			h => OBSTACLE_HEIGHT,
			x => get_rand(random(2 * index + 1), (GAME_WIDTH + w) / 2 - HALF_WATER_MAX, (GAME_WIDTH - w) / 2 + HALF_WATER_MAX),
			y => y
		);
	end function;

begin

	process(fps, reset)
	begin
		if reset = '1' then
			rect <= initial_rect;
			first_time <= '1';
		elsif rising_edge(fps) then
			if first_time = '1' then
				rect <= respawn;
				first_time <= '0';
			elsif state = RUNNING then
				if destroy = '1' then
					visible <= '0';
				end if;
				if rect.y < GAME_HEIGHT then
					rect.y <= rect.y + speed;
				else
					rect <= respawn;
				end if;
			end if;
		end if;
	end process;

	bounds <= rect;

	color <= "111100001111" when visible = '1' and in_box(scan_x, scan_y, rect) else
				NO_COLOR;

end architecture;
