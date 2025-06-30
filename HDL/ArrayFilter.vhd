library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ArrayFilter_pkg.all;

entity ArrayFilter is
		generic(
		DATA_WIDTH		: integer := 8
	);
	port (
		clk       : in std_logic;
		rst		  : in std_logic;
		data_av	  : in std_logic;
		data	  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		data_in   : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		done	  : out std_logic;
		addr   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		sel		 : out std_logic;
		ld		 : out std_logic
	);

	end ArrayFilter;

	architecture structural of ArrayFilter is
		signal cmd: Command;
		signal sts: Status;
	begin
		
	    CONTROL_PATH: entity work.ControlPath
	        port map (
	            clk     => clk,
	            rst     => rst,
	            data_av => data_av,    
	            done    => done,    
	            sel     => sel,
	            ld      => ld,
	            cmd     => cmd,
	            sts     => sts
	    );
	        
	    DATA_PATH: entity work.DataPath(behavioral)
	        generic map (
	            DATA_WIDTH  => DATA_WIDTH
	        )
	        port map (
	            clk         => clk,
	            rst         => rst,
	            cmd         => cmd,
	            sts         => sts,
	            data        => data,
	            data_in     => data_in,
	            addr    	=> addr,
	            data_out    => data_out
	        );
	        
	end structural;
	
	architecture behavioral of ArrayFilter is
			signal regI, regJ, regSize       : UNSIGNED(DATA_WIDTH - 1 downto 0);
			signal regAux					 : SIGNED(DATA_WIDTH - 1 downto 0);
			type State is (S0, S1, S2, S3, S4, S5, S6, S7);
			signal currentState: State;
	begin		  
			process(clk, rst)
			begin 
					if rst = '1' then
						currentState <= S0;
				elsif rising_edge(clk) then
						case currentState is
							
							when S0 =>
								regI <= unsigned(data);
								if data_av = '1' then
										currentState <= S1;
								else
										currentState <= S0;
								end if;
								
							when S1 =>
								regSize <= unsigned(regI) + unsigned(data);
								if data_av = '1' then
										currentState <= S2;
								else
										currentState <= S1;
								end if;
							when S2 =>
								regJ <= unsigned(data);
								if data_av = '1' then 
										currentState <= S3;
								else
										currentState <= S2;
								end if;
								
							when S3 =>
								regAux <= signed(data_in);
								if regI < regSize then
									currentState <= S4;
								else 
									currentState <= S7;
								end if;
							
							when S4 =>	
								regI <= regI + 1;
								if regAux > 0 then
									currentState <= S5;
								else
									currentState <= S3;
								end if;
								
							when S5 =>
								currentState <= S6;
							
							when S6 =>
								regJ <= regJ + 1;
								currentState <= S3;
							
							when others => --s14
									currentState <= S0;
						end case;
				end if;
			end process;
			
			sel <= '1' when currentState = S3 or
							currentState = S5 else '0';
			
			ld <= '1' when currentState = S5 else '0';
			
			done <= '1' when currentState = S7 else '0';
				
			process(currentState, regI, regJ)
				begin
				case currentState is
					when S3 =>
						addr <= std_logic_vector(regI);
					
					when S5 =>
						addr <= std_logic_vector(regJ);
					
					when others =>
						addr <= (others => '0');
				end case;	
				end process;
				
			data_out <= std_logic_vector(regAux) when currentState = S5	else (others => '0');
	end behavioral;
	
	