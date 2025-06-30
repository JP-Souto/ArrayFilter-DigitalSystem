library IEEE;
use IEEE.std_logic_1164.all;
use work.ArrayFilter_pkg.all;
use IEEE.numeric_std.all;

entity ControlPath_tb is
end ControlPath_tb;

architecture behavioral of ControlPath_tb is
		signal rst     		: std_logic;
		signal clk     		: std_logic := '0';
		signal data_av 		: std_logic;
		signal done			: std_logic;
		signal sel, ld		: std_logic;
		signal sts			: Status;
		signal cmd 			: Command;
begin
	

	
	
		clk <= not clk after 20ns;	
		
		CONTROL_PATH: entity work.ControlPath
				port map (
				rst => rst,
				clk => clk,
				data_av => data_av,
				done => done,
				sel => sel,
				ld => ld,
				sts => sts,
				cmd => cmd
				);
			
process 
	begin
		rst <= '1';
		data_av <= '0';
		sts.comp <= '0';
		wait until clk = '1';
		rst <= '0';
		wait until clk = '1'; --s0
		data_av <= '1';
		wait until clk = '1'; --s1
		wait until clk = '1'; --s2
		wait until clk = '1'; --s3
		sts.comp <= '1';
		wait until clk = '1'; --s4
		wait until clk = '1'; --s5
		wait until clk = '1'; --s6
		sts.comp <= '0';
		wait until clk = '1';--s3
		wait until clk = '1';--s7
		wait until clk = '1';
	end process;	
end behavioral;