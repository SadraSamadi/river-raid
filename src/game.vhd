library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity game is
	port(
		clk				: in std_logic;
		reset				: in std_logic;
		scan_x			: in integer;
		scan_y			: in integer;
		key 				: in std_logic_vector(3 downto 0);
		sw					: in std_logic_vector(9 downto 0);
		color_table		: out std_logic_vector(11 downto 0);
		ledr				: out std_logic_vector(9 downto 0);
		seven_seg		: out T_SEG
	);
end entity;

architecture game of game is

	type T_OBSTACLES_COLOR is array (0 to OBSTACLES - 1) of T_COLOR;
	type T_OBSTACLES_BOUNDS is array (0 to OBSTACLES - 1) of T_RECT;

	signal state, next_state		: T_STATE;
	signal fps							: std_logic := '0';
	signal prescaler					: integer := 0;
	signal counter						: integer := 0;
	signal timer						: integer := 0;
	signal score						: integer := 0;
	signal speed						: integer := 1;
	signal collision					: std_logic := '0';
	signal random						: T_RAND;
	signal ground_color				: T_COLOR;
	signal ground_bounds				: T_RECT;
	signal ground_collision			: std_logic;
	signal player_color				: T_COLOR;
	signal player_left				: std_logic := '0';
	signal player_right				: std_logic := '0';
	signal player_bounds				: T_RECT;
	signal bullet_fired				: std_logic := '0';
	signal bullet_bounds				: T_RECT;
	signal bullet_color				: T_COLOR;
	signal obstacles_color			: T_OBSTACLES_COLOR;
	signal obstacles_bounds			: T_OBSTACLES_BOUNDS;
	signal obstacles_passed			: std_logic_vector(OBSTACLES - 1 downto 0) := (others => '0');
	signal obstacles_distroyed		: std_logic_vector(OBSTACLES - 1 downto 0) := (others => '0');

begin

	random_generator: entity work.lfsr(lfsr)
		port map(
			clk				=> clk,
			reset				=> reset,
			pseudo_rand		=> random
		);

	game_ground: entity work.ground(ground)
		port map(
			fps				=> fps,
			reset				=> reset,
			state				=> state,
			speed				=> speed,
			player			=> player_bounds,
			scan_x			=> scan_x,
			scan_y			=> scan_y,
			color				=> ground_color,
			bounds			=> ground_bounds,
			collision		=> ground_collision
		);

	game_player: entity work.player(player)
		port map(
			fps				=> fps,
			reset				=> reset,
			state				=> state,
			speed				=> speed,
			go_left			=> player_left,
			go_right			=> player_right,
			scan_x			=> scan_x,
			scan_y			=> scan_y,
			color				=> player_color,
			bounds			=> player_bounds
		);

	game_bullet: entity work.bullet(bullet)
		port map(
			fps				=> fps,
			reset				=> reset,
			state				=> state,
			speed				=> speed,
			player			=> player_bounds,
			fired				=> bullet_fired,
			scan_x			=> scan_x,
			scan_y			=> scan_y,
			color				=> bullet_color,
			bounds			=> bullet_bounds
		);

	game_obstacles: for i in 0 to OBSTACLES - 1 generate
		game_obstacle: entity work.obstacle(obstacle)
			port map(
				index				=> i,
				fps				=> fps,
				reset				=> reset,
				state				=> state,
				speed				=> speed,
				destroy			=> obstacles_distroyed(i),
				random			=> random,
				scan_x			=> scan_x,
				scan_y			=> scan_y,
				color				=> obstacles_color(i),
				bounds			=> obstacles_bounds(i)
			);
	end generate;

	main_process: process(clk, reset)
	begin
		if reset = '1' then
			state <= WAITING;
			timer <= 0;
			prescaler <= 0;
			counter <= 0;
			speed <= 1;
		elsif rising_edge(clk) then
			state <= next_state;
			if prescaler >= 500000 then
				fps <= not fps;
				prescaler <= 0;
			else
				prescaler <= prescaler + 1;
			end if;
			if state = RUNNING then
				if counter >= 50000000 then
					if timer > 0 and (timer mod 15) = 0 then
						speed <= speed + 1;
					end if;
					timer <= timer + 1;
					counter <= 0;
				else
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

	game_process: process(fps, reset)
		variable obstacle, ahead		: T_RECT;
		variable obstacle_collision	: std_logic;
	begin
		if reset = '1' then
			score <= 0;
			collision <= '0';
			bullet_fired <= '0';
			player_left <= '0';
			player_right <= '0';
			obstacles_passed <= (others => '0');
			obstacles_distroyed <= (others => '0');
		elsif rising_edge(fps) then
			if state = RUNNING then
				if bullet_bounds.y < 0 then
					bullet_fired <= '0';
				end if;
				if key(3) = '0' then -- fire bullet
					bullet_fired <= '1';
				end if;
				if sw(0) = '0' then -- auto pilot
					for i in 0 to OBSTACLES - 1 loop
						obstacle := obstacles_bounds(i);
						if obstacles_distroyed(i) = '0' and
							obstacle.y + obstacle.h / 2 < player_bounds.y - player_bounds.h / 2 and
							player_bounds.y + (player_bounds.h + obstacle.h) / 2 - obstacle.y < OBSTACLES_DISTANCE then
							ahead := obstacle;
						end if;
					end loop;
					player_left <= '0';
					player_right <= '0';
					if abs(player_bounds.x - ahead.x) <= (player_bounds.w + ahead.w) / 2 then
						if player_bounds.x <= ahead.x then
							if ahead.x - ahead.w / 2 - ground_bounds.x + HALF_WATER_MAX > PLAYER_WIDTH + 2 * speed then
								player_left <= '1';
							else
								player_right <= '1';
							end if;
						else
							if ground_bounds.x + HALF_WATER_MAX - ahead.x - ahead.w / 2 > PLAYER_WIDTH + 2 * speed then
								player_right <= '1';
							else
								player_left <= '1';
							end if;
						end if;
					end if;
				else
					player_left <= not key(2);
					player_right <= not key(1);
				end if;
				obstacle_collision := '0';
				for i in 0 to OBSTACLES - 1 loop
					obstacle := obstacles_bounds(i);
					if obstacles_distroyed(i) = '0' and bullet_fired = '1' and box_collision(obstacle, bullet_bounds) then
						obstacles_distroyed(i) <= '1';
						score <= score + 1;
						bullet_fired <= '0';
					end if;
					if obstacle.y - obstacle.h / 2 > player_bounds.y + player_bounds.h / 2 then
						if obstacles_passed(i) = '0' then
							score <= score + 1;
							obstacles_passed(i) <= '1';
							obstacles_distroyed(i) <= '0';
						end if;
					else
						obstacles_passed(i) <= '0';
					end if;
					if obstacles_distroyed(i) = '0' and box_collision(obstacle, player_bounds) then
						obstacle_collision := '1';
					end if;
				end loop;
				collision <= ground_collision or obstacle_collision;
			end if;
		end if;
	end process;

	next_state_process: process(state, key, sw, timer, score, collision)
	begin
		case state is
			when WAITING =>
				if key(3) = '0' or key(2) = '0' or key(1) = '0' then
					next_state <= RUNNING;
				else
					next_state <= WAITING;
				end if;
			when RUNNING =>
				if timer >= 99 or score >= 99 or collision = '1' then
					next_state <= STOPPED;
				else
					next_state <= RUNNING;
				end if;
			when STOPPED => next_state <= STOPPED;
			when others => next_state <= WAITING;
		end case;
	end process;

	state_process: process(state)
	begin
		ledr <= (others => '0');
		case state is
			when WAITING =>
				seven_seg <= to_seg(2210);
			when RUNNING =>
				seven_seg <= (
					digit_at(timer, 1),
					digit_at(timer, 0),
					-1, -1,
					digit_at(score, 1),
					digit_at(score, 0)
				);
			when STOPPED =>
				ledr <= (others => '1');
			when others =>
				seven_seg <= to_seg(0);
		end case;
	end process;

	color_process: process(ground_color, obstacles_color, bullet_color, player_color)
		variable color: T_COLOR;
	begin
		color := ground_color;
		for i in 0 to OBSTACLES - 1 loop
			color := color xor obstacles_color(i);
		end loop;
		color := color xor bullet_color;
		color := color xor player_color;
		color_table <= color;
	end process;

end architecture;
