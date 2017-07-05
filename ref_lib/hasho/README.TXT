#/**		@file  		README.TXT
# *
# *     Copyright (c) 2006~ by Upresto Inc, Korea
# *     All rights reserved.
# * 
# * 	$Id: README.TXT,v 1.3 2006/06/09 06:54:24 cjlee Exp $
# * 
# *     @Author      $Author: cjlee $
# *     @version     $Revision: 1.3 $
# *     @date        $Date: 2006/06/09 06:54:24 $
# *     @todo        먼저 읽어보시기 바랍니다. 
# *
# *     @section     Intro(소개)
# *      - hashg는 main memory에서 도는 것 입니다. (malloc으로  memory할당)
# *		   hasho는 memg를 이용한 memory 관리 안에서 이를 해결합니다. 	
# *
# *     @section     Requirement Tool
# *      @li doxygen 
# *      @li gcc 
# *      @li graphviz 
# *      @li perl 
# *
# **/

/*****************************
* Tue Apr 11 16:44:40 KST 2006
2006.04.11

실행 순서 :
$ ./configure
$ ./make
$ 실행 화일 (실행)  - hashg
$ ./make doc

문서명 : [철주] HASH and Timer 정의 v1.0.doc

files :
Doxyfile	 - doxygen configuration file
HISTORY.TXT
Makefile	
README.TXT
configure	- configure file 미리 실행하여 structg등을 CVS에서 가져오고 compile함.
hasho.c		- hasho library file
hash.stg	- hasho에서 사용하는 structure 모음.

/*****************************
* 2006.04.18
hashg : main memory에서 구현한 것 
hasho : offset을 가지고 하는 것 (main mem or shared mem : 사이즈 일정) - 이게 프로그램할때 한계등에 대해서 명확히 정의가 됨

*설계
- hashg를 offset중심으로 변경을 시킨다. (pointer를 절대 사용하면 안된다. )
  내부적으로 사용하는 primitives는 변경을 하지 않는 것으로 한다. 
  
/*****************************
* 2006.04.20
Makefile안에서 LIBS    = $(LIBRARY) -lmemg -lSTGhasho -lSTGmemg  이렇게 수행해야 하는데,
순서를 바꾸면 에러가 나온다.
-l ... 일때 뒤의 것부터 memory에 load 하여 두는 것으로 보인다.
가장 기본이 되는 것을  뒷쪽에 나열하는 것이 맞는 것으로 판단된다. 


TEST를 어떻게 할지 설계를 해야 할 것으로 보인다.
문제는 TEST를 하고 결과가 제대로 나오는지를 자동으로 체크할 방법을 찾아야 한다. 방법이 있을가? 


/*
 *      - hash library 파일  (offset개념으로 작성)
 *      - hasho_init으로 초기롸를 한후에 기본저인 primitives 를 이용하게 함
 *      - primitives
 *      	@li hasho_init
 *      	@li hasho_add  , hasho_link_node
 *      	@li hasho_del  , hasho_unlink_node
 *      	@li hasho_find
 *      	@li hasho_print_info
 *      	@li hasho_print_node
 *      	@li hasho_print_all
 *      	@li Supplement 		: hasho_draw_all
@code
 *      - Hasho 구조  (v1.1) 
 *      규칙 0 : memg안에서의 offset은 pstMEMGINFO 에서부터의 offset임.
 *   pstHASHOINFO = hasho_init(sizeof(stKEY)=8, sizeof(stKEY)=8, sizeof(stDATA)=4 , 4  :: hash size 0
 *
 *                        +----------------------------------+
 *                    48  |    memg_info (stMEMGINFO)        | [H]offset_memginfo = -48
 [M]offsetHeadRoom(48) -> +----------------------------------+
 *                    36  |    Head Room                     |  20 stHASHOINFO    
 *                        |                                  |  16 [H]offset_psthashnode = 20
 [M]offsetNodeStart(84)-> +----------------------------------+
 *                    16  |    memg node hdr1(stMEMGNODEHDR) |
 *                 +--28------+memg node data                |
 *                 |      +----------------------------------+
 *                 |  16  |    memg node hdr2(stMEMGNODEHDR) |
 *                 |  28  |    memg node data                |
 *                 |      +----------------------------------+
 *                 |      |    memg node hdr3(stMEMGNODEHDR) |
 *                 |      |    memg node data                |
 *                 |      +----------------------------------+
 *                 |
 *                 |
 *                 |    규칙 : hasho 의 offset은 pstHASHOINFO에서부터의 offset을 의미함.
 *           [H]52 +----> +----------------------------------+
 *                     4  |    offset_next          +----------------------------+      
 *                     4  |    offset_prev                   |                   |      
 *                     4  |    offset_Key     +--------------------+             |      
 *                     4  |    offset_Data    +--------------------|---+         |      
 *          offset_Key    +----------------------------------+<----+   |         |      
 *                     8  |    Key (usKeyLen)                |         |         |      
 *          offset_Data   +----------------------------------+<--------+         |      
 *                     4  |    Data (usDataLen)              |                   |      
 *                        +----------------------------------+                   |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                        +----------------------------------+<------------------+      
 *                     4  |    offset_next                   |                          
 *                     4  |    offset_prev                   |                          
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *                        +----------------------------------+
 *                     4  |    offset_next                   |
 *                     4  |    offset_prev                   |
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *             [M] 1844   +----------------------------------+
 *
 *       offset 기준 : 
 *       pstMEMGINFO      -> stMEMGINFO 안의  offset 들
 *       pstHASHOINFO     -> stHASHOINFO , stHASHONODE 안의 offset 들 
@endcode
*/


hasho에서는 현재 hasho_add를 할때 memcpy를 하는데
hasho_add전이든 뭐든 mem을 할당해서 그 mem을 사용하게 하는 것으로 해주었으면 함.

요구사항...
[류태중] 흘러가는 데로~~/우우/ 님의 말 :
현재 hash_add시 데이터 복사가 안일어나고 메모리할당만 하고.. 프로세스가 hash_add 후 메모리에 직접 쓸 수 있도록 해줘..

project 이름 : hashA
요구사항 : 현재 hash_add시 데이터 복사가 안일어나고 메모리할당만 하고.. 프로세스가 hash_add 후 메모리에 직접 쓸 수 있도록 해줘
안 1 : mem alloc을 따로 하여 NODE를 할당받은 후에 , hashA_add시 그 NODE를 더 한다.
-         Primitives
             pNODE = hashA_GetNode(INFO) 추가         // key를 몰라도 그냥 node size만큼 할당
             fail or success = hashA_add(INFO , pNODE) 방식으로 변경
-         사용방법
             pNODE = hashA_GetMem(pstHASHINFO);
             pNODE의 KEY와 DATA에 값을 삽입
             hashA_add(pstHASHINFO , pNODE);
안 2 : hashA_add()를 하여  NODE를 할당받은후에 , 그 DATA에 값을 씀.
문제점 : hash에 넣기 위해서는 key를 미리 알아야 함.  NODE할당이 된 것은 DATA가 없음에도 hash에 달려있으므로 큰 문제는 없게지만, 동시 사용등에 문제가 발생 (현재는 동시 사용없음.)
-         Primitives
n         pNODE = hashA_add(pstHASHINFO , KEY);      // 키를 memcpy해야 하는 부분은 어쩔수 없음
-         사용방법
n         pNODE = hashA_add(pstHASHINFO , pKEY);
n         pNODE에 값을 삽입.
추천안 e 안 1 . 



#/** file			README.TXT
# *     $Log: README.TXT,v $
# *     Revision 1.3  2006/06/09 06:54:24  cjlee
# *     no message
# *
# *     Revision 1.2  2006/04/21 08:06:20  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.1  2006/04/21 02:19:49  cjlee
# *     INIT
# *
# *
# *     */
