library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utility is

	constant OBSTACLES				: integer := 4;
	constant RAND_BITS 				: integer := 10;
	constant RANDS						: integer := 2 * OBSTACLES;
	constant GAME_WIDTH				: integer := 640;
	constant GAME_HEIGHT				: integer := 480;
	constant PLAYER_WIDTH			: integer := 30;
	constant PLAYER_HEIGHT			: integer := 30;
	constant BULLET_SIZE				: integer := 3;
	constant OBSTACLE_HEIGHT		: integer := 20;
	constant OBSTACLES_DISTANCE	: integer := GAME_HEIGHT / OBSTACLES;
	constant HALF_WATER_MIN			: integer := 1 * GAME_WIDTH / 8;
	constant HALF_WATER_MAX			: integer := 3 * GAME_WIDTH / 8;

	type T_STATE is (WAITING, RUNNING, STOPPED);

	type T_SEG is array (5 downto 0) of integer;

	type T_RAND is array (RANDS - 1 downto 0) of std_logic_vector(RAND_BITS - 1 downto 0);

	subtype T_COLOR is std_logic_vector(11 downto 0);

	constant NO_COLOR: T_COLOR := (others => '0');

	type T_RECT is record
		x: integer;
		y: integer;
		w: integer;
		h: integer;
	end record;

	function int_seg(n: integer) return std_logic_vector;

	function digit_at(n, i: integer) return integer;

	function to_seg(n: integer) return T_SEG;

	function in_box(x, y: integer; box: T_RECT) return boolean;

	function box_collision(a, b: T_RECT) return boolean;

	function get_rand(random: std_logic_vector(RAND_BITS - 1 downto 0); lower, upper: integer) return integer;

end package;

package body utility is

	function int_seg(n: integer) return std_logic_vector is
		variable ans: std_logic_vector(6 downto 0);
	begin
		case n is
			when 0 => ans := "1000000";
			when 1 => ans := "1111001";
			when 2 => ans := "0100100";
			when 3 => ans := "0110000";
			when 4 => ans := "0011001";
			when 5 => ans := "0010010";
			when 6 => ans := "0000010";
			when 7 => ans := "1111000";
			when 8 => ans := "0000000";
			when 9 => ans := "0010000";
			when 10 => ans := "0001000";
			when 11 => ans := "0000011";
			when 12 => ans := "1000110";
			when 13 => ans := "0100001";
			when 14 => ans := "0000110";
			when 15 => ans := "0001110";
			when others => ans := "1111111";
		end case;
		return ans;
	end function;

	function digit_at(n, i: integer) return integer is
	begin
		return (n / 10 ** i) mod 10;
	end function;

	function to_seg(n: integer) return T_SEG is
	begin
		return (
			digit_at(n, 5),
			digit_at(n, 4),
			digit_at(n, 3),
			digit_at(n, 2),
			digit_at(n, 1),
			digit_at(n, 0)
		);
	end function;

	function in_box(x, y: integer; box: T_RECT) return boolean is
	begin	
		return x >= (box.x - box.w / 2) and x <= (box.x + box.w / 2)
				and y >= (box.y - box.h / 2) and y <= (box.y + box.h / 2);
	end function;

	function box_collision(a, b: T_RECT) return boolean is
	begin
		return abs(a.x - b.x) <= (a.w + b.w) / 2 and abs(a.y - b.y) <= (a.h + b.h) / 2;
	end function;

	function get_rand(random: std_logic_vector(RAND_BITS - 1 downto 0); lower, upper: integer) return integer is
		variable max_rand		: unsigned(RAND_BITS - 1 downto 0) := (others => '1');
		variable u_lower		: unsigned(RAND_BITS - 1 downto 0);
		variable u_upper		: unsigned(RAND_BITS - 1 downto 0);
		variable result		: unsigned(2 * RAND_BITS - 1 downto 0);
	begin
		u_lower := to_unsigned(lower, RAND_BITS);
		u_upper := to_unsigned(upper, RAND_BITS);
		result := unsigned(random) * (u_upper - u_lower) / max_rand + u_lower;
		return to_integer(result);
	end function;

end package body;
