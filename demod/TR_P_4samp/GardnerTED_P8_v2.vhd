--*********************************************************************************
-- Author : Zaichu Yang
-- Project: 600Mbps Parallel Digital Demodulator
-- Date   : 2008.6.5
--
-- Purpose: 
--        Gardner TED.
--
-- Revision History:
--      2008.6.5        first rev.
--      2008.6.20       second rev.
--              Added  decimate function to reduce the delay .
--              delay = 3 clock.
--      2010.6.14       v2版本，较之前版本改动较大
--      2011.9.29       修改sInPhase_Reg4赋值部分
--*********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GardnerTED_P8_v2 is 
        generic(
                kInSize    : positive := 8;
                kOutSize   : positive := 16);
        port(
                aReset     : in std_logic;
                Clk_in     : in std_logic;
                sEnable    : in std_logic;
                
                -- input signal
                sInPhase0    : in signed(kInSize-1 downto 0);     --phase 0 of the input signal
                sInPhase1    : in signed(kInSize-1 downto 0);     --phase 1 of the input signal
                sInPhase2    : in signed(kInSize-1 downto 0);     --phase 2 of the input signal
                sInPhase3    : in signed(kInSize-1 downto 0);     --phase 3 of the input signal
                sInPhase4    : in signed(kInSize-1 downto 0);     --phase 4 of the input signal
                sInPhase5    : in signed(kInSize-1 downto 0);     --phase 5 of the input signal
                sInPhase6    : in signed(kInSize-1 downto 0);     --phase 6 of the input signal
                sInPhase7    : in signed(kInSize-1 downto 0);     --phase 7 of the input signal
                
                sQuadPhase0  : in signed(kInSize-1 downto 0);     --phase 0 of the input signal
                sQuadPhase1  : in signed(kInSize-1 downto 0);     --phase 1 of the input signal
                sQuadPhase2  : in signed(kInSize-1 downto 0);     --phase 2 of the input signal
                sQuadPhase3  : in signed(kInSize-1 downto 0);     --phase 3 of the input signal
                sQuadPhase4  : in signed(kInSize-1 downto 0);     --phase 4 of the input signal
                sQuadPhase5  : in signed(kInSize-1 downto 0);     --phase 5 of the input signal
                sQuadPhase6  : in signed(kInSize-1 downto 0);     --phase 6 of the input signal
                sQuadPhase7  : in signed(kInSize-1 downto 0);     --phase 7 of the input signal
                
                InterpType_ori : in unsigned ( 1 downto 0);
                InterpType0   : in unsigned ( 1 downto 0);
                InterpType1   : in unsigned ( 1 downto 0);
                InterpType2   : in unsigned ( 1 downto 0);
                InterpType3   : in unsigned ( 1 downto 0);
                InterpType4   : in unsigned ( 1 downto 0);
                InterpType5   : in unsigned ( 1 downto 0);                
                InterpType6   : in unsigned ( 1 downto 0);
                InterpType7   : in unsigned ( 1 downto 0);
                flag          : in unsigned( 1 downto 0 );
                
                                
                -- output signal
                sTimingError0 : out signed(kOutSize-1 downto 0);   -- phase 0 of the output signal
                sTimingError1 : out signed(kOutSize-1 downto 0)   -- phase 1 of the output signal
   
                --sEnableOut    : out boolean
                );
   
end GardnerTED_P8_v2;

architecture rtl of GardnerTED_P8_v2 is

        signal d_sInPhase0    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase1    :  signed(kInSize-1 downto 0);    
        signal d_sInPhase2    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase3    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase4    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase5    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase6    :  signed(kInSize-1 downto 0);     
        signal d_sInPhase7    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase0    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase1    :  signed(kInSize-1 downto 0);    
        signal d_sQuadPhase2    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase3    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase4    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase5    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase6    :  signed(kInSize-1 downto 0);     
        signal d_sQuadPhase7    :  signed(kInSize-1 downto 0);   
        signal d_InterpType_ori : unsigned ( 1 downto 0);
        signal d_InterpType0   : unsigned ( 1 downto 0);
        signal d_InterpType1   : unsigned ( 1 downto 0);
        signal d_InterpType2   : unsigned ( 1 downto 0);
        signal d_InterpType3   : unsigned ( 1 downto 0);
        signal d_InterpType4   : unsigned ( 1 downto 0);
        signal d_InterpType5   : unsigned ( 1 downto 0);                
        signal d_InterpType6   : unsigned ( 1 downto 0);
        signal d_InterpType7   : unsigned ( 1 downto 0);  
        
        type SignedArrayIn is array (natural range <>) of signed(kInSize-1 downto 0);
        signal sInPhase_Reg4     : signed(kInSize-1 downto 0);
        signal sQuadPhase_Reg4   : signed(kInSize-1 downto 0);
        
--        type EnableArray is array (natural range <>) of boolean;
--        signal sEnable_Reg      : EnableArray (3 downto 0);
        
        type SignedArrayInter is array (natural range <>) of signed(kInSize downto 0);
        signal sInPhase_Inter   : SignedArrayInter (3 downto 0);
        signal sQuadPhase_Inter : SignedArrayInter (3 downto 0);
        
        signal sInPhase_Mult0   : signed(2*kInSize+1 downto 0); 
        signal sInPhase_Mult1   : signed(2*kInSize+1 downto 0); 
        signal sQuadPhase_Mult0 : signed(2*kInSize+1 downto 0); 
        signal sQuadPhase_Mult1 : signed(2*kInSize+1 downto 0); 
        
        signal sInPhase_Reg0          : signed(kInSize-1 downto 0);
        signal sInPhase_Reg1          : signed(kInSize-1 downto 0);
        signal sInPhase_Reg2          : signed(kInSize-1 downto 0);
        signal sInPhase_Reg3          : signed(kInSize-1 downto 0);
        
        signal sQuadPhase_Reg0        : signed(kInSize-1 downto 0);
        signal sQuadPhase_Reg1        : signed(kInSize-1 downto 0);
        signal sQuadPhase_Reg2        : signed(kInSize-1 downto 0);
        signal sQuadPhase_Reg3        : signed(kInSize-1 downto 0);
        
        signal flag_d          :  unsigned( 1 downto 0 );
        
begin
        
        process(aReset, Clk_in)
           	variable sTimingError0_Inter    : signed(2*kInSize+1 downto 0);
        		variable sTimingError1_Inter    : signed(2*kInSize+1 downto 0);     
        begin
                if aReset='1' then
                      d_sInPhase0    <= ( others=>'0' );     
			                d_sInPhase1    <= ( others=>'0' );    
			                d_sInPhase2    <= ( others=>'0' );     
			                d_sInPhase3    <= ( others=>'0' );     
			                d_sInPhase4    <= ( others=>'0' );     
			                d_sInPhase5    <= ( others=>'0' );     
			                d_sInPhase6    <= ( others=>'0' );     
			                d_sInPhase7    <= ( others=>'0' );     
			                d_sQuadPhase0    <= ( others=>'0' );     
			                d_sQuadPhase1    <= ( others=>'0' );    
			                d_sQuadPhase2    <= ( others=>'0' );     
			                d_sQuadPhase3    <= ( others=>'0' );     
			                d_sQuadPhase4    <= ( others=>'0' );     
			                d_sQuadPhase5    <= ( others=>'0' );     
			                d_sQuadPhase6    <= ( others=>'0' );     
			                d_sQuadPhase7    <= ( others=>'0' );   
			                d_InterpType_ori 	 <= ( others=>'0' );
			                d_InterpType0   <= ( others=>'0' );
			                d_InterpType1   <= ( others=>'0' );
			                d_InterpType2   <= ( others=>'0' );
			                d_InterpType3   <= ( others=>'0' );
			                d_InterpType4   <= ( others=>'0' );
			                d_InterpType5   <= ( others=>'0' );                
			                d_InterpType6   <= ( others=>'0' );
			                d_InterpType7   <= ( others=>'0' );
			                flag_d <= "00";
			                
			                for i in 0 to 3 loop
                                sInPhase_Inter(i)   <= (others => '0');
                                sQuadPhase_Inter(i) <= (others => '0');
                        end loop;
                        
                        sInPhase_Reg4     <= (others => '0');
                        sQuadPhase_Reg4   <= (others => '0');
                        sInPhase_Mult0    <= (others => '0');
                        sQuadPhase_Mult0  <= (others => '0');
                        sInPhase_Mult1    <= (others => '0');
                        sQuadPhase_Mult1  <= (others => '0');
                        
                        sInPhase_Reg0   <= (others => '0');
                        sInPhase_Reg1   <= (others => '0');
                        sInPhase_Reg2   <= (others => '0');
                        sInPhase_Reg3   <= (others => '0');
                        sQuadPhase_Reg0 <= (others => '0');
                        sQuadPhase_Reg1 <= (others => '0');
                        sQuadPhase_Reg2 <= (others => '0');
                        sQuadPhase_Reg3 <= (others => '0');

                        sTimingError1           <= (others => '0');
                        sTimingError0           <= (others => '0');
                        sTimingError0_Inter     := (others => '0');
                        sTimingError1_Inter     := (others => '0');
                        
                elsif rising_edge(Clk_in) then
                     	if sEnable='1' then
                          
                          ------------------------
                         	-- the first pipeline     
                          ------------------------
                      		d_sInPhase0    <= sInPhase0;     
					                d_sInPhase1    <= sInPhase1;    
					                d_sInPhase2    <= sInPhase2;     
					                d_sInPhase3    <= sInPhase3;     
					                d_sInPhase4    <= sInPhase4;     
					                d_sInPhase5    <= sInPhase5;     
					                d_sInPhase6    <= sInPhase6;     
					                d_sInPhase7    <= sInPhase7;     
					                d_sQuadPhase0    <= sQuadPhase0;     
					                d_sQuadPhase1    <= sQuadPhase1;    
					                d_sQuadPhase2    <= sQuadPhase2;     
					                d_sQuadPhase3    <= sQuadPhase3;     
					                d_sQuadPhase4    <= sQuadPhase4;     
					                d_sQuadPhase5    <= sQuadPhase5;     
					                d_sQuadPhase6    <= sQuadPhase6;     
					                d_sQuadPhase7    <= sQuadPhase7;   
					                d_InterpType_ori 	 <= InterpType_ori;
					                d_InterpType0   <= InterpType0;
					                d_InterpType1   <= InterpType1;
					                d_InterpType2   <= InterpType2;
					                d_InterpType3   <= InterpType3;
					                d_InterpType4   <= InterpType4;
					                d_InterpType5   <= InterpType5;                
					                d_InterpType6   <= InterpType6;
					                d_InterpType7   <= InterpType7;    
					                
					                flag_d <= flag;   
                         	------------------------
                         	-- the second pipeline     
                          ------------------------
                          
                          -- sInPhase_Reg4为上一周期的最后一个最佳点，
                          -- sInPhase_Reg0,sInPhase_Reg1,sInPhase_Reg2,sInPhase_Reg3为本周期的过零点、最佳点、过零点、最佳点
                          
                         case flag_d is
                         	
                         	when "10" =>
                         		
                         		case d_InterpType_ori is
                         			when "10" =>
	                          		if  d_InterpType1 = "11" then
		                         					sInPhase_Reg4 <= d_sInPhase1;
		                         					sQuadPhase_Reg4 <= d_sQuadPhase1;
		                         		else
		                         					sInPhase_Reg4 <= d_sInPhase0;
		                         					sQuadPhase_Reg4 <= d_sQuadPhase0;
		                         	  end if;
		                         	when "01" =>
		                         		if  d_InterpType2 = "11" then
		                         					sInPhase_Reg4 <= d_sInPhase2;
		                         					sQuadPhase_Reg4 <= d_sQuadPhase2;
		                         		else
		                         					sInPhase_Reg4 <= d_sInPhase1;
		                         					sQuadPhase_Reg4 <= d_sQuadPhase1;
		                         	  end if;
		                         	when others =>
		                         		sInPhase_Reg4           <= sInPhase_Reg3;
                          			sQuadPhase_Reg4         <= sQuadPhase_Reg3;
                          	end case;
                          		
		                      when others =>  	 
                          		sInPhase_Reg4           <= sInPhase_Reg3;
                          		sQuadPhase_Reg4         <= sQuadPhase_Reg3;
                          end case;
                          
                          case flag_d is
                         			------------
                         			--   00
                         			------------
                         			when "00" =>
                         			
                         				case d_InterpType_ori is
                         					when "00" =>
                         						sInPhase_Reg0 <= d_sInPhase1;
                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
			                         			sInPhase_Reg1 <= d_sInPhase3;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
			                         			sInPhase_Reg2 <= d_sInPhase5;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
			                         			sInPhase_Reg3 <= d_sInPhase7;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
			                         		when "01" =>
			                         			sInPhase_Reg0 <= d_sInPhase0;
                         						sQuadPhase_Reg0 <= d_sQuadPhase0;
			                         			sInPhase_Reg1 <= d_sInPhase2;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase2;
			                         			sInPhase_Reg2 <= d_sInPhase4;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase4;
			                         			sInPhase_Reg3 <= d_sInPhase6;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase6;
			                         		when "10" =>                 --!! Change 
			                         			sInPhase_Reg0 <= d_sInPhase3;
                         						sQuadPhase_Reg0 <= d_sQuadPhase3;
			                         			sInPhase_Reg1 <= d_sInPhase5;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase5;
			                         			sInPhase_Reg2 <= d_sInPhase7;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase7;
			                         			if InterpType1 = "11" then                
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
			                         			elsif InterpType2 = "11" then
			                         				sInPhase_Reg3 <= sInPhase2;
				                         			sQuadPhase_Reg3 <= sQuadPhase2;
				                         		else
				                         			sInPhase_Reg3 <= sInPhase0;
				                         			sQuadPhase_Reg3 <= sQuadPhase0;
				                         		end if;
				                         	when "11" =>                  --!! Change                             
				                         		sInPhase_Reg0 <= d_sInPhase2;
                         						sQuadPhase_Reg0 <= d_sQuadPhase2;
			                         			sInPhase_Reg1 <= d_sInPhase4;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase4;
			                         			sInPhase_Reg2 <= d_sInPhase6;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase6;
			                         			if InterpType0 = "11" then
				                         			sInPhase_Reg3 <= sInPhase0;
				                         			sQuadPhase_Reg3 <= sQuadPhase0;			                         
				                         		else
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
				                         		end if;
				                         	when others =>
				                         		sInPhase_Reg0 <= d_sInPhase1;
                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
			                         			sInPhase_Reg1 <= d_sInPhase3;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
			                         			sInPhase_Reg2 <= d_sInPhase5;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
			                         			sInPhase_Reg3 <= d_sInPhase7;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
			                         	end case;
			                        ------------
                         			--   01
                         			------------
                         			when "01" =>
                         			
                         				case d_InterpType_ori is
                         				
                         					when "00" =>
                         						if d_InterpType1 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase1;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase2;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase2;
	                         					end if;
	                         					if d_InterpType3 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase3;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase4;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase4;
				                         		end if;
				                         		if d_InterpType5 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase5;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase6;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase6;
				                         		end if;
				                         		
			                         			sInPhase_Reg3 <= sInPhase0;
				                         		sQuadPhase_Reg3 <= sQuadPhase0;
				                         		
				                         	when "01" =>
                         						if d_InterpType0 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase0;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase0;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase1;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
	                         					end if;
	                         					if d_InterpType2 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase2;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase2;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase3;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
				                         		end if;
				                         		if d_InterpType4 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase4;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase4;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase5;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
				                         		end if;
				                         		if d_InterpType6 = "11" then
				                         			sInPhase_Reg3 <= d_sInPhase6;
				                         			sQuadPhase_Reg3 <= d_sQuadPhase6;
				                         		else
				                         			sInPhase_Reg3 <= d_sInPhase7;
				                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
				                         		end if;
				                         		
			                         		when "10" =>
                         						if d_InterpType3 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase3;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase3;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase4;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase4;
	                         					end if;
	                         					if d_InterpType5 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase5;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase5;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase6;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase6;
				                         		end if;
				                         		
				                         			sInPhase_Reg2 <= sInPhase0;
				                         			sQuadPhase_Reg2 <= sQuadPhase0;
--				                         			sInPhase_Reg2 <= (others=>'0');
--				                         			sQuadPhase_Reg2 <= (others=>'0');
				                         		
				                         		if InterpType2 = "11" then
				                         			sInPhase_Reg3 <= sInPhase2;
				                         			sQuadPhase_Reg3 <= sQuadPhase2;
				                         		else
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
				                         		end if;
				                         		
				                         	when "11" =>
                         						if d_InterpType2 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase2;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase2;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase3;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase3;
	                         					end if;
	                         					if d_InterpType4 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase4;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase4;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase5;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase5;
				                         		end if;
				                         		if d_InterpType6 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase6;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase6;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase7;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase7;
				                         		end if;
				                         		if InterpType1 = "11" then
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
				                         		else
				                         			sInPhase_Reg3 <= sInPhase0;
				                         			sQuadPhase_Reg3 <= sQuadPhase0;
				                         		end if;
				                         		
				                         	when others =>
				                         		sInPhase_Reg0 <= d_sInPhase1;
                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
			                         			sInPhase_Reg1 <= d_sInPhase3;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
			                         			sInPhase_Reg2 <= d_sInPhase5;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
			                         			sInPhase_Reg3 <= d_sInPhase7;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
			                         	end case;
			                        ------------
                         			--   10
                         			------------
                         			when "10" =>
                         			
                         				case d_InterpType_ori is
                         				
                         					when "00" =>
                         						if d_InterpType1 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase1;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase0;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase0;
	                         					end if;
	                         					if d_InterpType3 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase3;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase2;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase2;
				                         		end if;
				                         		if d_InterpType5 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase5;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase4;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase4;
				                         		end if;
				                         		if d_InterpType7 = "11" then
				                         			sInPhase_Reg3 <= d_sInPhase7;
				                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
				                         		else
				                         			sInPhase_Reg3 <= d_sInPhase6;
				                         			sQuadPhase_Reg3 <= d_sQuadPhase6;
				                         		end if;
			                         	
                         					when "01" =>
                         						if d_InterpType4 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase4;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase4;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase3;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase3;
	                         					end if;
	                         					if d_InterpType6 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase6;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase6;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase5;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase5;
				                         		end if;
				                         		
				                         			sInPhase_Reg2 <= d_sInPhase7;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase7;
				                         	
				                         		if InterpType1 = "11" then
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
				                         		else
				                         			sInPhase_Reg3 <= sInPhase2;
				                         			sQuadPhase_Reg3 <= sQuadPhase2;
				                         		end if;
			                         			
                         					when "10" =>
                         						if d_InterpType3 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase3;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase3;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase2;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase2;
	                         					end if;
	                         					if d_InterpType5 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase5;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase5;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase4;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase4;
				                         		end if;
				                         		if d_InterpType7 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase7;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase7;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase6;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase6;
				                         		end if;
				                         		if InterpType0 = "11" then
				                         			sInPhase_Reg3 <= sInPhase0;
				                         			sQuadPhase_Reg3 <= sQuadPhase0;
				                         		else
				                         			sInPhase_Reg3 <= sInPhase1;
				                         			sQuadPhase_Reg3 <= sQuadPhase1;
				                         		end if;
                          
                         					when "11" =>
                         						if d_InterpType2 = "01" then
	                         						sInPhase_Reg0 <= d_sInPhase2;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase2;
	                         					else
	                         						sInPhase_Reg0 <= d_sInPhase1;
	                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
	                         					end if;
	                         					if d_InterpType4 = "11" then
				                         			sInPhase_Reg1 <= d_sInPhase4;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase4;
				                         		else
				                         			sInPhase_Reg1 <= d_sInPhase3;
				                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
				                         		end if;
				                         		if d_InterpType6 = "01" then
				                         			sInPhase_Reg2 <= d_sInPhase6;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase6;
				                         		else
				                         			sInPhase_Reg2 <= d_sInPhase5;
				                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
				                         		end if;
				                         		
				                         			sInPhase_Reg3 <= d_sInPhase7;
				                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
				                         		
				                         	when others =>
				                         		sInPhase_Reg0 <= d_sInPhase1;
                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
			                         			sInPhase_Reg1 <= d_sInPhase3;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
			                         			sInPhase_Reg2 <= d_sInPhase5;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
			                         			sInPhase_Reg3 <= d_sInPhase7;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
			                         	end case;
			                         	
			                         	when others =>
				                         		sInPhase_Reg0 <= d_sInPhase1;
                         						sQuadPhase_Reg0 <= d_sQuadPhase1;
			                         			sInPhase_Reg1 <= d_sInPhase3;
			                         			sQuadPhase_Reg1 <= d_sQuadPhase3;
			                         			sInPhase_Reg2 <= d_sInPhase5;
			                         			sQuadPhase_Reg2 <= d_sQuadPhase5;
			                         			sInPhase_Reg3 <= d_sInPhase7;
			                         			sQuadPhase_Reg3 <= d_sQuadPhase7;
                          end case;
                          
                         	------------------------
                         	-- the third pipeline     
                          ------------------------
                          -- in phase ted
                          sInPhase_Inter(0)       <= (sInPhase_Reg1(kInSize-1) & sInPhase_Reg1) - (sInPhase_Reg4(kInSize-1) & sInPhase_Reg4);
                          sInPhase_Inter(1)       <= sInPhase_Reg0(kInSize-1) & sInPhase_Reg0;

                          sInPhase_Inter(2)       <= (sInPhase_Reg3(kInSize-1) & sInPhase_Reg3) - (sInPhase_Reg1(kInSize-1) & sInPhase_Reg1);
                          sInPhase_Inter(3)       <= sInPhase_Reg2(kInSize-1) & sInPhase_Reg2;
                          
                          -- Quad Phase ted
                          sQuadPhase_Inter(0)     <= (sQuadPhase_Reg1(kInSize-1) & sQuadPhase_Reg1) - (sQuadPhase_Reg4(kInSize-1) & sQuadPhase_Reg4);
                          sQuadPhase_Inter(1)     <= sQuadPhase_Reg0(kInSize-1) & sQuadPhase_Reg0;

                          sQuadPhase_Inter(2)     <= (sQuadPhase_Reg3(kInSize-1) & sQuadPhase_Reg3) - (sQuadPhase_Reg1(kInSize-1) & sQuadPhase_Reg1);
                          sQuadPhase_Inter(3)     <= sQuadPhase_Reg2(kInSize-1) & sQuadPhase_Reg2;
                          
                         	------------------------
                         	-- the 4th pipeline     
                          ------------------------                          
                          sInPhase_Mult0          <= sInPhase_Inter(0)*sInPhase_Inter(1);
                          sInPhase_Mult1          <= sInPhase_Inter(2)*sInPhase_Inter(3);
                          
                          sQuadPhase_Mult0        <= sQuadPhase_Inter(0)*sQuadPhase_Inter(1);
                          sQuadPhase_Mult1        <= sQuadPhase_Inter(2)*sQuadPhase_Inter(3);

                         	------------------------
                         	-- the 5th pipeline     
                          ------------------------                          
--                          sTimingError0_Inter     := sInPhase_Mult0+sInPhase_Mult1;
--                          sTimingError1_Inter     := sQuadPhase_Mult0+sQuadPhase_Mult1;
                          
                                sTimingError0_Inter     := -sInPhase_Mult0-sInPhase_Mult1;
                                sTimingError1_Inter     := -sQuadPhase_Mult0-sQuadPhase_Mult1;
                          
                          --sEnableOut              <= sEnable_Reg(2);
                          sTimingError0           <= sTimingError0_Inter(2*kInSize+1)& sTimingError0_Inter(2*kInSize-2 downto 2*kInSize-kOutSize);
                          sTimingError1           <= sTimingError1_Inter(2*kInSize+1)& sTimingError1_Inter(2*kInSize-2 downto 2*kInSize-kOutSize);
 
                        else
                               null;
                        end if;
                end if;
        end process;
        
end rtl;