   library IEEE;
   use IEEE.std_logic_1164.all;
   
   package ArrayFilter_pkg is
	   
	   type Command is record
		   
		   -- writes
		   wrSize, wrJ, wrI, wrAux    : std_logic;
		   
		   -- mux selectors
		   selMuxReg, selMuxAdder0, selMuxAdder1    : std_logic;
		   selMuxComp0, selMuxComp1, selMuxAddress: std_logic;
		  		   
	   end record;
	   
	   type Status is record
		   
		   comp : std_logic;
		   
	   end record;
		  
	end ArrayFilter_pkg;