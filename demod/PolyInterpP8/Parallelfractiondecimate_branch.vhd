--new-----------------------------------------------------------------------------
--
-- 作者: 杨再初
-- 所属项目: QPSK高速并行解调
-- 时间: 2008.1.11
--
-- 功能：并行单路分数倍抽取(采用改进的Farrow结构和查表法)
--
-- 说明：
--    输入的抽取率为kInWidth位，前kCountWidth位为整数，后面kInWidth-kCountWidth位为小数
--    mu值为无符号数，位宽与抽取率的小数部分宽度一致
-------------------------------------------------------------------------------
--
-- Revision History:
-- 2007.12.28 First revision
-- 2008.6.2   second revision
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity ParallelFractionDecimate_branch is
        generic(
                kInWidth        : positive := 13; -- 抽取率位宽
                kCountWidth     : positive := 4;  -- 计数器的宽度
                kDataWidth      : positive :=8;  -- 输入数据宽度
                kRomOutWidth    : positive :=16); -- ROM 模块输出数据的位宽 
        port   (
                aReset          : in  std_logic;
                Clk_in          : in  std_logic;
                sMuIn           : in  unsigned (kInWidth-kCountWidth-1 downto 0);
                sEnableIn       : in  std_logic;
                sDataIn0        : in  signed (kDataWidth-1 downto 0);
                sDataIn1        : in  signed (kDataWidth-1 downto 0);
                sDataIn2        : in  signed (kDataWidth-1 downto 0);
                sDataIn3        : in  signed (kDataWidth-1 downto 0);
                sDataIn4        : in  signed (kDataWidth-1 downto 0);
                sDataIn5        : in  signed (kDataWidth-1 downto 0);
                sDataOut        : out signed (kDataWidth-1 downto 0);
                sEnableOut      : out std_logic);
end ParallelFractionDecimate_branch;

architecture rtl of ParallelFractionDecimate_branch is

        component Rom_one
        port(
                address_a       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                address_b       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                clock           : IN STD_LOGIC ;
                q_a             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0);
                q_b             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0)
                );
        end component;

        component Rom_two
        port(
                address_a       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                address_b       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                clock           : IN STD_LOGIC ;
                q_a             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0);
                q_b             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0)
                );
        end component;

        component Rom_three
        port(
                address_a       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                address_b       : IN STD_LOGIC_VECTOR (kInWidth-kCountWidth-1 DOWNTO 0);
                clock           : IN STD_LOGIC ;
                q_a             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0);
                q_b             : OUT STD_LOGIC_VECTOR (kRomOutWidth-1 DOWNTO 0)
                );
        end component;

		  constant kRomOutWidth2 : positive := 9;
        constant Temp_constant  : std_logic_vector (kInWidth-kCountWidth-1 downto 0):= std_logic_vector(to_unsigned(2**(kInWidth-kCountWidth)-1,kInWidth - kCountWidth));
        --********************每路采用Farrow结构，各级流水缓存******************************
        type SignedArray_t is array (natural range <>) of signed(kDataWidth+kRomOutWidth2-1 downto 0);
        --保存与输入数据相乘结果
        signal sProd0      : SignedArray_t(6 downto 0);

        signal sProd1      : SignedArray_t(2 downto 0);
        signal sProd2      : signed(kDataWidth+kRomOutWidth2-1 downto 0);
        
        signal sAddress0   : std_logic_vector(kInWidth - kCountWidth-1 downto 0);
        signal sAddress1   : std_logic_vector(kInWidth - kCountWidth-1 downto 0);
       -- signal sAddress2   : std_logic_vector(kInWidth - kCountWidth-1 downto 0);
        
        signal sRomData0   : std_logic_vector(kRomOutWidth-1 downto 0);
        signal sRomData1   : std_logic_vector(kRomOutWidth-1 downto 0);
        signal sRomData2   : std_logic_vector(kRomOutWidth-1 downto 0);
        signal sRomData3   : std_logic_vector(kRomOutWidth-1 downto 0);
        signal sRomData4   : std_logic_vector(kRomOutWidth-1 downto 0);
        signal sRomData5   : std_logic_vector(kRomOutWidth-1 downto 0);
		  
		  signal sRomData0_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
        signal sRomData1_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
        signal sRomData2_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
        signal sRomData3_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
        signal sRomData4_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
        signal sRomData5_2   : std_logic_vector(kRomOutWidth2-1 downto 0);
		  
		  

        signal sDataIn0_Inter1   : signed (kDataWidth-1 downto 0);
        signal sDataIn1_Inter1   : signed (kDataWidth-1 downto 0);
        signal sDataIn2_Inter1   : signed (kDataWidth-1 downto 0);
        signal sDataIn3_Inter1   : signed (kDataWidth-1 downto 0);
        signal sDataIn4_Inter1   : signed (kDataWidth-1 downto 0);
        signal sDataIn5_Inter1   : signed (kDataWidth-1 downto 0);

        signal sDataIn0_Inter2   : signed (kDataWidth-1 downto 0);
        signal sDataIn1_Inter2   : signed (kDataWidth-1 downto 0);
        signal sDataIn2_Inter2   : signed (kDataWidth-1 downto 0);
        signal sDataIn3_Inter2   : signed (kDataWidth-1 downto 0);
        signal sDataIn4_Inter2   : signed (kDataWidth-1 downto 0);
        signal sDataIn5_Inter2   : signed (kDataWidth-1 downto 0);

        signal sDataIn0_Inter3   : signed (kDataWidth-1 downto 0);
        signal sDataIn1_Inter3   : signed (kDataWidth-1 downto 0);
        signal sDataIn2_Inter3   : signed (kDataWidth-1 downto 0);
        signal sDataIn3_Inter3   : signed (kDataWidth-1 downto 0);
        signal sDataIn4_Inter3   : signed (kDataWidth-1 downto 0);
        signal sDataIn5_Inter3   : signed (kDataWidth-1 downto 0);

--        signal sDataIn0_Inter4   : signed (kDataWidth-1 downto 0);
--        signal sDataIn1_Inter4   : signed (kDataWidth-1 downto 0);
--        signal sDataIn2_Inter4   : signed (kDataWidth-1 downto 0);
--        signal sDataIn3_Inter4   : signed (kDataWidth-1 downto 0);
--        signal sDataIn4_Inter4   : signed (kDataWidth-1 downto 0);
--        signal sDataIn5_Inter4   : signed (kDataWidth-1 downto 0);

        type EnableSignedArray is array (natural range <>) of std_logic;
        signal sEnableDelayChain :EnableSignedArray(10 downto 0); --移位保存Enable值
        
        
begin

        search1 : Rom_one
                port map (
                        address_a       => sAddress0,
                        address_b       => sAddress1,
                        clock        	=> Clk_in,
                        q_a             => sRomData0,
                        q_b             => sRomData5
                );
                
        search2 : Rom_two
                port map (
                        address_a       => sAddress0,
                        address_b       => sAddress1,
                        clock        	=> Clk_in,
                        q_a             => sRomData1,
                        q_b             => sRomData4
                );

        search3 : Rom_three
                port map (
                        address_a       => sAddress0,
                        address_b       => sAddress1,
                        clock        	=> Clk_in,
                        q_a             => sRomData2,
                        q_b             => sRomData3
                );
					 
		  sRomData0_2 <= sRomData0( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
		  sRomData1_2 <= sRomData1( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
		  sRomData2_2 <= sRomData2( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
		  sRomData3_2 <= sRomData3( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
		  sRomData4_2 <= sRomData4( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
		  sRomData5_2 <= sRomData5( kRomOutWidth-1 downto kRomOutWidth-kRomOutWidth2);
                     
        process(aReset, Clk_in)
           --variable sProd2      : signed(kDataWidth+kRomOutWidth-1 downto 0);
        begin
                if aReset='1' then
                        for i in 0 to 5 loop
                                sProd0(i) <= (others =>'0');
                        end loop;
                        for i in 0 to 2 loop
                                sProd1(i) <= (others =>'0');
                        end loop;
                        for i in 0 to 10 loop
                                sEnableDelayChain(i)    <= '0';
                        end loop;
                                                                                        
                        sProd2           <= (others => '0');
                        sAddress0        <= (others => '0');
                        sAddress1        <= (others => '0');
                        --sAddress2        <= (others => '0');
                        sDataIn0_Inter1  <= (others => '0');
                        sDataIn1_Inter1  <= (others => '0');
                        sDataIn2_Inter1  <= (others => '0');
                        sDataIn3_Inter1  <= (others => '0');
                        sDataIn4_Inter1  <= (others => '0');
                        sDataIn5_Inter1  <= (others => '0');

                        sDataIn0_Inter2  <= (others => '0');
                        sDataIn1_Inter2  <= (others => '0');
                        sDataIn2_Inter2  <= (others => '0');
                        sDataIn3_Inter2  <= (others => '0');
                        sDataIn4_Inter2  <= (others => '0');
                        sDataIn5_Inter2  <= (others => '0');

                        sDataIn0_Inter3  <= (others => '0');
                        sDataIn1_Inter3  <= (others => '0');
                        sDataIn2_Inter3  <= (others => '0');
                        sDataIn3_Inter3  <= (others => '0');
                        sDataIn4_Inter3  <= (others => '0');
                        sDataIn5_Inter3  <= (others => '0');

--                        sDataIn0_Inter4  <= (others => '0');
--                        sDataIn1_Inter4  <= (others => '0');
--                        sDataIn2_Inter4  <= (others => '0');
--                        sDataIn3_Inter4  <= (others => '0');
--                        sDataIn4_Inter4  <= (others => '0');
--                        sDataIn5_Inter4  <= (others => '0');

                        sDataOut         <= (others => '0');
                        sEnableOut       <= '0';
                elsif rising_edge(Clk_in) then
                        --the first pipeline
                        sAddress0        <= std_logic_vector(sMuIn);
                        sAddress1        <= Temp_constant - std_logic_vector(sMuIn);
                        sDataIn0_inter1  <= sDataIn0;
                        sDataIn1_inter1  <= sDataIn1;
                        sDataIn2_inter1  <= sDataIn2;
                        sDataIn3_inter1  <= sDataIn3;
                        sDataIn4_inter1  <= sDataIn4;
                        sDataIn5_inter1  <= sDataIn5;
                        
                        --the second pipeline
                        sDataIn0_inter2  <= sDataIn0_inter1;
                        sDataIn1_inter2  <= sDataIn1_inter1;
                        sDataIn2_inter2  <= sDataIn2_inter1;
                        sDataIn3_inter2  <= sDataIn3_inter1;
                        sDataIn4_inter2  <= sDataIn4_inter1;
                        sDataIn5_inter2  <= sDataIn5_inter1;

                        --the third pipeline
                        sDataIn0_inter3  <= sDataIn0_inter2;
                        sDataIn1_inter3  <= sDataIn1_inter2;
                        sDataIn2_inter3  <= sDataIn2_inter2;
                        sDataIn3_inter3  <= sDataIn3_inter2;
                        sDataIn4_inter3  <= sDataIn4_inter2;
                        sDataIn5_inter3  <= sDataIn5_inter2;

                        --the fourth pipeline
--                        sDataIn0_inter4  <= sDataIn0_inter3;
--                        sDataIn1_inter4  <= sDataIn1_inter3;
--                        sDataIn2_inter4  <= sDataIn2_inter3;
--                        sDataIn3_inter4  <= sDataIn3_inter3;
--                        sDataIn4_inter4  <= sDataIn4_inter3;
--                        sDataIn5_inter4  <= sDataIn5_inter3;

                        sEnableDelayChain(0)    <= sEnableIn;
                        for i in 1 to 10 loop
                                sEnableDelayChain(i)    <= sEnableDelayChain(i-1);
                        end loop; 
                        
                        --the fourth pipeline
                        ------------------实现每一分支的运算需要4个时钟周期---------------------
                        sProd0(0)       <= sDataIn0_inter3* signed(sRomData5_2);
                        sProd0(1)       <= sDataIn1_inter3* signed(sRomData4_2);
                        sProd0(2)       <= sDataIn2_inter3* signed(sRomData3_2);
                        sProd0(3)       <= sDataIn3_inter3* signed(sRomData2_2);
                        sProd0(4)       <= sDataIn4_inter3* signed(sRomData1_2);
                        sProd0(5)       <= sDataIn5_inter3* signed(sRomData0_2);

                        --the fifth pipeline
                        sProd1(0)       <= sProd0(0)+sProd0(1);
                        sProd1(1)       <= sProd0(2)+sProd0(3);
                        sProd1(2)       <= sProd0(4)+sProd0(5);
                        
                        --the sixth pipeline
                        sProd2          <= sProd1(0)+sProd1(1)+sProd1(2);
                       
                        --the seventh pipeline
                        sEnableOut      <= sEnableDelayChain(5);
                        
                        --ROUND
                        if sProd2(kRomOutWidth2-2-1)='0' then
							sDataOut        <= sProd2(kDataWidth+kRomOutWidth2-3 downto kRomOutWidth2-2);
						else
							sDataOut        <= sProd2(kDataWidth+kRomOutWidth2-3 downto kRomOutWidth2-2)+1;
						end if;
                end if;
        end process;

end rtl;