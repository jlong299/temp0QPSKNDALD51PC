--2-----------------------------------------------------------------------------
--
-- Author: Zaichu Yang
-- Project: QPSK  Demodulator
-- Date: 2009.6.30
--
-------------------------------------------------------------------------------
--
-- Purpose: 
-- 	Revolve the phase based on  error of carrier.(parallel structure with 2 branch)
-------------------------------------------------------------------------------
--
-- Revision History: 
-- 2009.6.30 first revision
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Phase_Revolve_P2 is 
  generic(
  	kDataWidth  : positive := 8;
  	kErrWidth   : positive := 12;
  	kSinWidth   : positive := 16
  	);
  port(               
    aReset            : in std_logic;
    Clk               : in std_logic;
                    
    -- Input data from timing recovery module
    sEnableIn         : in std_logic;
    sInPhase0         : in std_logic_vector(kDataWidth-1 downto 0);
    sQuadPhase0       : in std_logic_vector(kDataWidth-1 downto 0);
    sInPhase1         : in std_logic_vector(kDataWidth-1 downto 0);
    sQuadPhase1       : in std_logic_vector(kDataWidth-1 downto 0);
    
    sErrCarrier       : in std_logic_vector(kErrWidth-1 downto 0);
    
    -- output data ready signal and data
--    sEnableOut        : out boolean;
    sInPhaseOut0       : out std_logic_vector(kDataWidth-1 downto 0);
    sQuadPhaseOut0     : out std_logic_vector(kDataWidth-1 downto 0);
    sInPhaseOut1       : out std_logic_vector(kDataWidth-1 downto 0);
    sQuadPhaseOut1     : out std_logic_vector(kDataWidth-1 downto 0));
end Phase_Revolve_P2;

architecture rtl of Phase_Revolve_P2 is

	component Phase_Revolve_branch is 
	  generic(
	  	kDataWidth  : positive := 8;
	  	kErrWidth   : positive := 12;
	  	kSinWidth   : positive := 16
	  	);
	  port(               
	    aReset       : in std_logic;
	    Clk          : in std_logic;
	                    
	    -- Input data from timing recovery module
	    sEnableIn    : in std_logic;
	    sInPhase     : in signed (kDataWidth-1 downto 0);
	    sQuadPhase   : in signed (kDataWidth-1 downto 0);
	    
	    sPhaseRevolve: in signed (kErrWidth downto 0); 
	    
	    -- output data ready signal and data
	    sInPhaseOut  : out signed(kDataWidth-1 downto 0);
	    sQuadPhaseOut: out signed(kDataWidth-1 downto 0));
	end component;

    	type BooleanArray is array (natural range <>) of boolean;
		type InputDataArray is array (natural range <>) of signed(kDataWidth-1 downto 0);
			
    	signal sInData_Reg0,sQuadData_Reg0: InputDataArray (1 downto 0);
    	signal sInData_Reg1,sQuadData_Reg1: InputDataArray (1 downto 0);
		signal sEnableIn_Reg    : BooleanArray ( 1 downto 0);
    	
    	--To avoid overflow, the width is kErrWidth+1, and the format is (2,kErrWidth-2)
    	signal sPhaseRevolve0,sPhaseRevolve1,sPhaseRevolve2,sPhaseRevolve3 : signed (kErrWidth downto 0); 
    	--signal sPhaseRevolve1 : signed (kErrWidth downto 0); 
    	
    	
    	--Output Register
		signal sEnableOut_Reg    : Boolean;
		signal sInPhaseOut_Reg0	 : std_logic_vector(kDataWidth-1 downto 0);
		signal sInPhaseOut_Reg1	 : std_logic_vector(kDataWidth-1 downto 0);
		signal sQuadPhaseOut_Reg0: std_logic_vector(kDataWidth-1 downto 0);
		signal sQuadPhaseOut_Reg1: std_logic_vector(kDataWidth-1 downto 0);

begin

	entity_Phase_Revolve_branch1: Phase_Revolve_branch 
	  generic map(kDataWidth,kErrWidth,kSinWidth)
	  port map(               
	    aReset       => aReset,
	    Clk          => Clk,
	                    
	    -- Input data from timing recovery module
	    sEnableIn    =>	sEnableIn,
	    sInPhase     =>	sInData_Reg0(1),
	    sQuadPhase   =>	sQuadData_Reg0(1),
	    
	    sPhaseRevolve=> sPhaseRevolve2,
	    
	    -- output data ready signal and data
	    std_logic_vector(sInPhaseOut)  => sInPhaseOut_Reg0,
	    std_logic_vector(sQuadPhaseOut)=> sQuadPhaseOut_Reg0
	    );

	entity_Phase_Revolve_branch2: Phase_Revolve_branch 
	  generic map(kDataWidth,kErrWidth,kSinWidth)
	  port map(               
	    aReset       => aReset,
	    Clk          => Clk,
	                    
	    -- Input data from timing recovery module
	    sEnableIn    =>	sEnableIn,
	    sInPhase     =>	sInData_Reg1(1),
	    sQuadPhase   =>	sQuadData_Reg1(1),
	    
	    sPhaseRevolve=> sPhaseRevolve3,
	    
	    -- output data ready signal and data
	    std_logic_vector(sInPhaseOut)  => sInPhaseOut_Reg1,
	    std_logic_vector(sQuadPhaseOut)=> sQuadPhaseOut_Reg1
	    );


PhaseRevolve_Calc: Process ( aReset, Clk)
	begin
		if aReset='1' then
			for i in 0 to 1 loop
				sInData_Reg0(i)		<= (others => '0');
				sQuadData_Reg0(i)	<= (others => '0');
				sInData_Reg1(i)		<= (others => '0');
				sQuadData_Reg1(i)	<= (others => '0');
			end loop;

--			sEnableOut			<= false;
			sInPhaseOut0		<= (others => '0');
			sQuadPhaseOut0	<= (others => '0');
			sInPhaseOut1		<= (others => '0');
			sQuadPhaseOut1	<= (others => '0');
			
			sPhaseRevolve0			<= (others => '0');
			sPhaseRevolve1  		<= (others => '0');
			--sPhaseRevolve1(kErrWidth) <= '0';
			sPhaseRevolve2			<= (others => '0');
			sPhaseRevolve3			<= (others => '0');
			
		elsif rising_edge(Clk) then
				-- the first pipline
			if sEnableIn='1' then
				sInData_Reg0(0)		<= signed(sInPhase0);	
				sQuadData_Reg0(0)	<= signed(sQuadPhase0);
				sInData_Reg1(0)		<= signed(sInPhase1);	
				sQuadData_Reg1(0)	<= signed(sQuadPhase1);
				
				sInData_Reg0(1)		<= sInData_Reg0(0);
				sQuadData_Reg0(1)	<= sQuadData_Reg0(0);
				sInData_Reg1(1)		<= sInData_Reg1(0);
				sQuadData_Reg1(1)	<= sQuadData_Reg1(0);
				
				
				sPhaseRevolve0   <= sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth-2 downto 0)+signed(sErrCarrier(kErrWidth-1) & sErrCarrier(kErrWidth-1 downto 0) );
				sPhaseRevolve1   <= sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth-2 downto 0)+signed(sErrCarrier & '0');
			
					
				sPhaseRevolve2	<= sPhaseRevolve0(kErrWidth) & sPhaseRevolve0(kErrWidth) & sPhaseRevolve0(kErrWidth-2 downto 0);
				sPhaseRevolve3	<= sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth) & sPhaseRevolve1(kErrWidth-2 downto 0);
									
--				if sPhaseRevolve1(kErrWidth downto kErrWidth-1) = "01" then 
--					sPhaseRevolve0	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1) & sErrCarrier)-to_signed(2**(kErrWidth-1),kErrWidth+1);
--				elsif sPhaseRevolve1(kErrWidth downto kErrWidth-1) = "10" then
--					sPhaseRevolve0	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1) & sErrCarrier)+to_signed(2**(kErrWidth-1),kErrWidth+1);
--				else
--					sPhaseRevolve0	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1) & sErrCarrier);
--				end if;
				
--				if sPhaseRevolve1(kErrWidth downto kErrWidth-1) = "01" then 
--					sPhaseRevolve1	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1 downto 0) & '0')-to_signed(2**(kErrWidth-1),kErrWidth+1);
--				elsif sPhaseRevolve1(kErrWidth downto kErrWidth-1) = "10" then
--					sPhaseRevolve1	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1 downto 0) & '0')+to_signed(2**(kErrWidth-1),kErrWidth+1);
--				else
--					sPhaseRevolve1	<= sPhaseRevolve1+signed(sErrCarrier(kErrWidth-1 downto 0) & '0');
--				end if;
--
			--end if;	
			
			
--			sEnableOut			<= sEnableOut_Reg;
			sInPhaseOut0		<= sInPhaseOut_Reg0;
			sQuadPhaseOut0		<= sQuadPhaseOut_Reg0;
			sInPhaseOut1		<= sInPhaseOut_Reg1;
			sQuadPhaseOut1		<= sQuadPhaseOut_Reg1;
		else
			null;
		end if;
		end if;
	end Process;
	
	
end rtl;  
