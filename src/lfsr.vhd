library ieee;
use ieee.std_logic_1164.all;
use work.utility.all;

entity lfsr is
	port(
		clk				: in std_logic;
		reset				: in std_logic;
		pseudo_rand		: out T_RAND
	);
end entity;

architecture lfsr of lfsr is

	signal rand: std_logic_vector(RAND_BITS - 1 downto 0) := (others => '0');

	function generate_rand(seed: std_logic_vector(RAND_BITS - 1 downto 0)) return std_logic_vector is
	begin
--		return seed(RAND_BITS - 2 downto 0) & (seed(7) xnor seed(5) xnor seed(4) xnor seed(3));		-- 8  bits
		return seed(RAND_BITS - 2 downto 0) & (seed(9) xnor seed(6));											-- 10 bits
--		return seed(RAND_BITS - 2 downto 0) & (seed(11) xnor seed(5) xnor seed(3) xnor seed(0));		-- 12 bits
--		return seed(RAND_BITS - 2 downto 0) & (seed(15) xnor seed(14) xnor seed(12) xnor seed(3));	-- 16 bits
--		return seed(RAND_BITS - 2 downto 0) & (seed(31) xnor seed(21) xnor seed(1) xnor seed(0));		-- 32 bits
	end function;

begin

	process(clk, reset)
		variable tmp: std_logic_vector(RAND_BITS - 1 downto 0);
	begin
		if reset = '1' then
			rand <= (others => '0');
		elsif rising_edge(clk) then
			tmp := rand;
			for i in 0 to RANDS - 1 loop
				tmp := generate_rand(tmp);
				pseudo_rand(i) <= tmp;
			end loop;
			rand <= tmp;
		end if;
	end process;

end architecture;
