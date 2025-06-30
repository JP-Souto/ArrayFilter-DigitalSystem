library IEEE;
use IEEE.std_logic_1164.all;
use work.ArrayFilter_pkg.all;


	entity ControlPath is
			port (
		
				--Input
				clk, rst, data_av    : in std_logic;  
				
				--output
				done    : out std_logic;
				
				-- datapath interface
				sts     : in Status;
				cmd     : out Command;
				
				--memory interface
				sel, ld    : out std_logic
				
				  );
	end ControlPath;
	
	
architecture behavioral of ControlPath is
		type State is ( S0, S1, S2, S3, S4, S5, S6, S7);
		signal currentState, nextState: State;
	
	
begin
	
		-- State memory
		   process(clk, rst)
		   begin
			   		if rst = '1' then
				   	currentState <= S0;
					   
					elsif rising_edge(clk) then
							currentState <= nextState;
							
					end if;
			end process;
			
			-- NextStateLogic
			process(currentState, data_av, sts.comp)
			begin
				case currentState is
					when S0 =>
					if data_av = '1' then
						nextState <= S1;
					else  
						nextState <= S0;
					end if;
					
					when S1 =>
					if data_av = '1' then 
						nextState <= S2;
					else 
						nextState <= S1;
					end if;
					
					when S2 =>
					if data_av = '1' then
						nextState <= S3;
					else
						nextState <= S2;
					end if;	 
					
					when S3 =>
					if sts.comp = '1' then
						nextState <= S4;
					else 
						nextState <= S7; --done
					end if;
					
					when S4 =>
					if sts.comp = '1' then
						nextState <= S5;
					else 
						nextState <= S3;
					end if;
					
					when S5 =>
						nextState <= S6;
					
					when S6 =>
						nextState <= S3;
					
					when others =>
						nextState <= S0;
					
				end case;
			end process;
			
			-- Output logic 
			done <= '1' when currentState = S7 else '0';
				
			-- write			
			cmd.wrI <= '1' when currentState = S0 or
						        currentState = S4 else '0'; 	
			cmd.wrSize <= '1' when currentState = S1 else '0';
			
			cmd.wrJ <= '1' when currentState = S2 or
								currentState = S6 else '0';			
			cmd.wrAux <= '1' when currentState = S3 else '0';
			
			--mux		
			cmd.selMuxReg <= '1' when currentState = S0 or
									  currentState = S1 or 
									  currentState = S2 else '0';
				
			cmd.selMuxAdder0 <= '1' when currentState = S1 or
									     currentState = S4 else '0';
										  
			cmd.selMuxAdder1 <= '1' when currentState = S1 else '0';
			
			cmd.selMuxComp0 <= '1' when currentState = S3 else '0';
			
			cmd.selMuxComp1 <= '1' when currentState = S4 else '0';
			
			cmd.selMuxAddress <= '1' when currentState = S3 else '0';
				
			--memory interface
			
			sel <= '1' when currentState = S3 or
							currentState = S5 else '0';
				
			ld <= '1' when currentState = S5 else '0';
	
end behavioral;