library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ArrayFilter_pkg.all;


entity DataPath is
	generic( 
	DATA_WIDTH  : integer := 8
	);
	port (
		clk      : in std_logic;
		rst      : in std_logic;
		
		data     : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		
		-- Control path interface
		sts      : out Status;
		cmd      : in Command;
		
		-- Memory interface
		addr     : out std_logic_vector (DATA_WIDTH - 1 downto 0);
		data_in  : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		data_out : out std_logic_vector (DATA_WIDTH - 1 downto 0)
		);
end DataPath;

architecture behavioral of DataPath is
	signal j, i, size, aux     : std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal muxReg, muxAdder0, muxAdder1     : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal muxComp0, muxComp1, muxAddress   : std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	signal sum                              : UNSIGNED(DATA_WIDTH - 1 downto 0);

begin 
	
	-- registradores
	  REG_J: entity work.RegisterNbits
		  generic map (
		  	WIDTH => DATA_WIDTH
		  )
		  port map(
		  clk => clk,
		  rst => rst,
		  ce => cmd.wrJ,
		  d => muxReg,
		  q => j
		  );
	  
	  REG_I: entity work.RegisterNbits
		  generic map(
		  	WIDTH => DATA_WIDTH
		  )
		  port map(
		  clk => clk,
		  rst => rst,
		  ce => cmd.wrI,
		  d => muxReg,
		  q => i
		  );   
		  
	   REG_SIZE: entity work.RegisterNbits
		   generic map(
		   	WIDTH => DATA_WIDTH
		   )
		   port map(
		   clk => clk,
		   rst => rst,
		   ce => cmd.wrSize,
		   d => STD_LOGIC_VECTOR(sum),
		   q => size
		   );
		   
		REG_AUX: entity work.RegisterNbits
			generic map(
			WIDTH => DATA_WIDTH
			)
			port map(
			clk => clk, 
			rst => rst,
			ce => cmd.wrAux,
			d => data_in,
			q => aux
			);
			
	  -- muxes
	    muxReg <= data when cmd.selMuxReg = '1' else STD_LOGIC_VECTOR(sum);
			
		muxAdder0 <= i when cmd.selMuxAdder0 = '1' else j;
		muxAdder1 <= muxReg when cmd.selMuxAdder1 = '1' else "00000001";
			
		muxAddress <= i when cmd.selMuxAddress = '1' else j;
		
		muxComp0 <= i when cmd.selMuxComp0 = '1' else "00000000";
		muxComp1 <= aux when cmd.selMuxComp1 = '1' else size;
	
	  -- somador
	  	sum <= unsigned(MuxAdder0) + unsigned(MuxAdder1);
	  
	  -- comparador
		sts.comp <= '1' when signed(MuxComp0) < signed(MuxComp1) else '0';
		addr <= muxAddress;
		
		data_out <= aux;
	
end behavioral;