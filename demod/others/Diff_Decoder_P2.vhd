library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------
entity Diff_Decoder_P2 is 
    port (
      aReset          : in  std_logic; 
      clk             : in  std_logic;
      datain_i        : in  std_logic_vector(1 downto 0);
      datain_q        : in  std_logic_vector(1 downto 0);
      datain_valid    : in  std_logic;
      
      dataout_i       : out  std_logic_vector(1 downto 0);
      dataout_q       : out  std_logic_vector(1 downto 0);
      dataout_valid   : out  std_logic        
     );
end Diff_Decoder_P2;

architecture rt1 of Diff_Decoder_P2 is
	signal constell_rec_0, constell_rec_1 : unsigned( 1 downto 0 );
	signal constell_Decoded_0, constell_Decoded_1 : unsigned( 1 downto 0 );
	signal constell_rec_1_dly : unsigned( 1 downto 0 );
	
begin
	-- mapping
	--  01  |  11        1  |  0
	--  ---------  =>   --------
	--  00  |  10        2  |  3
	process(aReset,clk)
	variable datain_cons_0 : unsigned(1 downto 0);
	begin
		if aReset='1' then
			constell_rec_0 <= (others=>'0');
		elsif rising_edge( clk ) then
		datain_cons_0 := datain_i(0) & datain_q(0);
		if datain_valid = '1' then
			case  datain_cons_0  is
				when "11" =>
					constell_rec_0 <= to_unsigned(0,2);
				when "01" =>
					constell_rec_0 <= to_unsigned(1,2);
				when "00" =>
					constell_rec_0 <= to_unsigned(2,2);
				when "10" =>
					constell_rec_0 <= to_unsigned(3,2);
				when others =>
					null;
			end case;
		else
			null;
		end if;
		end if;
	end process;
	
	process(aReset,clk)
	variable datain_cons_1 : unsigned(1 downto 0);
	begin
		if aReset='1' then
			constell_rec_1 <= (others=>'0');
			constell_rec_1_dly <= (others=>'0');
		elsif rising_edge( clk ) then
		datain_cons_1 := datain_i(1) & datain_q(1);
		if datain_valid = '1' then
			case  datain_cons_1  is
				when "11" =>
					constell_rec_1 <= to_unsigned(0,2);
				when "01" =>
					constell_rec_1 <= to_unsigned(1,2);
				when "00" =>
					constell_rec_1 <= to_unsigned(2,2);
				when "10" =>
					constell_rec_1 <= to_unsigned(3,2);
				when others =>
					null;
			end case;
			constell_rec_1_dly <= constell_rec_1;
		else
			null;
		end if;
		end if;
	end process;
	
	-- Diff_Decode			
	process(aReset,clk)
	begin
		if ( aReset = '1' ) then
			constell_Decoded_0 <= (others=>'0');
			constell_Decoded_1 <= (others=>'0');
			
		elsif rising_edge(clk) then
		if datain_valid = '1' then
			constell_Decoded_0 <= constell_rec_0 - constell_rec_1_dly;
			constell_Decoded_1 <= constell_rec_1 - constell_rec_0;
			
		else
			null;
		end if;
		end if;
	end process;
	
	dataout_i(1) <= constell_Decoded_1(1);
	dataout_i(0) <= constell_Decoded_0(1);
	dataout_q(1) <= constell_Decoded_1(0);
	dataout_q(0) <= constell_Decoded_0(0);
	
--	-- demapping
--	--  1  |  0        01  |  11
--	--  -------   =>   ---------
--	--  2  |  3        00  |  10
--	process(aReset,clk)
--	begin
--		if ( aReset = '1' ) then
--			dataout_i <= (others=>'0');
--			dataout_q <= (others=>'0');
--		elsif rising_edge(clk) then
--		if datain_valid = '1' then
--			case constell_Decoded_0 is
--				when "00" =>
--					dataout_i(0) <= '1';
--					dataout_q(0) <= '1';
--				when "01" =>
--					dataout_i(0) <= '0';
--					dataout_q(0) <= '1';
--				when "10" =>
--					dataout_i(0) <= '0';
--					dataout_q(0) <= '0';
--				when "11" =>
--					dataout_i(0) <= '1';
--					dataout_q(0) <= '0';
--			end case;	
--			
--			case constell_Decoded_1 is
--				when "00" =>
--					dataout_i(1) <= '1';
--					dataout_q(1) <= '1';
--				when "01" =>
--					dataout_i(1) <= '0';
--					dataout_q(1) <= '1';
--				when "10" =>
--					dataout_i(1) <= '0';
--					dataout_q(1) <= '0';
--				when "11" =>
--					dataout_i(1) <= '1';
--					dataout_q(1) <= '0';
--			end case;	
--			
--						
--		else
--			null;
--		end if;
--		end if;
--	end process;
	
	process(aReset,clk)
	begin
		if ( aReset = '1' ) then
			dataout_valid <= '0';
		elsif rising_edge(clk) then	
			dataout_valid <= datain_valid;
		end if;
	end process;
end rt1;
















