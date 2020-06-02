-- This file is responsible for displaying all of the visual aspects of the game on the VGA screen.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY display IS
	PORT
		(
		--Global Signals--
		SIGNAL clk, vert_sync, left_click	: IN std_logic;
		SIGNAL pixel_row, pixel_column		: IN std_logic_vector(9 DOWNTO 0);
		--Bird Signals--
		SIGNAL red, green, blue, bird_dead	: OUT std_logic
		--Pipe Signals--
		);		
END display;

architecture behavior of display is

------ Signals associated with the bird ------
SIGNAL bird_on										: std_logic;
SIGNAL bird_size, bird_y_pos, bird_y_motion		: std_logic_vector(9 DOWNTO 0);
SIGNAL bird_x_pos									: std_logic_vector(10 DOWNTO 0);

------ Signals associated with the pipe ------
SIGNAL pipe_top, pipe_bottom					: std_logic;
SIGNAL pipe_size 									: std_logic_vector(9 DOWNTO 0);  
SIGNAL pipe_top_y_pos, pipe_bottom_y_pos 	: std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_x_pos 								: std_logic_vector(9 DOWNTO 0	) := CONV_STD_LOGIC_VECTOR(640,10);

BEGIN           

------ Initialisation of the bird ------
bird_size <= CONV_STD_LOGIC_VECTOR(8,10);
bird_x_pos <= CONV_STD_LOGIC_VECTOR(320,11);

------ Initialisation of the pipe ------
pipe_size <= CONV_STD_LOGIC_VECTOR(20,10);
pipe_top_y_pos <= CONV_STD_LOGIC_VECTOR(200,10);
pipe_bottom_y_pos <= CONV_STD_LOGIC_VECTOR(350,10);

------ Display the bird on the VGA screen ------
bird_on <= '1' when ( ('0' & bird_x_pos <= '0' & pixel_column + bird_size) and ('0' & pixel_column <= '0' & bird_x_pos + bird_size) 	-- x_pos - bird_size <= pixel_column <= x_pos + bird_size
					and ('0' & bird_y_pos <= pixel_row + bird_size) and ('0' & pixel_row <= bird_y_pos + bird_size) )  else	-- y_pos - bird_size <= pixel_row <= y_pos + bird_size
			  '0';

------ Display the pipe on the VGA screen ------
pipe_top <= '1' when ( (pipe_x_pos <= pixel_column + pipe_size) and (pixel_column <= pipe_x_pos + pipe_size) 	-- x_pos - pipe_size <= pixel_column <= x_pos + pipe_size
					 and (pixel_row <= pipe_top_y_pos + pipe_size) )  else	-- y_pos - pipe_size <= pixel_row <= y_pos + pipe_size
			'0';
pipe_bottom <= '1' when ( (pipe_x_pos <= pixel_column + pipe_size) and (pixel_column <= pipe_x_pos + pipe_size)
					 and (pipe_bottom_y_pos <= pixel_row +pipe_size)) else
			'0';

------ Bird mechanics ------
Move_Bird: process (vert_sync, left_click)  	
begin
	-- Move bird once every vertical sync
	if (rising_edge(vert_sync)) then
		-- Let the bird freefall when there is no left click
		bird_y_motion <= CONV_STD_LOGIC_VECTOR(4,10);
		-- Move the bird up on a left click 
		if (left_click = '1' and (bird_y_pos > bird_size)) then
			bird_y_motion <= - CONV_STD_LOGIC_VECTOR(6,10);
		-- The bird will land at the bottom of the screen if the mouse is not being left clicked
		elsif ('0' & bird_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - bird_size) then
			bird_y_motion <= "0000000000";
		end if;
		-- Compute next bird Y position
		bird_y_pos <= bird_y_pos + bird_y_motion;
	end if;
	-- Flag when the bird lands at the bottom of the screen.
	if (bird_y_pos = CONV_STD_LOGIC_VECTOR(479,10) - bird_size) then
		bird_dead <= '1';
	end if;
end process Move_Bird;

------ Pipe mechanics ------
pipe_move: process(clk)
variable clk_cnt : integer := 1;
variable clk_t : STD_LOGIC := '0';
variable position : integer := 0;
begin
	if (clk'event and clk = '1') then
		clk_cnt := clk_cnt + 1;
		if (clk_cnt = 1000000) then
			clk_cnt := 1;
			clk_t := NOT(clk_t);
			if (position > 660) then
				position := 0;
			else
				position := position + 1;
			end if;
		end if;
	end if;
	pipe_x_pos <= CONV_STD_LOGIC_VECTOR((640 - position),10);
end process pipe_move;

------ Display ------
Red <= bird_on or ((not pipe_top) and (not pipe_bottom));
Green <= bird_on or ((not pipe_top) and (not pipe_bottom));
Blue <= bird_on or ((not pipe_top) and (not pipe_bottom));
END behavior;