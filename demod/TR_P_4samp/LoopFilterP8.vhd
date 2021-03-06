--*********************************************************************************
-- Author : Zaichu Yang
-- Project: 600Mbps Parallel Digital Demodulator
-- Date   : 2008.6.12
--
-- Purpose: 
--        Loop filter in the time recovery.
--
-- Revision History:
--      2008.6.12        first rev.
--
-- Delay Period is 4
--*********************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LoopFilterP8 is 
  generic(
    kInSize   : positive := 16;
    kOutSize  : positive := 16;
    kKpSize   : positive := 3;
    kKiSize   : positive := 3);
port(
    aReset       : in std_logic;
    Clk_in       : in std_logic;
    sEnable      : in std_logic;
    cKp          : in unsigned(kKpSize-1 downto 0);
    cKi          : in unsigned(kKiSize-1 downto 0);
    cTimingErrorI: in signed(kInSize-1 downto 0);
    cTimingErrorQ: in signed(kInSize-1 downto 0);
    cLoopFilter  : out signed(kOutSize-1 downto 0));
end LoopFilterP8;

architecture rtl of LoopFilterP8 is

  constant kIntegSize : positive := 32;
  signal sPropTE : signed(kIntegSize-1 downto 0);
  signal sPropTE_Dly : signed(kIntegSize-1 downto 0);
  signal sIntegTE : signed(kIntegSize-1 downto 0);
  signal sAccumulator : signed(kIntegSize-1 downto 0);
  --signal sSum : signed(kIntegSize-1 downto 0);
--  signal sLoopFilterInt : signed(kOutSize-1 downto 0);
  signal counter : integer range 0 to 10000 :=0;
  signal flag    : std_logic;
  
begin
  
  process(aReset, Clk_in)
    	variable PropTE  : signed(kIntegSize-1 downto 0);
    	variable IntegTE : signed(kIntegSize-1 downto 0);
  		variable sSum 	 : signed(kIntegSize-1 downto 0):=(others => '0');
  begin
        if aReset='1' then
                sPropTE         <= (others => '0');
                sPropTE_Dly     <= (others => '0');
                sIntegTE        <= (others => '0');
                sAccumulator    <= (others => '0');
                PropTE					:= (others => '0');
                IntegTE					:= (others => '0');
                sSum						:= (others => '0');
--                sLoopFilterInt  <= (others => '0');
                cLoopFilter     <= (others => '0');

                
                --counter <= 0;
                --flag <= '0';
        elsif rising_edge(Clk_in) then
                if sEnable='1' then
--                     if counter /=4000 then
--                        counter <= counter+1;
--                        flag<= '0';
--                     else
--                        flag <= '1';
--                     end if;
                        PropTE  := (cTimingErrorI & to_signed(0,kIntegSize-kInSize))+(cTimingErrorQ & to_signed(0,kIntegSize-kInSize));
                        IntegTE := (cTimingErrorI & to_signed(0,kIntegSize-kInSize))+(cTimingErrorQ & to_signed(0,kIntegSize-kInSize));
                     -- proportional gain control
                        case to_integer(cKp) is
                                  when 0 =>
                                        sPropTE <= shift_right(PropTE,1); --相当于平均值乘以2^-2
                                  when 1 =>
                                        sPropTE <= shift_right(PropTE,2); --相当于平均值乘以2^-3
                                  when 2 =>
                                        sPropTE <= shift_right(PropTE,3); --相当于平均值乘以2^-4
                                  when 3 =>
                                        sPropTE <= shift_right(PropTE,4); --相当于平均值乘以2^-5
                                  when 4 =>
                                        sPropTE <= shift_right(PropTE,5); --相当于平均值乘以2^-6
                                  when 5 =>
    --                                  if flag = '0' then
                                        sPropTE <= shift_right(PropTE,6); --相当于平均值乘以2^-7  --6
--                                      else
--                                      	sPropTE <= shift_right(PropTE,7);
--                                      end if;
                                  when 6 =>
                                        sPropTE <= shift_right(PropTE,7); --相当于平均值乘以2^-8
                                  when 7 =>
                                        sPropTE <= shift_right(PropTE,8); --相当于平均值乘以2^-9
                                  when others =>
                                    null; 
                        end case;
        
                        -- integral gain control
                        case to_integer(unsigned(cKi)) is
                                  when 0 =>
                                        sIntegTE <= shift_right(IntegTE, 6); --相当于平均值乘以2^-9
                                  when 1 =>
                                        sIntegTE <= shift_right(IntegTE, 7); --相当于平均值乘以2^-10
                                  when 2 =>
                                        sIntegTE <= shift_right(IntegTE, 8); --相当于平均值乘以2^-11
                                  when 3 =>
                                        sIntegTE <= shift_right(IntegTE, 9); --相当于平均值乘以2^-12
                                  when 4 =>
                                        sIntegTE <= shift_right(IntegTE, 10); --相当于平均值乘以2^-13
                                  when 5 =>
                                        sIntegTE <= shift_right(IntegTE, 11); --相当于平均值乘以2^-14
                                  when 6 =>
      --                               if flag = '0' then
                                        sIntegTE <= shift_right(IntegTE, 13); --相当于平均值乘以2^-15  --13
--                                     else
--                                     	  sIntegTE <= shift_right(IntegTE, 14);
--                                     end if;
                                  when 7 =>
                                        sIntegTE <= shift_right(IntegTE, 13); --相当于平均值乘以2^-16
                                  when others =>                     
                                    null; 
                        end case;
        
                        -- Uncomment the following lines to limit the accumulator's value
--                        if (sAccumulator >= signed'(x"F8000000") and sAccumulator <= signed'(x"08000000")) then
--                          sAccumulator <= sAccumulator + sIntegTE;
--                        else
--                          sAccumulator <= signed'(x"01000000");
--                        end if; 
 
--						if (sAccumulator >= signed'(x"01800000") or sAccumulator <= signed'(x"FE80000")) then  --x"08000000", x"F8000000"
						if (sAccumulator >= to_signed(-41474836, kIntegSize) and sAccumulator <= to_signed(41474836,kIntegSize)) then  --x"08000000", x"F8000000"
--                        if (sAccumulator >= signed'(x"E8000000") and sAccumulator <= signed'(x"08000000")) then
							sAccumulator <= sAccumulator + sIntegTE;
						else
							sAccumulator <= to_signed(0,kIntegSize);           
						end if; 
--
                        sPropTE_Dly  	<= sPropTE;
                        sSum 		:= sAccumulator + sPropTE_Dly;
                        --if sSum< to_signed(0,kIntegSize) then
                        --	cLoopFilter	<= (others => '0');
                        --else
                        ----ROUND
							if sSum(kIntegSize-kOutSize-1)='0' then
								cLoopFilter    	<= sSum(kIntegSize-1 downto kIntegSize-kOutSize);
							else
								cLoopFilter    	<= sSum(kIntegSize-1 downto kIntegSize-kOutSize)+1;
							end if;
                        --end if;
                        
                   
                else
                        null;
                end if; 
        end if;                               
  end process;

end rtl;