#/*!		@page  Makefile
# *
# *		Copyright (c) 2006~ by Upresto Inc, Korea
# *		All rights reserved.
# * 
# *		$Id: Makefile,v 1.1 2007/03/30 07:28:20 cjlee Exp $
# *
# *		@Author      $Author: cjlee $
# *		@version     $Revision: 1.1 $
# *		@date        $Date: 2007/03/30 07:28:20 $
# *		@warning     여러개를 할때도 $< 이 맞는지 확인은 안됨 
# *		@warning     clean tag에서 *hash.h 라는 이름은 hash.stg안에 output file이름을 나타낸 것이다.
# *		@ref         README.TXT    HISTORY.TXT
# *		@todo        clean 등의 tag를 원할히 처리하기 위해서 Makefile도 자동으로 만들어주어야 할 것이다.
# *
# *		@section     Intro(소개)
# *      - Makefile로써 $IN 안에 *.stg를 넣어주면 수행이 되게 된다.
# *
# *		@section     Requirement
# *				@li 	doxygen
# *				@li 	perl
# **/



IN 	= userfile.asng 
MEGACO 	= megaco.berg 
OUT = OUTPUT

all : $(MEGACO)
	echo $<
	/bin/sh ctag.sh
	perl berg.pl $< $(OUT)

preall : $(INPRE)
	echo $<
	perl pstg.pl $<
	perl structg.pl pre.stg $(OUT)

clean :
	rm -f *.o *~ *.stgo *.c *.h *.pc DEBUG*.TXT GLOBAL*.TXT
	rm -rf STRUCTG OUTPUT TEST
	rm -rf OTEST OAQUA OFLOW OSTGL OBIT OCOM  OTT

doc :
	doxygen structg.cfg

pstg :
	perl pstg.pl pstg.pstg
	perl structg.pl pstg.stg OPSTG

test :
	perl pstg.pl $(TEST)
	perl structg.pl test.stg OTEST
	#cp ./OTEST/test.h ./OTEST/STC
	#$(CC) -o test.exe ./OTEST/STC/flow.c -DTEST

aqua :
	perl pstg.pl $(AQUA)
	perl structg.pl aqua.stg OAQUA

sd :
	perl pstg.pl state_diagram.pstg
	perl structg.pl state_diagram.stg OSD
	cp ./OSD/state_diagram.h ./OSD/STC
	$(CC) -g3 -o sd.exe ./OSD/STC/state_diagram.c -DTEST

com :
	perl pstg.pl $(COM)
	perl structg.pl $(TEMP) OCOM

flow :
	perl structg.pl flow.stg OFLOW

flow2 : 
	perl pstg.pl flow2.pstg
	perl structg.pl flow2.stg OFLOW
	cp ./OFLOW/flow2.h ./OFLOW/STC
	$(CC) -o flow2.exe ./OFLOW/STC/flow.c -DTEST

trans_flow : 
	perl pstg.pl trans_flow.pstg
	perl structg.pl trans_flow.stg OFLOW

tt :
	perl structg.pl tt.stg OTT

stgl :
	echo "perl structg.pl userfile.stgL OUTPUT"
	perl structg.pl userfile.stgL OSTGL

bit :
	echo "perl structg.pl bit.stg BIT"
	perl structg.pl bit.stg OBIT
	echo "test main file : ./TESTc/bit.c    -lSTGBit"

conf :
	perl pstg.pl conf.pstg
	perl structg.pl conf.stg OCONF

online :
	perl pstg.pl online.pstg
	perl structg.pl online.stg ONLINE


#/*! @page	Makefile
# *     $Log: Makefile,v $
# *     Revision 1.1  2007/03/30 07:28:20  cjlee
# *     BER 시험
# *
# *     Revision 1.1  2007/03/29 13:52:32  cjlee
# *     INIT
# *
# *     Revision 1.31  2007/03/28 01:03:35  cjlee
# *     state_diagram 예제 추가
# *
# *     Revision 1.30  2007/03/27 12:57:07  cjlee
# *     state_diagram 추가
# *         - 기존의 TAG_FLOW와 같은 기능을 하는 것임.
# *         - 새로운 요구사항을 추가하고, 기존의 것도 그대로 지원하기 위해서 STATE_DIAGRAM 으로 새로 만듦
# *         - <STATE_DIAGRAM_VERTEX:..> </STATE_DIAGRAM_VERTEX:..>  과
# *           <STATE_DIAGRAM_EDGE:..> </STATE_DIAGRAM_EDGE:..> 가 같이 존재해야함
# *         - Example : make sd  하면 됨.  (state_diagram.pstg와 아래의 stc들을 이용하게 됨)
# *
# *     Revision 1.29  2007/03/07 05:14:01  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.28  2007/03/06 08:19:28  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.27  2007/02/28 04:05:51  cjlee
# *      LOG_COMMON (STG_COMMON)안에서도 TAG_DEFINE:... 사용가능
# *
# *     Revision 1.26  2007/02/27 07:57:46  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.25  2007/02/27 06:49:04  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.24  2007/02/20 09:24:45  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.23  2007/02/20 03:47:09  cjlee
# *     STG_PARM 기능 추가
# *
# *     Revision 1.22  2007/02/16 04:52:15  cjlee
# *     FLOW에서 VERTEX와 EDGE로 구분되어 처리됨
# *
# *     Revision 1.21  2006/10/31 04:52:46  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.20  2006/10/27 05:11:37  dark264sh
# *     *** empty log message ***
# *
# *     Revision 1.19  2006/10/09 02:54:29  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.18  2006/09/06 08:20:13  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.17  2006/09/06 01:22:41  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.16  2006/09/06 00:07:01  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.15  2006/09/05 00:11:47  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.14  2006/08/29 04:06:18  cjlee
# *     BIT 처리 완료 : compile 완료
# *
# *     Revision 1.13  2006/08/29 02:21:31  cjlee
# *     BIT operation 추가
# *     	BIT16			a1 (1 : PING);				/**< TOS의 첫번째 bit */
# *     	BIT16			ctime (12 : PING);			/**< TOS 마지막 3개의 bit */
# *     	BIT16			b ( 3 : PING);
# *
# *     결과물 : flat , Dec , Enc , Prt 모두 변형됨
# *
# *     Revision 1.12  2006/08/22 06:17:28  cjlee
# *     no message
# *
# *     Revision 1.11  2006/08/22 01:28:31  cjlee
# *     1. precomile을 해야하는 것들에 대한 확장자는 .pstg 로 하는 것이 좋을 것으로 보인다. 이것을 하면 확장자가 .stg로 나오게 하면 될 것으로 보인다.
# *     	pstg.pl 생성
# *     	pstg용 file들 : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
# *     	Makefile에 flow , aqua , test  여러기지 추가
# *
# *     Revision 1.10  2006/08/18 10:45:14  cjlee
# *     no message
# *
# *     Revision 1.9  2006/07/31 06:39:04  cjlee
# *     precompile이 되게 함.
# *     KUN , ME에 대해서 call 관련 structure에 대한 처리 완료
# *     structg.pl -> input : argv , output : 안의 FileName : 으로 된 것
# *     structg_precompile1.pl -> input : pre.stg , output : userfile_pre.stg
# *     make pre --> input : pre.stg , output : userfile_pre.stg
# *
# *     Makefile안을 보면 좀더 상세히 알수 있음.
# *
# *     Revision 1.8  2006/07/28 06:31:41  cjlee
# *     no message
# *
# *     Revision 1.7  2006/07/25 02:45:47  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.6  2006/05/29 05:05:34  cjlee
# *     make clean에서 TEST , GLOBAL.TXT등을 추가로 지워줌.
# *
# *     Revision 1.5  2006/03/19 03:44:17  yhshin
# *     IN = userfile.stg 변경
# *
# *     Revision 1.4  2006/04/06 04:23:09  cjlee
# *     OUTPUT 삭제 추가
# *
# *     Revision 1.3  2006/04/06 00:30:57  cjlee
# *     structg.pl 을 사용
# *
# *     Revision 1.2  2006/04/03 07:06:26  cjlee
# *     in case of clean , we can remove all .h files
# *
# *     Revision 1.1  2006/03/31 00:55:31  cjlee
# *     INIT
# *
# *     */
