#/*!		@page  		README.TXT
# *
# *     Copyright (c) 2006~ by Upresto Inc, Korea
# *     All rights reserved.
# * 
# * 	$Id: README.TXT,v 1.47 2006/08/28 01:19:47 cjlee Exp $
# * 
# *     @Author      $Author: cjlee $
# *     @version     $Revision: 1.47 $
# *     @date        $Date: 2006/08/28 01:19:47 $
# *     @todo        ¸ÕÀú ÀÐ¾îº¸½Ã±â ¹Ù¶ø´Ï´Ù. 
# *
# *     @section     Intro(¼Ò°³)
# *      - ±âº» »ý°¢µéÀ» ¿©±â¿¡ Àû¾îµÎ¾ú½À´Ï´Ù.
# *
# *     @section     Requirement Tool
# *      @li perl 
# *      @li doxygen 
# *
# **/

#/*! @page			README.TXT
# *     $Log: README.TXT,v $
# *     Revision 1.47  2006/08/28 01:19:47  cjlee
# *     no message
# *
# *     Revision 1.46  2006/08/23 01:32:56  cjlee
# *     *.stc¾ÈÀÇ IFEQUAL µÚÀÇ multi-line Ã³¸® ¿Ï·á
# *     #{    ...   }# À¸·Î multi-line Ã³¸®
# *     ±âÁ¸ÀÇ ÇÑ¶óÀÎÀº IFEQUAL(A,B)  ... À¸·Î ¿¹Àü°ú °°ÀÌ ±×³É »ç¿ëÇÏ¸é µÊ
# *     multi-lineÀÏ¶§¸¸ À§ÀÇ #{ .. }#À» »ç¿ëÇÏ¸éµÊ.  flow.stc¾È¿¡ ¿¹Á¦ Ãß°¡ÇÏ¿´À½.
# *
# *     Revision 1.45  2006/08/22 09:17:24  cjlee
# *     <TAG_FLOW_START:PAGE>¿¡¼­ action¿¡ ´ëÇÑ multi line Ã³¸® ¿Ï·á
# *     % .. %   # .. # ÇÑÁÙÀÏ¶§´Â # # À¸·Î Ã³¸®
# *     ¿©·¯ÁÙÀÏ¶§´Â #{     ¿©·¯ÁÙ    }# À¸·Î ³¡À» ¾Ë¸²
# *
# *     Revision 1.44  2006/08/22 05:34:26  cjlee
# *     2. stg¸¦ multi·Î Ã³¸®ÇÒ¼ö ÀÖ°Ô ¼öÁ¤ stgµéÀÇ ¸ðÀ½ÀÌ ÀÖÀ»°æ¿ì¿¡´Â ÀÌ°ÍµéÀ» ÂÓ Ã³¸®ÇÒ¼ö ÀÖ´Â stglÀ» ¸¸µé´øÁö ÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù. (ÀÔ·Â fileÀÌ stgl ÀÎ °æ¿ì¿¡´Â List·Î ÇØ¼®ÇÏ¿© Ã³¸®ÇÏµµ·Ï structg.pl À» ¼öÁ¤ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.) - precompile°ü·Ã±îÁö Ãß°¡¸¦ ÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù.
# *     ÇÑ°³·Î ¸ð¾ÆÁÖ´Â °ÍÀÌ ¸ÂÀ» °ÍÀÌ¶ó »ý°¢µÈ´Ù. FileNameÀ¸·Î .h°¡ »õ·Î »ý¼ºÀÌ µÇ´Â °ÍÀÌ°í, stg¾È¿¡ ÀÖ´Â FileNameÀº ¹«½Ã µÇ°Ô µÉ °ÍÀÌ´Ù.
# *     test.stg , flow.stg°¡ ÀÖ´Ù°í ÇÏ¸é __ FileNameÀº ¹«½Ã , STC_FileName Àº ÇÕÄ¡°í ,
# *     *.stg¿¡ ³ª¿Â °ÍµéÀ» FileName.h -> $outputdir/FileName.stg·Î ¸ðÀº´Ù. ÀÌ ¸ð¾ÆÁø °ÍÀ» °¡Áö°í Ã³¸®¸¦ ÇÑ´Ù.
# *
# *     Revision 1.43  2006/08/22 01:28:31  cjlee
# *     1. precomileÀ» ÇØ¾ßÇÏ´Â °Íµé¿¡ ´ëÇÑ È®ÀåÀÚ´Â .pstg ·Î ÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. ÀÌ°ÍÀ» ÇÏ¸é È®ÀåÀÚ°¡ .stg·Î ³ª¿À°Ô ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.
# *     	pstg.pl »ý¼º
# *     	pstg¿ë fileµé : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
# *     	Makefile¿¡ flow , aqua , test  ¿©·¯±âÁö Ãß°¡
# *
# *     Revision 1.42  2006/08/21 11:12:32  cjlee
# *     precompile : STG_COMMON ¿¡¼­ alternative¸¦ ÇÑ°³µµ »ç¿ëÇÏÁö ¾ÊÀ»¶§ ¹®Á¦ ÇØ°á (STG_BASICÀ» »ç¿ë)
# *     aqua.stg
# *     structg_precompile1.pl
# *
# *     Revision 1.41  2006/08/21 04:47:23  cjlee
# *     for PAGE TEST
# *
# *     Revision 1.40  2006/08/21 01:29:25  cjlee
# *     $save_typedef¿¡¼­ member check½Ã table_log ÀÏ¶§¸¸ ´Ù¸¥ typeÀÏ¶§ die
# *
# *     Revision 1.39  2006/08/18 10:29:34  cjlee
# *     stc.uprÀ» ¸¸µé¾î .stc¸¦ ±â·ÏÇÏ¸é OUTPUT¹Ø¿¡ ÀÚµ¿À¸·Î »ý¼ºÇÏ°Ô ÇÏ´Â °Í Ãß°¡
# *       ¿¹·Î LOG_member_Get_func.stc ¸¦ Ãß°¡
# *     flow.stc : state_go , print_stateµîÀÇ ÇÔ¼ö¸¦ Ãß°¡ÇßÀ¸¸ç, flow.c¿¡  structure¿¡ °ü°è¾øÀÌ memberÀÇ °ªÀ» ±¸ÇÒ¼ö ÀÖ´Â c++¿¡¼­ member getÇÔ¼ö »ç¿ë
# *     flow.stg : stateµé¿¡ ´ëÇÑ define°ª ÀÚµ¿ »ý¼º ¼±¾ð
# *     structg.pl :
# *      - stc.uprÀ» À§ÇÑ Ã³¸® Ãß°¡
# *      - ITERATE¾È¿¡¼­ Set : A { B } = "C" Ãß°¡
# *      - stc.uprÀÇ °ÍµéÀº OUTPUT¾Æ·¡ ¹Ù·Î »ý¼ºµÇ°Ô ÇÔ
# *      - stc.upr¾ÈÀÇ °ÍÀº Makefile¿¡ Ãß°¡ÇÏ°Ô ÇÔ
# *      - Set Hash 1 ¿¡¼­¸¸ ¼öÇàµÊ.... (¼öÇà ¼ø¼­)
# *      - Ã³¸® ¼ø¼­ º¯°æ : Makefileµî ¸¸µé°í STCÃ³¸® --> STC Ã³¸®ÈÄ Makefile µîÀ» »ý¼º
# *      - %save_typedef_member  , %save_typedef_name Ãß°¡ »ý¼º : LOG_member_Get_func.stc¿¡¼­ »ç¿ë
# *
# *     Revision 1.38  2006/08/16 05:46:07  cjlee
# *     IFEQUAL Ãß°¡
# *     Flow ±×¸² Ãß°¡ : flow.stg , flow_dot.stc
# *
# *     Revision 1.37  2006/08/16 01:22:46  cjlee
# *     FLOW dotÃß°¡
# *
# *     Revision 1.36  2006/08/09 05:33:48  cjlee
# *     no message
# *
# *     Revision 1.35  2006/08/04 12:01:55  cjlee
# *     no message
# *
# *     Revision 1.34  2006/08/03 08:12:32  cjlee
# *     no message
# *
# *     Revision 1.33  2006/08/01 05:51:01  cjlee
# *     no message
# *
# *     Revision 1.32  2006/07/28 04:42:25  cjlee
# *     no message
# *
# *     Revision 1.31  2006/07/27 11:44:10  cjlee
# *     #FIRST# / #LAST# Á¤ÀÇ : Ã³À½ °ªÀ» °¡Áö°í ÀÖÀ»Áö , ¸¶Áö¸· setµÇ¾îÁö´Â °ªÀ» °¡Áö°í ÀÖÀ»Áö¸¦ °áÁ¤ÇØÁÖ´Â RULE
# *
# *     Revision 1.30  2006/07/27 10:58:32  cjlee
# *     STG_COMMON ¼öÇàÀü  (¼³°è ±îÁö ¿Ï¼º : README.TXT)
# *     LOG_TEXT_PARSING±îÁö ÀÏ´Ü ¸¶¹«¸®
# *
# *     Revision 1.29  2006/07/27 01:58:29  cjlee
# *     <TAG_DEFINE_START: ....>  <TAG_DEFINE_END:...> Ã³¸® ¿Ï·á
# *     ÀÇ°ß: ÀÌ·± HTML¸ð¾çÀº
# *         <TAG_DEFINE:.....>  </TAG_DEFINE>
# *
# *     Revision 1.28  2006/07/26 03:27:32  cjlee
# *     <TAG_DEFINE_START:AAA>
# *     #define ....
# *     .... (¼ýÀÚ¸¸)
# *     <TAG_DEFINE_END:AAA>
# *     ·Î Á¤ÀÇÇÏ°í
# *     U32 <AAA>TTT;   ÀÌ·± ½ÄÀ¸·Î »ç¿ëÇÏ¸é ÁÖ¼®µîÀÌ ÀÚµ¿À¸·Î ºÙ´Â´Ù.
# *
# *     Revision 1.27  2006/07/26 02:20:43  cjlee
# *     #defineÀÌ typedef ¾ÈÀÌµç ¹ÛÀÌµç ¸ðµÎ Ã³¸® °¡´É
# *
# *     Revision 1.26  2006/07/25 02:26:45  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.25  2006/06/14 06:41:27  cjlee
# *     no message
# *
# *     Revision 1.24  2006/06/13 07:35:08  cjlee
# *     º¯°æ ³»¿ë  : STAT°ü·Ã Ã³¸® º¯°æ
# *     	table ¸í %s ¾ø¾Ú.
# *     	accumulate , once º¯°æ : STAT_ALL Ãß°¡
# *     	- pc.upr
# *     		table¸í¿¡ %s¸¦ STATÀÏ¶§¸¸ _%s¸¦ ¾ø¾Ú.
# *     	-  structg.pl
# *     		STAT°ü·Ã Ã³¸® Ãß°¡ : Once , Accumulate º¯°æ
# *     		_%s Ã³¸® º¯°æ : table¸í
# *     	- userfile.stg
# *     		STAT ³»¿ë º¯°æ : ACCU.. .INC¿¡¼­¸¸ Å¸ tableÀÇ ³»¿ë »ç¿ë°¡´É
# *     		ÀÚÃ¼ ÀûÀÎ °Í ¾È¿¡¼­´Â pthis¸¸ »ç¿ë°¡´É
# *
# *     Revision 1.23  2006/06/10 07:20:06  cjlee
# *     2006.06.10 protocol ÀÚµ¿È­¿¡´ëÇÑ »õ·Î¿î °ËÅä ÀÇ°ß
# *
# *     Revision 1.22  2006/06/09 07:56:01  cjlee
# *     no message
# *
# *     Revision 1.21  2006/06/09 03:31:15  cjlee
# *     		STG_STAT_TABLE Ãß°¡
# *     		STAT°ü·Ã °á°ú·Î Set_Stat_Once.c ¸¦ ´õ Ãß°¡·Î ³»¾î³õÀ½.
# *     		STG_ACCUMULATE , STG_INCÃß°¡
# *
# *     Revision 1.20  2006/06/08 00:35:08  cjlee
# *     no message
# *
# *     Revision 1.19  2006/06/02 08:46:38  cjlee
# *     no message
# *
# *     Revision 1.18  2006/06/02 08:40:37  cjlee
# *     no message
# *
# *     Revision 1.17  2006/06/01 05:41:27  cjlee
# *     no message
# *
# *     Revision 1.16  2006/05/30 08:43:06  cjlee
# *     no message
# *
# *     Revision 1.15  2006/05/30 08:10:31  cjlee
# *     no message
# *
# *     Revision 1.14  2006/05/29 11:45:04  cjlee
# *     no message
# *
# *     Revision 1.13  2006/05/29 06:13:24  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.12  2006/05/29 05:06:32  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.11  2006/05/26 04:49:46  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.10  2006/05/26 01:13:42  cjlee
# *     no message
# *
# *     Revision 1.9  2006/05/25 07:55:05  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.8  2006/05/17 08:22:42  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.7  2006/05/16 08:38:52  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.6  2006/04/19 07:21:47  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.5  2006/03/11 06:16:22  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.4  2006/04/03 03:34:09  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.3  2006/03/31 01:47:38  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.2  2006/03/31 01:45:28  cjlee
# *     *** empty log message ***
# *
# *     Revision 1.1  2006/03/31 00:59:14  cjlee
# *     *** empty log message ***
# *
# *     */


./structg/structg ·Î ÀÏ´Ü 2°³¸¦ ¸¸µç´Ù. ¿Ö³Ä¸é Çì±ò¸®±â ¶§¹®ÀÌ´Ù.

./structg ¹Ø¿¡¼­   
cvs import -m "INIT" structg upresto start
À» ÇÏ¿© projectÀ» ¸¸µç´Ù.

cvs co structg ¸¦ ÇÏ¸é ¸¸µé¾îÁö´Â °ÍÀ» º¼¼ö ÀÖÀ» °ÍÀÌ´Ù.

binary·Î ÀúÀå : cvs add -kb test.gif    (binary commit)

cvs add Makefile
cvs ci -m "INIT" Makefile

./hash.stg                                                          1.1 - Binary
cvs add -kb hash.stg
cvs ci -m "INIT" hash.stg 


/home/cjlee/structg
¿¡¼­ make clean , make¸¦ ÇÏ¸é ½ÇÇàµÇ´Â °ÍµéÀÌ º¸ÀÔ´Ï´Ù.

°á°ú¹°Àº 
NTAF¿¡¼­ »ç¿ëÇÒ : *.c *h
NTAM¿¡¼­ »ç¿ëÇÒ : flat*.h
ÀÔ´Ï´Ù.  (nested °¡ Àû¿ëµÈ °Í ÀÔ´Ï´Ù. ) 

/*****************************
* Fri Mar 31 09:22:11 KST 2006
2006.03.31

¼öÇà ¹æ¹ý : make ; make doc 
Áö¿ì´Â ¹æ¹ý : make clean

Fileµé ¼³¸í
flat ÀÌ¶õ nestedµÇ¾îÁø structure¸¦ ÆÇÆÇÈ÷ Æì´Â °ÍÀÌ´Ù. (ÀÌÀ¯ : Database¿¡¼­´Â nestedµÈ structure¸¦ »ç¿ëÇÏÁö ¸øÇÑ´Ù°í ÇÔ)
- HISTORY.TXT
-Makefile
-README.TXT 
-code_gen.pl 		: perl È­ÀÏ : file *.c *.h (hash.stg¾ÈÀÇ $FileNameÀ¸·Î Á¤ÀÇ)
-define_stg.h		: stg(structg)¿¡¼­ »ç¿ëÇÏ´Â ±âº»ÀûÀÎ °ÍµéÀ» ¸ð¾ÆµÐ °ÍÀÓ.
-flat_hdr_gen.pl	: perl È­ÀÏ : (hash.stg¾ÈÀÇ $FlatFileNameÀ¸·Î Á¤ÀÇ)µÈ *.h ¸¦ ¸¸µê
-structg.cfg		: Doxygen¿¡¼­ ÀÌ¿ëÇÒ configuration file 
					: INPUT Àº ÇöÀç . À¸·Î ÇÏ°í recursive°¡ µÇ°Ô setµÇ¾îÁ®ÀÖ´Ù.
					: È®ÀåÀÚ°¡ ´Ù¸¥ °ÍÀ» Ã³¸®ÇÏ·Á¸é FILTER¸¦ °íÄ¡¸é µÉ °ÍÀÌ´Ù.
-hash.stg 			: ¿¹Á¦·Î Nested¸¦ Æ÷ÇÔÇÏ´Â ¿¹Á¦·Î perlÀÇ input °ªÀÌ´Ù. 
					: ¿ì¸®´Â ÀÌ ºÎºÐÀ» ¸¸µé¾î¾ß ÇÑ´Ù.
-flat.upr			: flat fileÀ» ¸¸µé¶§ ÇÊ¿äÇÑ °ÍÀ¸·Î flat file¿¡¼­ »ç¿ëÇÒ ³»¿ëÀ» Á¤ÀÇÇÑ °ÍÀÌ´Ù.(DB¿ë) 
-header.upr			: file header¿¡ Á¤ÀÇÇÏ±â À§ÇÑ generic form
-footer.upr			: file footer¿¡ Á¤ÀÇÇÏ±â À§ÇÑ generic form
-function.upr		: file¾ÈÀÇ Á¤ÀÇµÈ functionµé ¾ÕÀÇ ÁÖ¼®ÀÇ generic form


/*****************************
* Sat Apr  1 22:27:49 KST 2006
2006.04.01

À§ÀÇ ±¸ÇöÀ» ÇØ¾ß ÇÏ´Â °ÍÀ» Â÷±ÙÂ÷±ÙÇØ¾ß ÇÒ °ÍÀÌ´Ù.
-         structg°¡ Á¦ÀÏ ¸ÕÀü ÇÑ °ÍÀÌ°í
n         perl¿¡ ´ëÇÑ docÀÎ perldocÀ» º¸°í , ÀÌ°Í¿¡ ´ëÇÑ ¹®¼­¸¦ ÀÛ¼ºÇØ¾ß ÇÑ´Ù.
u       perldoc perl
u       perldoc perlre
u       perldoc Net::FTP
n         °¡´ÉÇÑ, Ç×»ó, use strict;¸¦ »ç¿ëÇÏ½Ê½Ã¿À. ÇÁ·Î±×·¥ÀÌ Ä¿Áú¼ö·Ï ¹ö±×°¡ ¸¹¾ÆÁý´Ï´Ù. ±×·¯³ª use strict;¸¦ »ç¿ëÇÏ¸é ¹ö±×¸¦ ½±°Ô Ã£¾Æ³¾ ¼ö ÀÖ°í, ¶Ç Àû°Ô »ý±é´Ï´Ù. 
u       perldoc strict   ÇÏ¸é help°¡ ³ª¿À°í ±×°ÍÀ» º¸°í ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. (ÃßÈÄ)
-         Ethereal SRCºÐ¼®
-         configuration¿¡ ´ëÇØ¼­ Ã³¸®¸¦ ÇØ¾ß ÇÑ´Ù.
-         hash / timer / sequence ¸¸µé°Í
-         TESTÇÔ¼ö¸¦ Ãß°¡ÇØ¾ß ÇÑ´Ù.
-         Debugging °ü·Ã ÇÔ¼ö ¸¸µé °Í
-         ÀüÃ¼ ¸ð¾çÀ» ±×¸®°í, ±×¿¡ µû¸¥ primitives µîÀ» Á¤ÀÇÇÑ ÈÄ¿¡ Á¤ÀÇµÈ ºÎºÐÀ» °¡Áö°í ¾î¶»°Ô È°¿ëÇÒÁö±îÁö °í·ÁÇÑ ¼³°è¸¦ ÇÏ¿©¾ß ÇÑ´Ù. (SoftwareÀûÀÎ ¼³°è°¡ ÇÊ¿ä)

ÀüÃ¼ÀûÀÎ ¸ð¾ç (ÇÑ°³ ÇÑ°³ Â÷±ÙÂ÷±Ù)
- NTAF¿¡¼­ ½ÇÁ¦·Î ¸ðµç ÀÏÀ» Ã³¸®ÇÏ´Â ¸ð¾çÀ¸·Î °¡Áø´Ù.
- Process´ÜÀ§·Î ¸¸µé¾îÁö¸ç, °¢ process´Â ´Ù¸¥ ¾ð¾î·Î °³¹ßµÉ¼ö ÀÖ¾î¾ß ÇÑ´Ù.
- ±âº» library¸¦ ¸¸µé¾î¾ß ÇÏ¸ç , °¢ library¿¡ ´ëÇØ¼­´Â primitives¸¦ Á¦´ë·Î Á¤ÀÇ¸¦ ÇÏ¿© »ç¿ëÇØ¾ß ÇÑ´Ù.
	+ TEST library (code generatorÀÇ ¸òÀÌ µÉ¼öµµ ÀÖ´Ù.)
	+ debugging / timer / hash or AVL / shared memory / sequence / conf file / ºÐ¼®±â¹ý / text parser
- code generator¸¦ ¸¹ÀÌ È°¿ëÇÏ´Â ¹æ¾ÈÀ» °¡Áø´Ù.
	+ structg(typdef struct¿¡ ´ëÇØ¼­ ÀÚµ¿ ÄÚµå »ý¼º) °ú °°Àº toolµéÀ» ¸¹ÀÌ ¸¸µé¾î¾ß ÇÑ´Ù.  »ç¿ëÇÏ´Â ±¸Á¶¸¦ ¿©·¯ ¾ð¾î·Î ¸¸µé¾î¼­ ¹èÆ÷ ÇÒ¼ö ÀÖ°Ô ¸¸µå´Â °ÍÀÌ ¸ñÇ¥°¡ µÇ¾î¾ß ÇÑ´Ù.
- °¢ protocolÀÌ Ãß°¡µÇ¾úÀ»¶§ ÀÌ ºÎºÐÀ» conf¸¦ GUI°°Àº °÷¿¡¼­ ¹Ù²Ù¾îÁÖ¸é ¹Ù²ï ¼ø¼­·Î´ë·Î Ã³¸®°¡ µÇ°Ô ÇÏ¿©¾ß ÇÑ´Ù. 
	+ ÀÌÁ¡À¸·Î´Â PPP°¡ protocol stack¿¡¼­ 2¹øÀÌ ³ª¿Â´Ù°í ÇÏ¿©µµ, ¹®Á¦°¡ µÇÁö ¾ÊÀ¸¸ç
		== pppµîÀÇ ÇÁ·Î°Ô½º¸¦ ¸¸µé¶§, nameÀº argv·Î µû·Î ½ÇÇàÀ» ÇÏ°Ô ÁÖ¾î¾ß ÇÑ´Ù. ±×·¡¾ß °°Àº ppp¶óµµ µÚ¿¡ ÁÖ¾îÁö´Â ÀÌ¸§À¸·Î ±¸º°À» ÇÒ¼ö ÀÖ±â ¶§¹®ÀÌ´Ù. 
	+ ¼¼¼¼ÇÑ protocol´ÜÀ§·Î ½±°Ô Ã³¸®¸¦ ¸¸µé¼ö ÀÖ´Ù. 
	+ °¢ moduleÀÇ in / out¿¡ ´ëÇØ¼­ ¾î¶»°Ô Á¤ÀÇ¸¦ ÇÏ¿©¾ß ÇÏ´ÂÁö °í¹Î (in/outÀÌ ´Ù¸¥ typeÀ¸·Î ³ª¿À´Â °æ¿ì°¡ ¹ß»ýÇÏ´ÂÁö ÀÌ¸¦ ÀÚ·ù·Ó°Ô ¼³Á¤ÇÏ·Á¸é ¾î¶»°Ô ÇØ¾ß ÇÏ´ÂÁö?)


/*****************************
* Mon Apr  3 09:52:40 KST 2006
2006.04.03
³»°¡ ±ÞÇÏ°Ô ÇØ¾ß ÇÒÀÏ
- ÀüÃ¼ frame work : perl ÁÖ¼® ´Þ±â , ÀÏ¹ÝÀû hash¸¸µé±â , timer ¸¸µé±â
	+ conf ¸¸µé±â¿Í text parser´Â ´Ù¸¥ »ç¶÷¿¡°Ô ÀÌ°üÀ» ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÓ.

³ªÀÇ ½ºÄÉÁÙ
- ¿À´Ã : perl ÁÖ¼® ´Þ±â , ÀÏ¹ÝÀû hash¸¸µé±â ½ÃÀÛ(stg_code_gen [structg]¸¦ ÀÌ¿ë)
perl ÁÖ¼®Àº enginsiteÀÇ perl editor¸¦ »ç¿ëÇÒ ¿¹Á¤ÀÓ


/*****************************
* Tue Apr 11 14:35:57 KST 2006
2006.04.11
* [Ã¶ÁÖ] Code Generator (structg) v1.0.doc ÀÛ¼º ¿Ï·á 
* °í·Á»çÇ×
-	¸¹Àº ¼öÇàÀ» ÇØº¸¾Æ¾ß ÇÑ´Ù.
-	hash¸¦ structg¸¦ ÅëÇØ¼­ ¸¸µé¾î º¸´Â °ÍÀ» ½ÃÇèÀ» ÇØº¸¾Æ¾ßÇÑ´Ù.
-	ÁÖ¼®À» ´Ù´Â °Í¿¡ ´ëÇØ¼­ »ìÆìº¸¾Æ¾ß ÇÑ´Ù.
-	ProCµî ´Ù¸¥ »ç¿ëÇØ¾ß ÇÏ´Â ÇÏ´Â ÀÚµ¿ ÄÚµå »ý¼º¿¡ ´ëÇØ¼­ °í·ÁÇØº¸¾Æ¾ßÇÑ´Ù.
-	ÇÔ¼öÀÇ ±ÔÄ¢À» ´õ °í·ÁÇØ¾ß ÇÔ.
-	make install À» ¸¸µé¾î¾ß ÇÑ´Ù.


2006.04.19
¿øÄ¢ : OUTPUTÀ¸·Î´Â ÇÑ°³ÀÇ .h¿Í ÇÑ°³ÀÇ .a¸¦ °¡Áø´Ù.  (flat_?.h ´Â pc¸¦ À§ÇØ¼­¸¸ º°µµ »ç¿ë)

======================================================================================
====   Section   Two  (2)
======================================================================================
Áö±Ý ÇØ¾ß ÇÏ´Â °ÍÀº CorelationÀÇ ÀÚµ¿È­¸¦ À§ÇÑ °ÍÀ¸·Î 
corelationÀ» ¾î¶»°Ô ÇÏ¸é º¯°æ¾øÀÌ keyµîÀ» Á¤ÀÇÇÑ °ª¿¡ ´ëÇØ¼­¸¸ º¯°æÀ» ÇÏ¸é
ÀÚµ¿À¸·Î code°¡ »ý¼ºµÇ°Ô ÇÒ¼öÀÖ´ÂÁö¿¡ ´ëÇÑ ÀÇ°ßÀ» ³ª´©±â À§ÇÑ °ÍÀÌ´Ù. 

±âº»ÀûÀ¸·Î ³ª¿À´Â °ÍÀÌ 
CreateTime , IMSI , TMSI , IP µîÀÌ ÀÖ¾úÀ¸¸ç, ÀÌ°Í¿¡ ´ëÇØ¼­´Â ³Ö¾îµÎ´Â ¼ø¼­¿¡ µû¶ó Key·Î ¼³Á¤À» ÇØ¾ß ÇÏ°í , 
ÀÌ KEY¿¡ ´ëÇØ¼­´Â ¼ø¼­°¡ Áß¿ä½Ã µÉ¼ö ÀÖ´Â °ÍÀÌ µÇ¾î¾ß ÇÒ °ÍÀÌ´Ù. 
KEY¶ó´Â ÀÌ¸§Àº fixµÈ ¾î¶°ÇÑ °ªÀ» »ç¿ëÇØ¾ß ÇÒ °ÍÀÌ´Ù.
±× µÚ¿¡ ¿À´Â ¿©·¯°¡ÁöÀÇ structureµéÀÌ µû¶ó ¿Ã °ÍÀÌ°í, 
ÀÌ µû¶ó¿À´Â °ÍµéÀ» ¾îµð¿¡ ÀúÀåÀ» ÇØµÎ¾î¾ß ÇÏ´Âµ¥ , ¾î¶»°Ô ÀúÀåÀ» ÇÒ °ÍÀÌ°í,
ÀÌ ÀúÀåµÈ °ª¿¡ ´ëÇØ¼­ ¾î¶² °ªÀÌ µé¾î¿Ã¶§ , ¾î¶°ÇÑ Ã³¸®¸¦ ÇØ¼­ DURATIONµîÀ» ¾î¶»°Ô ±¸ÇØ¼­ ³õÀ»¼ö ÀÖ´ÂÁö¿¡ ´ëÇÑ 
¼öÇà ¼ø¼­¸¦ ³ª¿­ÇØ¾ß ÇÒ °ÍÀÌ´Ù. 

stKEY
ÀÏ´Ü , stAAA , stBBB , stCCC 3°³ÀÇ °ÍµéÀÌ ÀÖ´Ù°í ÇÏÀÚ. ¸ðµÎ key´Â Time/IMSI ¶ó°í Á¤ÀÇ¸¦ ÇÏÀÚ.
ÀÌ ¾È¿¡´Â ¾î¶² °ÍµéÀÌ µé¾î°¥¼ö ÀÖ´ÂÁö´Â structure¿¡ ³ÖÀ¸¸é µÉ °ÍÀ¸·Î º¸ÀÌ¸ç


¸Ç ¾ÕÀÇ °Í¿¡ ´ëÇØ¼­ ³ª¿À´Â CodeµéÀÌ °¢±â ´Ù¸¥ CodeµéÀ» »ý¼º½ÃÄÑÁØ´Ù.

KEY typedef struct _stTimeIMSI {
	int	type;
	IMSI
	iCallTime
	iCallMTime
} stTimeIMSI;

HASH typedef struct _stExample {
	HKEY  stTimeIMSI	sKEY;
	/* ÀÌ °¢°¢¿¡ ´ëÇØ¼­ Table·Î ¸¸µé¾î¾ßÇÑ´Ù. */
	HDATA stAAA sAAA;
	HDATA stBBB sBBB;
	HDATA stCCC sCCC;
	stComplex sDDD;
} stExample;
- HASH¿¡ ´ëÇØ¼­´Â ÀÏ¹ÝÀûÀ¸·Î »ç¿ëÇÒ¼ö ÀÖ°Ô ÀÌ¹Ì Á¤ÀÇ°¡ µÇ¾îÁ®ÀÖ´Ù. ÀÌ°ÍÀ» À§ÇØ¼­ Æ¯È­ ½ÃÅ³ ÇÊ¿ä´Â ¾ø´Ù°í º»´Ù.
´ë½Å ÀÌ HASH¶ó°í ¾²¿©Áö¸é , ¾Æ´Ï´Ù.. ¸¸µé¾îÁø KEYµé·Î hash initÀ» ÇÒ¼ö ÀÖ°Ô ¸¸µé¾îÁÖ°í init¾È¿¡ ÀÌ°ÍµéÀ» ³Ö¾îÁÖ´Â °ÍµîÀ» ÀÚµ¿À¸·Î ¸¸µé¸é ÆíÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù.
ÄÚµå¿¡¼­ ³ª¿À´Â °ÍµéÀ» Á¤ÀÇÇØ µÎ¾î¾ß ÇÒ °ÍÀÌ´Ù. 
- Threshold¸¦ Ãß°¡ÇÏ´Â °ÍÀ» °°ÀÌ °í·Á¸¦ ÇØ¾ß ÇÒ °ÍÀÌ´Ù.   
	Åë°è¸¦ ³½ °ªÀÌ³ª ±×·± °ªµéÀ» °¡Áö°í , threshold¸¦ ±¸ÇÏ´Â °ÍÀ¸·Î ÇÑ´Ù. 
	±× ¾È¿¡ threshold¸¦ ±¸ÇÏ´Â ¹ýÀ» °°ÀÌ ³Ö¾îµÎ´Â °ÍÀÌ ¸ÂÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. 
	º¸Åë ±¸ÇÏ´Â °ªÀ¸·Î´Â Æò±ÕÀÌ¶õµçÁö¿¡ +- ¿ÀÂ÷¸¦ µÎ¾î Ç¥ÇöÇÏ´Â °ÍÀÌ °¡Àå ÁÁÀº ¹æ¹ýÀÌ¶ó°í »ý°¢ÇÑ´Ù.



/* À§ÀÇ stExample¾ÈÀÇ °Íµé°ú ÀÌ ¾ÈÀÇ °Íµé·Î¸¸ ¸¸µé¼ö ÀÖ¾î¾ß ÇÑ´Ù. 
** ±×·¡¾ß , Á¤ÀÇµÇ¾î µé¾î¿Â °ªÀ» °¡Áö°í ÀÌ·± Ã³¸®¸¦ ÇÒ¼ö ÀÖ´Ù.  
*/
NEWTABLE typedef struct _stComplex {
	DURATION ATime(sAAA.CreateTime,sBBB.CreateTime) - [threshold¸¦ Ç¥ÇöÇÏ´Â ¾î¶² °Í]  ;
	DURATION BTime(sBBB.CreateTime,sCCC.CreateTime);
	AVERAGE  CPktCntSec(sAAA.PKTCnt,ATime);
	AVERAGE  CPktSizeSec(sAAA.pktsize,sBBB.pktcnt);
} stComplex;

¶ó°í °¡Á¤À» ÇÏÀÚ. ÀÌ°Ç ¾È¿¡ ³»ºÎÀûÀ¸·Î °¡Áö°í ÀÖ´Â °ÍÀÌÁö¸¸, ÀÌ°ÍÀº ³»ºÎÀûÀ¸·Î¸¸ »ç¿ëÇÑ´Ù°í °¡Á¤ÇÒ¼ö ÀÖ´Â°Ô ÀÖ¾î¾ß ÇÒ °ÍÀÌ´Ù.
Ç¥Çö ¹æ½ÄÀ» ¼­¼úÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù. 

ÀÌ¸§ Á¤ÇÔ::::
STG_HASH_KEY
STG_COMBINATION_TABLE 


======================================================================================
====   Section    3 : NTAM¿¡¼­ ¾î¶»°Ô ±¸ÇöÀÌ µÇ¾îÁ®¾ß ÇÏ¸ç, ÀÌ°ÍÀ» À§ÇØ¼­´Â ¾î¶² °ÍµéÀ» ÁØºñÇÒ¼ö ÀÖ´ÂÁö?
======================================================================================
NTAM¿¡¼­´Â È£ °ü·Ã ¸Þ½ÃÁö°¡ ¿Ã °ÍÀÌ°í, ÀÏ´Ü ¸ðµç °ÍÀº ¸Þ½ÃÁö typeÀ» º¸°í ÇØ´ç Ã³¸®¸¦ ÇØ¾ß ÇÑ´Ù.
TLVÀÌµç TVÀÌµçÀ» Á¤ÇØ¼­ ÇÏ´Â °ÍÀ¸·Î ÇÏ°í,  msg typeÀ» º¸°í ÇØ´ç strucuture·Î °ªÀ» ÀÐÀºÈÄ¿¡ ±× Ã³¸®¸¦ ÇÏ°Ô µÈ´Ù.
±âº»ÀûÀ¸·Î ¾Æ·¡ ¹Ø¿¡ ÀÖ´Â STG_HASH , STG_KEYµîÀº ±âº»ÀûÀ¸·Î ÇÑ°³ ÀÌ»ó¾¿Àº Á¤ÀÇµÇ¾îÁ®¾ß NTAMÀÇ Code¸¦ ¸¸µé¼ö ÀÖÀ» °ÍÀÌ´Ù. (NTAM¿¡¼­´Â Àû¾îµµ ÇÑ°³ÀÌ»ó¾¿Àº ÀÌ °ªµéÀÌ ÇÊ¿äÇÏ±â ¶§¹®ÀÌ´Ù.) 

1. È£ Ã³¸®  (µû·Î ¸¸µé°Å³ª ¿À´Â °Í¿¡ ´ëÇÑ Ã³¸®¸¦ ÇÏ°Å³ª ¹®Á¦°¡ µÇÁö ¾Ê´Â´Ù.)
È£ ¸Þ½ÃÁö ¶Ç´Â LOG ¸Þ½ÃÁö¸¦ ÇÑ °÷¿¡¼­ ¹Þ´Â´Ù.  ¹ÞÀºÈÄ¿¡ typeÀ» º¸°í  HASH¸¦ ¸¸µå´Â ÀÏÀ» ¼öÇàÇÑ´Ù.
HASH´Â ÇöÀç´Â IP -> IMSI , IMSI -> TMSI , TMSI -> TimeÀ» Ã£´Â´Ù.
main : hash_init()À» ¼öÇàÇØ¾ß ÇÒ °ÍÀÌ°í
hash_init : À§ÀÇ 3°³ÀÇ hash¿¡ ´ëÇÑ Ã³¸®¸¦ ÇØ¾ß ÇÒ °ÍÀÌ´Ù.  (ÀÌ¸§µéÀ» Á¤ÇüÈ­ ÇÒ ÇÊ¿ä°¡ ÀÖÀ» °ÍÀÌ´Ù. ÁÖ·Î typedefÀÇ ÀÌ¸§À» ±âÁØÀ¸·Î prefix Ãß°¡)
	Ã³À½ ºÎºÐ¿¡ msg¸¦ ±¸ºÐÇÏ±â À§ÇÑ msg_typeÀ» ²À Á¤ÀÇÇØ ÁÖ¾î¾ß ÇÒ °ÍÀÌ´Ù. ¾Æ´Ï¸é ¹ÞÀº °ªÁß¿¡ msg_typeÀÌ ÀÖ¾îµµ »ó°ü¾ø´Ù. 
#define IMSI_STR_MAX 		16
	[[ U32	msg_type; ]]
STG_HASH_UNIT  typedef struct _stIP_IMSI {
	STG_HASH_KEY	U32	IP;
	STG_HASH_DATA	U8	IMSI[IMSI_STR_MAX];
} stIP_IMSI;
ÀÌ·¸°Ô ¼±¾ðÇÏ¿© È£´Â µé¾î¿Í¾ß ÇÑ´Ù. ÀÌ·± °Íµé¿¡ µû¶ó HASH¸¦ ±¸¼ºÇÏ°Ô µÉ °ÍÀÌ¸ç, 
HASHÀÇ DATA ºÎºÐ¿¡´Â  TIME / IMSI / TMSI / IP / timerid ¸¦ ¸ðµÎ ³Ö¾îÁÖ´Â °ÍÀÌ ÀÖ¾î¾ß ÇÒ °ÍÀÌ´Ù.
STG_HASH_DATA ·Î Á¤ÀÇ¸¦ ÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù.  (1°³¸¸ ÀÖ¾î¾ß°ÚÁÒ)!

È£°¡ ¿À´õ¶óµµ key¿Í data°¡ ±¸º°ÀÌ µÇ¿©Á®¾ß ÇÒ °ÍÀÌ´Ù.  º¸³»ÁÖ´Â typeÀ» º¸°í ÀÌ·± Ã³¸®¸¦ ÇØ¾ßÇÏ´Âµ¥ , ÀÌ°ÍÀº Èûµé °ÍÀ¸·Î º¸ÀÎ´Ù. 
KEY·Î Á¤ÀÇµÈ ºÎºÐ°ú DATA·Î Á¤ÀÇµÈ ºÎºÐÀ» ³ª´©¾î ÁÖ¾î¾ß ÇÒ °ÍÀÌ´Ù. 

Á¤ÇÔ : À§¿¡¼­ºÎÅÍ 2°³¾¿À» ¹­¾î¼­ Ã³¸®ÇÏ´Â °ÍÀ¸·Î ÇÑ´Ù. 


2. È£°¡ ¿Ï·áµÇ¸é LOG·Î µé¾î¿À´Â msgµé¿¡ ´ëÇØ¼­ key(TIME / TMSI / IMSI / IP)¸¦ ´Þ¾ÆÁÖ´Â ÀÏÀ» ÇØ¾ß ÇÑ´Ù. 
Áú¹® : ±âº» call È£°¡ ¾ø´Â °Íµéµµ ÀÌ·¸°Ô ÀúÀåÀ» Çß´Ù°¡ ÇÊ¿äÇÑ °ªµéÀ» ²¨³»´Â°ÍÀÌ ÀÇ¹Ì°¡ ÀÖ´ÂÁö...
callµµ ¾ø´Âµ¥ ÀÌ·± °ÍÀ» ¾îµð¿¡ ÀúÀåÀ» ÇØ¾ß ÇÒÁö... ÀúÀåÀº ¾î¶°ÇÑ ¸ð¾çÀÇ ¾îµð¿¡ Á¤ÀÇÇÏ´Â °ÍÀÌ ¸ÂÀ»Áö??
½ÇÁ¦·Î ¸¹ÀÌ µé¾î¿À´Â È£Áß¿¡¼­ ¾îµð¿¡ ´Þ¾Æ¾ßÇÒ Áö¸¦ Á¤ÇØ¾ß ÇÏ¸ç, ÀÌ·± °ÍÀ» STG_HASH_MAIN_UNITµîÀ¸·Î Á¤ÀÇÇØ¾ß ÇÏ´Â °ÍÀÌ ¾Æ´Ñ°¡ ÇÑ´Ù.
STG_HASH_MAIN_UNIT·Î Á¤ÀÇÇÏ´Â °Í¿¡´Â char *Protocol[MAX] °°Àº °ÍÀ» °¡Áö°í type definition value¿Í [] °ªÀ» µ¿ÀÏÇÏ°Ô ÇÏ¿© »ç¿ëÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. 
¾î¶² °ÍµéÀÌ µé¾î¿ÃÁö¸¦ ¸ð¸£±â ¶§¹®ÀÌ´Ù. defineÀº ÇÏ°í Áß°£¿¡ ¾È ¾²´Â °ÍµéÀº ¾î¶»°Ô ÇÒ °ÍÀÎ°¡? 
(¸Þ¸ð¸®ÀÇ ³¶ºñ¶§¹®¿¡ ¹ß»ýÇÏ´Â °ÍÀ¸·Î ÀÏ´ÜÀº ±¸ÇöÀ» ÇÏ°í ÀÌ·± ºÎºÐÀº º¯°æÇÏ´Â °Íµµ ÇÑ°¡Áö ¹æ¹ýÀÌ¶ó°í »ý°¢µÈ´Ù.)
- ÀúÀåÇÏ´Â ³»¿ë¿¡ ºñÇØ¼­ »ç¿ëÇÏÁö ¾Ê´Â °ªÀÌ ¸¹Áö ¾ÊÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. MAX°ªÀ» µû·Î Á¤ÀÇÇÏ°Ô ÇÏ¿©¾ß ÇÒ °ÍÀÌ´Ù. MAX¸¸Å­¸¸ »ý±â°Ô ÇÏ±â ¶§¹®ÀÌ´Ù.  
- char cnt[]µµ ³Ö¾î¼­ ¸î°³°¡ ¹Ýº¹ÀûÀ¸·Î ¿Ô´ÂÁöµµ °°ÀÌ Ç¥ÇöÀ» ÇÏ¸é ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. 

STG_HASH_MAIN_UNIT typedef struct  _stKEY {  /// ÀÌ°Í¿¡ ´ëÇÑ Ã£´Â Key´Â ¹«¾ùÀ¸·Î ÇÒ °ÍÀÎ°¡? Ã³À½ 2°³¸¦ Key·Î ¼³Á¤ÇÒ °ÍÀÎ°¡? 
	TIME
	TMSI
} stKEY; 

STG_DATA typedef struct  _stDATA {  /// ÀÌ°Í¿¡ ´ëÇÑ Ã£´Â Key´Â ¹«¾ùÀ¸·Î ÇÒ °ÍÀÎ°¡? Ã³À½ 2°³¸¦ Key·Î ¼³Á¤ÇÒ °ÍÀÎ°¡? 
	IMSI
	IP
	stPPP *PPP; 			/* stPPP °¡ µé¾î¿À¸é ¿©±â¿¡ ´Þ¾ÆÁÖ°Ô ÇÑ´Ù. */ ÀÌ¹Ì ´Þ·ÁÀÖ´ÂÁö´Â nullÀÎÁö È®ÀÎÇÏ¸é µÈ´Ù.
							/// ¿©·¯°³¸¦ ´Þ°³ ÇÏ°í ½ÍÀ¸¸é array¸¦ »ç¿ëÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.  
							/// ÇØ´ç sessionÀº ³¡³ª¾ß ¿Â´Ù. timeoutÀÌ µÇ°Å³ª, ½ÇÁ¦·Î ³¡³ª°Å³ª. 
	*GN
	*IUPS
	*WAP
	stComplex	AA;
} stDATA;
µîÀÇ ¿©·¯°¡ÁöÀÇ Service°ü·Ãµµ ºÙÀ»¼ö ÀÖ´Ù.


°í·ÁÇØ º¼ ºÎºÐ : keyÀÇ Á¶ÇÕ - ÀÏ·Ä·Î µÈ ¼øÂ÷ÀûÀÎ dependancy°¡ ÀÖÀ¸¸é µü ÁÁÀºµ¥ , ±×·¸Áö ¾ÊÀº °ÍÀÌ ¹ß»ýÇßÀ» °æ¿ì¿¡ ´ëÇÑ Ã³¸®´Â ¾î¶»°Ô???
LOG¿¡ µé¾î¿À´Â key´Â ¼ø¼­°¡ ÀÖ°í ¸Ç µÚÀÇ KeyºÎÅÍ ÀÖ´ÂÁö¸¦ checkÇÏ¿© Ã³¸®ÇÏ´Â ¹æ½ÄÀ» µÎ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. (¼±Çü±¸Á¶)
ÀÌ·± °ÍÀÌ 2°³°¡ ÀÖ´Ù°í °¡Á¤À» ÇØº¸ÀÚ. (»ý±æ¼ö´Â ÀÖ´Â°¡?)   TIME / TMSI / IMSI or MIN / IP ÀÎ °æ¿ì¿¡ IMSI³ª MINÀÎÁö¸¦ ±¸º°ÇÏ´Â °ÍÀÌ ¾îµò°¡ µé¾î°¡ ÁÖ¾î¾ß ÇÒ °ÍÀÌ°í ,
MIN or IMSI¿¡ µû¶ó¼­ Ã³¸®°¡ ´Þ¶óÁ®¾ß ÇÒ °ÍÀÌ´Ù. 
unionÀ» ÀÌ¿ëÇÒ¼ö ÀÖÀ¸¸é ÇØ°áÀÌ µÉ °ÍÀÎ°¡? unionÀ» ÀÌ¿ëÇÏµå¶óµµ typeÀ» ³Ö¾îÁÖ´Â °ÍÀÌ ÀÖ¾î¾ß ÇÒÅÙµ¥, typeÀ» º¸°í unionÃ³¸®¸¦ ÇÏ´Â°Ô ¸ÂÀ» °ÍÀÎ°¡?
(½ÇÁ¦·Î IMSI ¿Í MINÀº ±×³É ¹øÈ£·Î Ã³¸®ÇÏ¸é µÇ¹Ç·Î º° ¹®Á¦´Â ¾ÈµÈ´Ù. ±× ¿ÜÀÇ ´Ù¸¥ typeÀÌ ÀÖÀ»¶§ ¹®Á¦°¡ µÉ¼ö ÀÖ´Ù´Â °ÍÀÌ´Ù.)


== 2006.05.17 == 
STG_HASH_KEY_Combination typedef struct _stKEy {
	TIME		// °Å±â´Â structureÀÌ¾îµµ »ó°ü¾øÀÌ ÇØ¾ß ÇÒ °ÍÀÌ´Ù.  
	TMSI
	IMSI
	IP
} stKey;·Î ÇØ¼­ »ç¿ëÇÒ °ÍÀÌ´Ù. ÀÌ°ÍÀ» À§Çì¼­ ºÎÅÍ 2°³´Â mainÀ¸·Î µÇ¾î¼­ ¸ðµç µé¾î¿À´Â LOGµéÀÇ Ã¹¹øÂ°µéÀ» ÀúÀåÀ» ÇØµÎ¾î¾ßÇÏ¸ç, (¼±ÇüÀûÀÎ °Í¸¸À» °í·ÁÇÑ´Ù. !!!°íÁ¤!!!)
ºñ¼±ÇüÀÎ °ÍÀº ´Ù¸¥ systemÀÏ °æ¿ì´Â ÀÌ°ÍµéÀ» ´Ù¸£°Ô Á¤ÀÇÇÏ¿© »õ·Î¿î process¸¦ ¸¸µé¾î »ç¿ëÇÏ°Ô µÉ  °ÍÀÌ´Ù. 
³ª¸ÓÁö ½Öµé¿¡ ´ëÇØ¼­´Â HASH¸¦ ¸¸µé¾îÁÖ´Â °ÍÀÌ´Ù. 
STG_HASH_DATA¶ó°í ÇÏ´Â ºÎºÐ¿¡´Â À§Ã³·³ STG_DATAÃ³·³ ¼±¾ðÇÏÁö ¸»°í { char cnt[]; char *log[]; } ÇÏ¿© »ç¿ëÇÏ°Ô µÉ °ÍÀÌ´Ù. (log¿¡´Â allocÀ» ÇÏ¿© Á¤º¸¸¦ ´Þ¾ÆÁØ´Ù.)
Áß°£¿¡ Á×Àº °ÍÀ» °í·ÁÇØ¾ß ÇÏ´ÂÁö¿¡ ´ëÇØ¼­´Â ÃßÈÄ °í·Á... (µû·Î »ý°¢ÇØµµ µÇ´Â ºÎºÐÀÌ¶ó°í »ý°¢ÇÑ´Ù.)

ÀÚµ¿ °á°ú ³ª¿Í¾ß ÇÏ´Â °Íµé :
-°¢ 2°³¾¿ÀÇ hash Á¤ÀÇ  (hash initÀ» ÀÚµ¿¼öÇà) - hash_init¿¡¼­  +HASH_INIT+
-°¢ 2°³¾¿ÀÇ stuructureÀÚµ¿ Á¤ÀÇ 
-strucuture¸¶´Ù GRP °ª°ú TYPE°ª Á¤ÀÇ
	2±ú¾¿ Â¥°ÔÁø structure (È£)  (1 + ?)
	LOG structure 			(2 + ?) - Nested·Î Ã³À½¿¡´Â key structure¸¦ Æ÷ÇÔÇØ¾ß ÇÑ´Ù.  
-size ÀÚµ¿ Á¤ÀÇ
-type¿¡ µû¸¥ Ã³¸® (key , data¸¦ ±¸ºÐÇØ¼­ ÀúÀå)  - switchÃ³¸® ºÎºÐ  (È£ Ã³¸®   ¹× LOGÀúÀå  ÇØ´çµÉ¶§´Â NewTableÀ» À§ÇÑ processingÀ»)
	hash_add , timer Ã³¸® 


perl ÇÁ·Î±×·¡¹Ö ÀÛ¼º¹ý : ¸ÕÀú .h¸¦ ÀÐ¾î¼­ ÇÊ¿äÇÑ °ªµéÀ» %hashµîÀ¸·Î ¸ðµÎ ¸¸µé¾îµÐ´Ù. ±×ÈÄ¿¡ ±× °ªµéÀ» °¡Áö°í programÀ» ÇÏ´Â ¹æ¹ýÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù.
flatÀº PC¿¡¼­¸¸ »ç¿ë ; InsertDB(AAA *a) ·Î ÇÏ°í ÇÔ¼ö ¾È¿¡¼­ flat_AAA *b; b = (flat_AAA *) a; ÇØ¼­ »ç¿ëÇÏ°Ô ÇÒ °ÍÀÌ´Ù. flatÀº ¿©±â¼­ »ç¿ëÇÏ´Â °ÍÀÌ ÀüºÎÀÌ´Ù. (flat...h¸¦ include) 

Memory ³¶ºñ¸¦ ¼±ÅÃ : ÇÁ·Î±×·¥ÀÌ ½±°Ô ÇÏÀÚ.... ¸Þ¸ð¸®´Â  ³ªÁß¿¡ ´õ Àß Â¥´Â »ç¶÷¿¡°Ô ¸Ã°ÜµÎÀÚ.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

3. LOG msg¸¦ Áß½ÉÀ¸·Î Ã³¸®ÇÏ´Â ´Ü°è
À§ÀÇ NEWTABLEÀÌ¶ó°í Á¤ÀÇµÇ´Â ºÎºÐµé¿¡ ´ëÇÑ Ã³¸®¸¦ ÇÒ¼ö ÀÖµµ·Ï 
ÄÚµå°¡ ÀÚµ¿À¸·Î Ãß°¡ µÇ¾îÁ®¾ß ÇÑ´Ù.  NEWTABLE¿¡ ´ëÇÑ AA¿¡ ´ëÇÑ Ã³¸®¸¦ ÇÒ¼ö ÀÖµµ·Ï Ãß°¡µÇ¾îÁ®¾ß ÇÒ °ÍÀÌ´Ù.


ÄÚµåÀÇ ¸ð¾çÀº ¾î¶³ °ÍÀÎ°¡? 
main(){
	hashinit();
	process();
}
process(){
	switch(msg-type){
		TYPE_DEFINE:
			type_process();
			break;
	}
}
type_process(){
	hash¿¡ »ðÀÔ
	or
	STG_DATA¿¡ »ðÀÔÈÄ¿¡  3°úÁ¤À» Ã³¸®
	or 
	DB¿¡ ¹Ù·Î »ðÀÔ (ÀÌ¶§´Â flat.. »ç¿ë) 
}

test.shÀ» ¸¸µé¾î¼­ ½ÃÇèÀ» ÀÚµ¿À¸·Î ¼öÇàÇÒ¼ö ÀÖ°Ô ¸¸µé¾îÁÖ¾úÀ½.


/*****************************
* 2006.05.25 - À§ÀÇ Section 3±îÁö ¸ðµÎ ¿Ï·á 
======================================================================================
<< ÇÁ·Î¼¼¼­º° ÀÚµ¿È­ Ã³¸® ÇØ¾ßÇÒ ºÎºÐ¿¡ ´ëÇÑ ¸®½ºÆ® >>
======================================================================================

[ CO_LOG ]
1. Hasho, TimerN init ºÎºÐ ÀÚµ¿È­
   - Hasho, TimerN Àº ¸ðµÎ 3°³¾¿ »ç¿ëÇÑ´Ù.(Key: TMSI, IMSI, IP)
>>> OK

2. Corelation ¸Þ¼¼¸¦ ¹Þ¾Æ Command ¿¡ ÀÇÇØ ADD,DEL,ALL DELÀ» ±¸ºÐÇÏ±â À§ÇØ¼­´Â
   ¸Þ¼¼ÁöÀÇ Ã³À½¿¡ Command ÇÊµå°¡ ¿Í¾ßÇÒ °Í °°´Ù.
   (°¢ Corelation ¸Þ¼¼Áöº°·Î ¾ÕÀÇ Corelation ÇÊµå°¡ ¼­·Î ´Ù¸£±â ¶§¹®)
>>> uiCommand¶ó´Â °ÍÀÌ °¢ È£Ã³¸®¿¡ Ãß°¡°¡ µË´Ï´Ù. (±âÁ¸¿¡´Â ¾ø´ø °ÍÀÓ) - NTAF¿¡¼­ ¿Ã·ÁÁÙ ¶§ ÀÌºÎºÐÀ» ³Ö¾îÁÖ¾î¾ßÇÕ´Ï´Ù.

3. Corelation ¸Þ¼¼ÁöÀÏ °æ¿ì Ã³¸® ¼ø¼­ (uiCommand·Î ±¸ºÐ : add , del , all_del)
   1) °¢ Corelation È£ ¸Þ¼¼Áöº° Hasho, TimerN Add
      - ¸Þ¼¼Áö¸¦ ¹Þ¾Æ Decoding ÇÑ´Ù.
      - ¸Þ¼¼Áö¸¦ Hasho Å×ÀÌºíÀÇ µ¥ÀÌÅ¸ ±¸Á¶¿¡ ¸Â°Ô »ý¼ºÇÑ´Ù.
        (Hasho Å×ÀÌºíÀÇ µ¥ÀÌÅ¸ ºÎºÐ¿¡ ³Ö±â À§ÇØ)
      - Hasho, TimerN Å×ÀÌºí¿¡ Add ÇÑ´Ù.
      - °¢°¢ÀÇ Hasho Å×ÀÌºíÀ» µ¿±âÈ­ÇÑ´Ù.
        - ¸Þ¼¼Áö¿¡¼­ Hasho Key¿¡ ÇØ´çÇÏ´Â µ¥ÀÌÅ¸¸¦ °¡Áö°í °¢°¢ÀÇ Hasho Å×ÀÌºíÀ» 
          °Ë»öÇÏ¿© µ¥ÀÌÅ¸¸¦ Á¶ÇÕÇÑ´Ù.
        - Á¶ÇÕÇÑ µ¥ÀÌÅ¸¸¦ °¢°¢ÀÇ Hasho Å×ÀÌºí¿¡ UpdateÇÑ´Ù.
>>> Add½Ã ÀÖ´Â µ¥ÀÌÅÍÀÇ °æ¿ì¿¡ , ÀÖ´Â ºÎºÐÀ» Áö¿öÁÖ°í »õ·Î¿î °ÍÀ¸·Î »ðÀÔÇÑ´Ù.
>>> Áö¿ì´Â °Í¿¡¼­´Â DELETE or ALL DELÁß¿¡ ¾î¶² °ÍÀ¸·Î ÇÒÁö Á¤ÇØ¾ß ÇÒ °ÍÀÌ´Ù. 
>>>   (Áö¿ï ¶§ Áö±Ý±îÁöÀÇ °ªÀº DB¿¡ ÀúÀå Ã³¸®)

   2) °¢ Corelation È£ ¸Þ¼¼Áöº° Hasho, TimerN Delete
      - ¸Þ¼¼Áö¸¦ ¹Þ¾Æ Decoding ÇÑ´Ù.
      - ¸Þ¼¼Áö¿¡ Hasho Key °ªÀ» °¡Áö°í Delete ÇÑ´Ù.
        (¿©±â¼­´Â ½ÇÁ¦·Î Hasho Å×ÀÌºíÀÇ Node¸¦ »èÁ¦ÇÏ´Â°Ô ¾Æ´Ï¶ó TimerId¸¦ UpdateÇÑ´Ù.) 
>>> stg file¾ÈÀÇ STG_HASH_DEL_TIMEOUT °ª ÂüÁ¶
>>> delete_timeoutÀÌ³ª ½ÇÁ¦·Î delete°¡ µÇ¾î¾ß ÇÏ´Â °æ¿ì¿¡ À§ÀÇ TMSI °°Àº °æ¿ì Set_Combination_Once() ¸¦ ¼öÇàÇÑ´Ù.
   
   3)  °¢ Corelation È£ ¸Þ¼¼Áöº° Hasho, TimerN ALL Delete
      - ¸Þ¼¼Áö¸¦ ¹Þ¾Æ Decoding ÇÑ´Ù.
      - ¸Þ¼¼Áö¸¦ Hasho Å×ÀÌºíÀÇ µ¥ÀÌÅ¸ ±¸Á¶¿¡ ¸Â°Ô »ý¼ºÇÑ´Ù.
        (Hasho Å×ÀÌºíÀÇ µ¥ÀÌÅ¸ ºÎºÐ¿¡ ³Ö±â À§ÇØ)
      - ¸Þ¼¼Áö¿¡ Hasho Key°ªÀ» °¡Áö°í Hasho µ¥ÀÌÅ¸(Corelation Á¤º¸)¸¦ °¡Á®¿Â´Ù.
      - µ¥ÀÌÅ¸¿¡ ÀÖ´Â °ªÀ¸·Î °¢°¢ÀÇ Hasho Å×ÀÌºíÀ» »èÁ¦ÇÑ´Ù.
        (¿©±â¼­´Â ½ÇÁ¦·Î Hasho Å×ÀÌºíÀÇ Node¸¦ »èÁ¦ÇÏ´Â°Ô ¾Æ´Ï¶ó TimerId¸¦ UpdateÇÑ´Ù.)
>>> stg file¾ÈÀÇ STG_HASH_DEL_TIMEOUT °ª ÂüÁ¶
>>> delete_timeoutÀÌ³ª ½ÇÁ¦·Î delete°¡ µÇ¾î¾ß ÇÏ´Â °æ¿ì¿¡ À§ÀÇ TMSI °°Àº °æ¿ì Set_Combination_Once() ¸¦ ¼öÇàÇÑ´Ù

4. Log ¸Þ¼¼ÁöÀÏ °æ¿ì Ã³¸® ¼ø¼­
   1) Log ¸Þ¼¼Áö¿¡¼­ Corelation Á¤º¸¸¦ Decoding ÇÑ´Ù.
   2) Log ¸Þ¼¼Áö¿¡ ÀÖ´Â Hasho Å×ÀÌºíÀÇ Key °ªÀ» °¡Áö°í ÇØ´ç Hasho Å×ÀÌºí¿¡¼­ 
      ³ª¸ÓÁö Corelation Á¤º¸¸¦ °¡Á®¿Â´Ù.
>>> ¸øÃ£¾ÒÀ» °æ¿ì ??  °í·Á
   3) LOG ¸Þ¼¼Áö¸¦ TMSI Hasho Å×ÀÌºíÀÇ µ¥ÀÌÅ¸ ÇÊµå¿¡ ÀúÀåÇÑ´Ù. 
>>> ²À TMSI°¡ ¾Æ´Ò¼öµµ ÀÖ°í STG_HASH_KEY·Î Á¤ÀÇµÇ´Â ¸Ç Ã³À½ member¿¡ ´Þ¸®°Ô µË´Ï´Ù.
      (malloc¸¦ ÀÌ¿ë, Pointer¸¦ ÀúÀåÇÑ´Ù.)
   4) Log ¸Þ¼¼Áö¿¡¼­ Corelation Á¤º¸¸¦ Encoding ÇÑ´Ù.
>>> accumulate °ü·Ã Ã³¸®¸¦ ¼öÇàÇÑ´Ù. (Á¤ÀÇµÈ ÇÔ¼ö¸¦ call ÇÏ°Ô µÊ)
   5) ¼öÁ¤µÈ Corelation Á¤º¸ + Log ¸Þ¼¼Áö Body ¸¦ ¸Þ¼¼ÁöÅ¥·Î º¸³½´Ù.
>>> µé¾î¿Â °ª¿¡ CorelationÁ¤º¸¸¸ ¼öÁ¤ÇØ¼­ ±×´ë·Î DBÀúÀåÀ» À§ÇÑ msgQ¿¡ º¸³½´Ù.

5. Å¸ÀÌ¸Ó¿¡ invokde ½Ã È£ÃâµÇ´Â ÇÔ¼ö¿¡ ´ëÇÑ ÀÚµ¿È­
   1) Hasho Å×ÀÌºíÀÌ TMIS ÀÏ °æ¿ì
      - key¿¡ ÇØ´çÇÏ´Â µ¥ÀÌÅ¸¿¡¼­ Log ¸Þ¼¼Áö¿¡ °ü·ÃµÈ ÇÊµåµéÀÇ µ¥ÀÌÅ¸¸¦ free ÇØÁØ´Ù.
      - Combi_NewTable¿¡ ´ëÇÑ Ã³¸®
      - Key¿¡ ÇØ´çÇÏ´Â Node¸¦ »èÁ¦ÇÑ´Ù.
   2) Hasho Å×ÀÌºíÀÌ IMSI, IP ÀÏ °æ¿ì
      - Key¿¡ ÇØ´çÇÏ´Â Node¸¦ »èÁ¦ÇÑ´Ù.

6. ÇÁ·Î¼¼¼­ Ã³À½ ½ÃÀÛ½Ã °¢°¢ÀÇ hasho Å×ÀÌºí µ¥ÀÌÅ¸¿¡ Å¸ÀÌ¸Ó¸¦ ´Þ¾ÆÁÖ´Â ºÎºÐ¿¡ ´ëÇÑ 
   ÀÚµ¿È­

7. ÇöÀç structg ¿¡ Àû¿ëµÈ ±¸Á¶Ã¼¸¦ °¡Áö°í ±âÁ¸ ÇÁ·Î±×·¥À» º¯°æ.
   ÀÏ´Ü º¯°æÇÑ ÇÁ·Î¼¼¼­°¡ Á¦´ë·Î µ¿ÀÛÇÏ´ÂÁö Å×½ºÆ® ÇÑ ÈÄ ¼Ò½º¸¦ º¸¸é¼­ ÀÚµ¿È­ Ã³¸®
   ±¸¼º¿¡ ¸Â°Ô º¯°æÇØ¾ß ÇÒ °Í °°´Ù.
>>> °°ÀÌ ÇÕ½Ã´ç!!!

   
[ M_LOG ]
1.      MID Ãß°¡½Ã switch ¹®¿¡ MID Ã³¸®ÇÔ¼ö È£Ãâ¿¡ ´ëÇÑ ÀÚµ¿È­
2. MID Ãß°¡½Ã MIDº° Ã³¸®ÇÔ¼ö »ý¼º¿¡ ´ëÇÑ ÀÚµ¿È­
>>> OK ? Ãß°¡ÇØ¾ß ÇÒ ºÎºÐÀ¸·Î »ý°¢µË´Ï´Ù.
 

>>> Ãß°¡ : CREATEµÈ ºÎºÐ¿¡ ´ëÇÑ È°¿ëÀº?
>>> ÀÌ°ÍÀ» À§ÇØ¼­ NTAF °³¹ßÀÚµéÀº DB¿¡¼­ QueryÇØ¾ß ÇÏ´Â »ç¶÷°ú ÀÌ¸§¿¡ ´ëÇÑ »óÀÇ¸¦ ÇÏ¿© 
stg file¿¡ ³»¿ëÀ» ¹Ý¿µ½ÃÄÑ¾ß ÇÕ´Ï´Ù.

stg¸¦ ¸¸µé ¶§ ÁÖÀÇ »çÇ×
-typedef struct 
	typedef struct _st_IUPS_Sess_Cnt {   À¸·Î ½ÃÀÛ { À» ´ÙÀ½ÁÙ¿¡ ¾²´Â °ÍÀº ¾ÈµÊ
	typedef struct .. { ¡¦ }  AAA ; À¸·Î ÇÒ ¶§ AAAÀÇ À¯ÀÇÁ¡
		COMBI_  Àº combinationÇÏ±â À§ÇÑ prefix
        TIM_  Àº DB Table¿¡ ¹Ù·Î µé¾î°¥ StructureÀÇ prefix
        CFLOW´Â ¾ÆÁ÷ ¾î¶»°Ô ÇÒÁö ¹ÌÁ¤ 
-ÁÖ¼® (¾Æ·¡ 2°¡Áö¸¸ Çã¿ë)
       /*  */ ÁÖ¼® Çã¿ëµÊ
       ///< ÁÖ¼® Çã¿ëµÊ
-Short Name
	%...% Àº DB¿¡¼­ »ç¿ëÇÒ Short NameÀ» À§ÇÑ key wordÀÔ´Ï´Ù. ÁÖ¼®µî¾È¿¡ ÀÌ ¹®ÀÚÀÇ »ç¿ëÀº »ï°¡¹Ù¶ø´Ï´Ù.
	ex) MTIME       utime;  %MTM%   /**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */   
        utime´ë½Å¿¡ MTMÀ» »ç¿ëÇÔ. (DB°ü·Ã¿¡¼­¸¸ »ç¿ëµÊ) 
        %..% ÀÌ ¾ø´Ù¸é ±×³É ÀÚ½ÅÀÇ ÀÌ¸§À» ±×´ë·Î »ç¿ëÇÔ.
	$shortremoveprefix·Î Á¤ÀÇµÈ ÀÌ¸§Àº ¶ó´Â °ÍÀº »ç¿ëÇÏÁö ¸¶¼¼¿ä..
		ÇöÀç´Â "TTTTT__" ·Î Á¤ÀÇ¸¦ Çß½À´Ï´Ù.
-#define ¡¦   Àº typedef struct ¡¦ { }¡¦;  ¿ÜºÎ¿¡ ¾µ °Í {} ¾È¿¡ ³ÖÁö ¸»¾ÆÁÖ¼¼¿ä.. Ã³¸® ¸ø ÇÒ °Ì´Ï´Ù
-»ç¿ë¼ø¼­
       Ã³À½ : ÀÏ¹ÝÀûÀ¸·Î typedef struct¡¦  
       µÎºÐÂ° : STG_COMBINATION_TABLE typedef struct ¡¦
       ¼¼¹øÂ° : STG_HASH_KEY typedef struct ¡¦   (ÀÌ°Ç ²À ÇÑ °³¸¸ Á¸ÀçÇØ¾ß ÇÕ´Ï´Ù.)

ÀÌ·±°Ç ¾ÈµË´Ï´Ù.
- STG_HASH_KEY ·Î ¼±¾ÈµÈ structure¸¦ À§¿¡¼­ nestedµÇ´Â ¸ð¾çÀ¸·Î ºÒ·¯ ¾²°í ½ÍÀº °æ¿ì
- ±×³É À§¿¡ ´Ù¸¥ ÀÌ¸§À¸·Î ÇÑ °³ ´õ ¼±¾ðÇØ¼­ ¾²¼¼¿ä.. (Á¦ ´É·ÂºÎÁ·À¸·Î ±×³É ±×·¸°Ô ÇØ°á)
- #if 0 ·Î ¸·¾ÆÁÖ¾îµµ Àú´Â ±×·± °Í ¸ð¸¨´Ï´Ù. ±×³É ´Ù Ã³¸®ÇØ¹ö¸². #if 0·Î ¸·´Â °ÍÀº ±×³É °ú°¨È÷ »èÁ¦ÇØÁÖ¼¼¿ä
 
Âü°í : structg  ¸¦ checkoutÇÏ¿© userfile.stg¸¦ ÂüÁ¶ÇÏ½Ã¸é DB°ü·Ã±îÁö ¸ðµÎ Ã³¸®°¡ µÇ´Â °Í ÀÔ´Ï´Ù.
structg.plÀ» ¼öÁ¤ÇÏ½Å ºÎºÐÀº ±× ¾ÈÀÇ test.sh¸¦ µ¹·Á¼­ comformance test¸¦ ¼öÇàÇÏ½Ã±â ¹Ù¶ø´Ï´Ù.


<< Ãß°¡ ÇØ¾ß ÇÒ list  >>
union ÀÇ Ã³¸® : TIM_¿¡¼­´Â unionÀÎ °ÍÀº ¹«½ÃÇÏ°í ³Ñ¾î°¡¾ß ÇÑ´Ù. (flat ±×³É typeÀÌ ¾ø´Â °ÍÀ¸·Î)
¼±¾ð¿¡ ÁÖÀÇ¸¦ ÁÖ¾î Ã³¸®¸¦ ÇØ¾ß ÇÑ´Ù. ¾î¶² °ÍÀÌ ¼±ÅÃÀÌ µÇ¾î¾ß ÇÒÁö¸¦ fixÇØ¾ß ÇÑ´Ù. 
Àû¿ë°Ç : 2Â÷±îÁö Àû¿ëÀ» ÇØ¾ß ÇÑ´Ù. 
- Iub¿¡ ´ëÇØ¼­ ¾î¶»°Ô ±¸ÇöÀ» ÇØ¾ß ÇÏ´ÂÁö ±Ô°ÝÀ» Àß Ã£¾Æº¸¾Æ¾ß  ÇÒ °ÍÀÌ´Ù.

2006.05.28
<< Á¤¸® >>
- ÀüÃ¼ÀûÀ¸·Î ÁÖ¼®À» ´Ü´Ù. (°¡´ÉÇÏ¸é ¼Ò½º¿¡ Æ÷ÇÔµÇµµ·ÏÇÑ´Ù.) 
	¼Ò½º ¾È¿¡¼­ ±¸ÇöµÇ°í ÀÖ´Â °Í¿¡ ´ëÇØ¼­ ¹®¼­µµ °°ÀÌ ¸¸µé¾îÁÖ¾î¾ß ÇÒ °ÍÀÌ´Ù. 
	¼Ò½º Â÷ÈÄ ´Ù¸¥ ¿ëÀ¸·Î ÀÌ¿ëÇÒ¼ö ÀÖ°Ô Á¤¸® ÇÊ¿ä. 
	perl package ÇÊ¿ä (pm : perl module)
- structgÀÇ Á¦¾à Á¶°ÇµéÀ» ³ª¿­ÇÑ´Ù.
	»ç¿ëÇØ¾ß ÇÏ´Â ¹®¹ýµé¿¡ ´ëÇØ¼­ ³ª¿­ÇÏ°í, ¿Ü±¹ÀÇ ¹®¼­¿Í °°ÀÌ compiler¿Í °°Àº »ç¿ë¹ýÀ» Á¤ÀÇÇÑ´Ù.
	vi¿¡¼­ stg, stc¿¡ ´ëÇÑ Ã³¸®¸¦ ÇÒ¼ö ÀÖµµ·Ï editingÀ» ÆíÇÏ°Ô ÇÏ´Â ¹æ¹ýÀ» ¸ð»öÇÑ´Ù. (vi or vim or ±×¹ÛÀÇ editor)
	°³¹ß ¹®¼­ ±ÔÄ¢À» doc°ú ¿¬°èÇÏ´Â ¹æ¹ýÀ» ¸ð»öÇÏÀÚ.  code¸¦ Â¥¸é ÀÚµ¿À¸·Î »ý¼ºÀÌ µÇ´Â ¸ð¾çÀ¸·Î ÇßÀ¸¸é ÇÑ´Ù.
	ex) /* */ ¾ÈÀÇ ³»¿ëÀÌ°í ¹¹°í ¿©±â¼­´Â °°ÀÌ Ãë±ÞÀ» ÇÑ´Ù.  /* ¾È¿¡µµ ¹®¹ý¿¡ Æ²¸®Áö ¾Ê°Ô ÀÛ¼ºÀ» ÇØ¾ß ÇÒ °ÍÀÌ´Ù. keywordµéÀ» Àý´ë »ç¿ëÇÏÁö ¸»°Í */


- PT¹®¼­¸¦ ÀÛ¼ºÇÑ´Ù. (½Ã°£ ¹«Áö °É¸®´Â ±º¸¸.. ´ëÃæ ½á³õ°í ´ëÃæ ³»¿ë Ã¤¿ì°í ³ªÁß¿¡ Ãß¸®µçÁö ÇÏ´Â°Ô °¡Àå ÁÁÀ»Áöµµ)
	ÀüÃ¼ ±¸Á¶¿¡ ´ëÇÑ ÀåÁ¡
	³ªÁß¿¡ ´Ù½Ã readableÇÑ ÀåÁ¡
	dynamicº¸´Ù staticÀÇ ÀåÁ¡ -> º¸¾È, ¼Óµµ , ¿ì¸®°¡ dynamicÇÑ °ÍÀÌ ÇÊ¿äÇÏÁö ¾ÊÀ½, º¸±â ½±°í ÀÌÇØ ½¬¿ò 
	È¿À²¿¡ ´ëÇÑ ºñ±³
- ETT tool°ú ºñ±³¸¦ ÇÑ´Ù.
- Data MininingÀ» À§ÇÑ ³»¿ëÀ» °ËÅäÇÏ°í ¾î¶»°Ô Àû¿ëÇÒÁö¿¡ ´ëÇØ¼­ »ý°¢À» ÇÑ´Ù.
- ´Ù¸¥ ºÁ¾ß ÇÒ Ã¥µéÀ» Á¤ÇØ¾ß ÇÑ´Ù. Áö¼ÓÀûÀ¸·Î º¼ °Í  (¿µ¹®À¸·Î º¸°í , ¿µ¹®À¸·Î ÀÛ¼ºÇÏ°í : ¾ÈµÇ¸é ±×¸²À¸·Î)


- ÃÖ°úÀåÀÇ Àû¿ëÀ» °è¼Ó ÁöÄÑº»´Ù. ( ÇöÀç M_LOG ¼öÇàÁß) 
- NTAF ÀÏºÎ ÀÚµ¿È­ °í·Á 
	unionÀº ³ªÁß¿¡ Ã³¸®ÇÏ´Â °ÍÀ¸·Î ÇÑ´Ù.  ³ªÁß¿¡ NTAF protocol°ü·Ã °³¹ß¿¡¼­ »ç¿ëÇÒ¼öµµ ÀÖÀ» °ÍÀÌ´Ù.
- ±â´É Ãß°¡
	- multi stg stc¸¦ ¸¸µç´Ù.			* perl
	threshold ¼³Á¤						* perl + stc 
	success , fail¿¡ ´ëÇÑ ³»¿ëµµ ¾Ë·ÁÁÖ¼¼¿ä. (Åë°è °ªÀÏ»Ó : Å©°Ô ¹®Á¦µÇÁö ¾ÊÀ½.)  * new
	½ÇÆÐµîÀÇ Code¸¦ º¸°í Ã³¸® Ã¼°è ¸¶·Ã (fault Ãß°¡½Ã) * new
	defineµî¿¡ ¼±¾ðµÈ °ªÀ» º¸°í ÇØ´ç stringÀ» Âï¾îÁÖ´Â Ã³¸® * perl + (perl¾ÈÀÇ prt¸¦ stc·Î º¯Çü)
	ÀÚµ¿À¸·Î STAT±îÁö ±¸ÇÏ´Â °ÍÀ» ¸¸µéÀÚ , 5ºÐ  timer¸¸ stc¿¡ Á¤ÀÇÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. COMBI_STAT ¶ó°í ÁöÀ¸¸é µÇÁö ¾ÊÀ»±î ÇÕ´Ï´Ù. (reserved word)  *stc
		µû·Î ÀÚ·áµéÀ» ¸ðµÎ ¸ð¾ÆµÎ´Â ºÎºÐÀÌ ÇÊ¿äÇÏ´Ù. thread¸¦ ¶ç¿ö¼­ 5ºÐ¸¶´Ù ¼öÇàÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. timer°¡ ¶ß¸é list¸¦ ¶¼¾î³»¾î Ã³¸®ÇÏ°í,
		»õ·Î µé¾î¿À´Â °ÍµéÀº »õ·Î¿î °Í¿¡ ´Þ¾ÆµÎ´Â °ÍÀÌ´Ù. (hashoÀÇ linkedlist¸¦ ÀÌ¿ëÇÏ¸é ½±°Ô ±¸Çö ÇÒ¼ö ÀÖÀ» °ÍÀ¸·Î º¸ÀÎ¤§.) 
		list¸¦ µÚÁö¸é¼­ ÇÏ´Â°Ô ÁÁÀ»±î? ¾Æ´Ï¸é , ±×³É ÇÑ°³ÇÑÃ¤ Ã³¸®¸¦ ÇÏ¸é¼­ ÇÏ´Â °ÍÀÌ ÁÁÀ»±î?  5ºÐ Åë°è¸¦ Ã³¸®ÇÏ°Ô µÇ¸é ²À ÀúÀåÇÏ¸é¼­ ÇÒ ÇÊ¿ä°¡ ¾ø´Ù°í º¸ÀÎ´Ù.
		¿Ö³Ä¸é, ÀúÀåÀ» ÇÏ¿©µµ ±× °ªµéÀÌ ÀÏºÎÀÏ °¡´É¼ºÀÌ ÀÖ±â¶§¹®¿¡ Åë°è¸¦ ³½´Ù´Â °ÍÀÌ ¹®Á¦°¡ ÀÖ´Ù°í º¸¿©Áø´Ù.   (5ºÐ¸¶´Ù STAT¸¦ DB¿¡ ¾²´Â °ÍÀ¸·Î ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. )
		³ªÁß¿¡ 5ºÐ Æò±ÕÀ» ³»µçÁö ÇÒ¶§´Â ÃÖÁ¾ ÀúÀåµÈ °ªÀ» °¡Áö°í ÀÖ¾î¾ß ÇÏ¸ç, ³ª´©´Â °ª°ú ³ª´©¾î¾ß ÇÏ´Â °ªÀ» ¾î¶»°Ô °è»êÇÒÁö¸¦ °í·ÁÇØ º¸¾Æ¾ß ÇÒ °ÍÀÌ´Ù.
	NTAM¿¡¼­ÀÇ raw packet ÀúÀå ¹× ´Ù½Ã loadingÀÛ¾÷ ¼öÇà  *stc
	µé¾î¿À´Â °ª ¸¶´ÙÀÇ comination °ªÀ» ±¸ÇØÁÖ´Â ºÎºÐ 	* perl : ºÐ·ù¿ä
	structure¾È¿¡¼­ÀÇ ½Ã°£À» ±¸ÇØÁÖ´Â ºÎºÐ (NTAF¿¡¼­ ÇØµµ ÀüÇô ¹®Á¦°¡ ¾øÀ½. - ÀÏ´Ü ÀÌ°ÍÀº ÇÏÁö ¾Ê±â·Î ÇÏ´Â °ÍÀÌ ¸ÂÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. ) * ¿¬±â
	GUIÀÇ queryµî¿¡µµ È®ÀåÇÏ´Â °ÍÀ» »ý°¢ÇØº¸Àå!! 	* perl + stj
	- Ãß°¡ÀûÀ¸·Î QueryµîÀÇ ±â´ÉÀ» »ìÇÊ¶§´Â "KTF ETL ±â´É »ç¾ç¼­"¸¦ ÂüÁ¶ÇÏ±â ¹Ù¶õ´Ù. 
	- Ãß°¡ÀûÀ¸·Î ±â´ÉÀÌ ÇÊ¿äÇÒ °æ¿ì¿¡´Â "CoSort ±³À°ÀÚ·á"¸¦ ÂüÁ¶ÇÏ±â ¹Ù¶õ´Ù.


- Protocol ÀÚµ¿È­
ÀÏ´Ü protocolµé¿¡´Â Å©°Ô 2°¡Áö·Î ³ª´©¾îÁø´Ù. text¿Í binary·Î µÈ °ÍÀÌ´Ù.
ÀÏ´Ü binary¿¡ ´ëÇØ¼­ ÀÌ¾ß±â¸¦ ÇÏ¸é 3GPP , 3GPP2¿¡¼­ »ç¿ëÇÏ´Â ¿©·¯°¡ÁöÀÇ typeµéÀÌ Á¸ÀçÇÑ´Ù.
binary - ASN.1À¸·Î µÈ °Í°ú ,   M , TLV, TV , V µîÀ¸·Î ³ª´©¾îÁö´Â °æ¿ì

ÀÏ¹ÝÀûÀÎ °æ¿ì¸¦ ÇÑ¹ø ¿¹·Î µé¾îº¸ÀÚ. 3GPP¿¡¼­´Â º¸ÅëÀÇ °æ¿ì MsgµéÀ» Á¤ÀÇÇÏ¸ç , ÀÌ ¾È¿¡´Â Information Elements(IE)¶ó´Â °ÍµéÀÌ µé¾î°¡ÀÖ´Ù.
MSGµéÀÌ ¿ÔÀ»¶§ ºÐ¼®À» ÇÒ ÇÊ¿ä°¡ ÀÖÀ¸¸é, ÀÌ ºÐ¼®ÇÑ °á°ú°¡ ¾î¶»°Ô ½ÖÀÌ µÇ¸é ÀÌ °ªÀ» ¾î¶»°Ô È°¿ëÇÒÁö¿¡ ´ëÇÑ Á¤ÇüÈ­¸¦ ½ÃÄÑ¾ß ÇÑ´Ù.
Mendatory , Conditional , Optional ÀÌ ÀÖÀ¸¸ç , mendatory¿Í ±× ³ª¸ÓÁö¸¸À» ³ª´©¸é µÈ´Ù.
IE¿¡´Â bit operationÀÌ Ãß°¡µÇ¾îÁ®¾ß ÇÑ´Ù.
REQ message¾È¿¡´Â ¸ðµÎ ³ª¿­À» ÇÑ´Ù. °¢ memberµé¸¶´Ù °ªÀÌ ÀÖ´ÂÁö ¾ø´ÂÁö´Â ¹º°¡¸¦ °¡Áö°í Ç¥ÇöÀ» ÇØ¾ß ÇÑ´Ù. (-1 or 0 ÀÌ ¾ø´Â °ÍÀ¸·Î)
¾î¶² msgÀÎÁö¸¦ ±¸ºÐÇÏ´Â °ÍÀº ¾Õ¿¡ typeÀ» µÎ¾î¼­ ³ªÅ¸³»ÁÖ¾î¾ß ÇÑ´Ù. 
±×Áß¿¡¼­ °¡Àå Å« size°¡ ¾ó¸¶ÀÎÁö¸¦ ±¸ÇÏ±â À§ÇØ¼­ unionÀ» »ç¿ëÇÏ¸é µÈ´Ù. (½ÇÁ¦·Î stg¾È¿¡¼­ unionÀ¸·Î ¼±¾ðÇÒ °ÍÀº ¾ø´Ù.)
(unionÀ¸·Î Ã³¸®¸¦ ÇÒ°æ¿ì ¾ó¸¶³ª ¿ÃÁö ¸ð¸£¹Ç·Î linked list·Î ¸¸µé´øÁö ÇÒ±î ÇÏ´Âµ¥ ÀÌ °æ¿ì´Â °á±¹ TLV¸¦ ´Ù½Ã ¹Ýº¹ÇÏ´Â °ÍÀ¸¹Ç·Î ´Þ¶óÁö´Â°Ô ÇÏ³ªµµ ¾ø´Â °ÍÀ¸·Î º¸ÀÎ´Ù. staticÀÌ ¾Æ´Ñ linked list°°ÀÌ °¡º¯ÀûÀÎ °ÍÀº ÀÇ¹Ì°¡ ¾ø´Â °ÍÀ¸·Î º¸ÀÎ´Ù. : unionÀ» »ç¿ëÇÏ¸é ¹¹°¡ ¿ÃÁö ¾Ë¼ö°¡ ¾ø´Ù.)
Á¦ÇÑ »çÇ× : IE°¡ ¿©·¯°³ ³ª¿Ã¶§ ¸î°³±îÁö ³ª¿À´ÂÁö ³ª¿­À» ÇØ¾ß ÇÏ´ÂÁö? recursionÀ¸·Î IEµéÀÌ³ª msgµéÀ» È£ÃâÇÏ´Â °æ¿ì°¡ ¾ø¾î¾ß ÇÒ °ÍÀÌ´Ù.
REQ MSG¶ó°í Á¤ÀÇ¸¦ ÇÏÀÚ. ºÐ¼®À» ÇÏ¿© ±× ¾ÈÀÇ °ª¿¡ ³Ö´Â ºÎºÐÀ» stg·Î ¸¸µé¼ö´Â ÀÖÀ»°ÍÀÌ´Ù. ±× ¾È¿¡¼­ ¾î¶² °ªÀ» °¡Á®´Ù ½á¾ß ÇÏ´ÂÁö´Â ÇÁ·ÎÅäÄÝÀ» °³¹ßÇÏ´Â »ç¶÷¸¶´Ù ´Ù¸¦ °ÍÀ¸·Î º¸ÀÎ´Ù.  cnt¶ó´Â °Íµµ ÇÊ¿äÇÑÁö »ý°¢ÇØº¸ÀÚ.

Bit operation Ã³¸® 
(endian°ü·ÃµÈ ½±°Ô ´Ù·ç´Â ¸ð¾çÀ¸·Î Ã³¸® ÇÊ¿ä)
SIP¿Í °°Àº Text Ã³¸®  : TIDY
(lex yaccÀ» »ç¿ëÇØ¾ß ÇÏ´ÂÁö GNU source¸¦ ÂüÁ¶ÇØ¾ßÇÏ´ÂÁö? µî¿¡ ´ëÇØ¼­ °í·Á¸¦ ÇÏ¿©¾ß ÇÑ´Ù.)

2006.06.09
- 5ºÐ Åë°è ÀÚµ¿È­
ÇöÀç ¾²´Â ½Ã°£ ±âÁØÀ¸·Î 5ºÐ Åë°è¸¦ ¼öÇàÇÑ´Ù.  5ºÐ¸¶´Ù ±ú¾î³ª¼­ STAT¶ó´Â Ã³¸®¸¦ ¼öÇàÇÑ´Ù.
ENDTIME À¸·Î Åë°è¸¦³»´Â °ÍÀÌ¸Â´Ù°íµé ÀÌ¾ß±â ÇÏÁö¸¸, »ç¾÷ÀÚ¿¡ ´Þ¶óÁú¼ö ÀÖÀ» °ÍÀ¸·Î , 
¾î´À ±âÁØÀ¸·Î ±¸ÇÏ´ÂÁö´Â ³ªÁß¿¡ ³ª¿­ÇÒ¼ö ÀÖ°Ô ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.  ±×°ÍÀº pl°ú stc¿¡¼­ °¡º¯ÀûÀ¸·Î ¸¸µé¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.

2006.06.10
- protocol  ÀÚµ¿È­¸¦ À§ÇÑ ºÐ¼®
RANAP°¡ °¡Àå º¹ÀâÇÑ ¸ð¾çÀÌ¶ó°í ¿©±â°í ÀÖÀ¸¸ç . °¢°¢¿¡ ´ëÇÑ ±âÁØÀ» ÇÑ¹ø ¸¶·ÃÀ» ÇØº¸¾Æ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù.
protocol¿¡´Â ¿©·¯°¡Áö°¡ ÀÖÀ¸¸ç ,  binary Áß¿¡¼­´Â GTP°¡ ÀÖÀ»¼ö ÀÖÀ¸¸ç, ±×¹Û¿¡ UDP , TCPµîÀÌ  RFC¿¡¼­ ±âº»ÀûÀ¸·Î »ç¿ëµÇ¾îÁö´Â °ÍµéÀÌ´Ù.
GTP¿¡ ´ëÇØ¼­ ÇÁ·ÎÅäÄÝ ºÐ¼®ÇÑ ³»¿ëÀ» ±â¼úÇÏ±â·Î ÇÏ°Ú´Ù.

-  GTP ºÐ¼®
TEID¿Í IP¸¦ Áß½ÉÀ¸·Î ºÐ¼®À» ÇÏ¸ç ,typeÀº binaryÀÌ´Ù.  
Ã³À½¿¡ packetÀÌ ¿À¸é UDP Æ¯Á¤ Æ÷Æ®¸¦ »ç¿ëÇÏ¿© ¿À°Ô µÉ °ÍÀÌ°í.
±× ¾ÈÀÇ ¸Þ½ÃÁö typeÀ» º¸°í ¾î¶² ¸Þ½ÃÁöÀÎÁö¸¦ ¾Ë¸ç, ±× ¾ÈÀÇ IE´Â °¢°¢ÀÇ type , [length] , value·Î °ªµéÀ» ¾Ë¼ö ÀÖ´Ù. 
ÀÌ·¯ÇÑ °ÍµéÀº tableÀ» ÇÑ°³ ¸¸µé¾î type , length , value¸¦ ³Ö°ÔÇÏ¿© µ¹¸®¸é ÇØ´ç °ªÀÌ ³ª¿Ã °ÍÀ¸·Î º¸ÀÌ¸ç, 
req , respµîÀÇ ¸Þ½ÃÁö¿¡¼­ mendatory,optionalµîÀ¸·Î Ç¥ÇöÇÑ °Íµé±îÁö Ç¥ÇöÀ»ÇÏ¿© ³ÖÀ»¼ö ÀÖÀ» °ÍÀ¸·Î º¸ÀÎ´Ù.
mandatoryÀÎ °æ¿ì¿¡´Â ÀÌ°ÍÀ» ÇÏÁö ¾ÊÀ¸¸é ¿¡·¯¸¦ ¹ß»ýÇÏ´Â ÄÚµåµîµµ °³¹ßÇÒ¼ö ÀÖÁö ¾ÊÀ»±î »ý°¢À» ÇÑ´Ù.
STG_PROTOCOL_IE #type:0x01-len:..-value:..#  typedef struct _st_IE_TEID {
	U8 teid[MAX_TEID];
} IE_TEID;
STG_PROTOCOL_A typedef struct _st_GTPC_REQ {
	IE_TEID uiTEID; %M% 		/**< mandatory teid */
	IE_IP  	uiIP;   %O% 		/**< optional ip */
} PROT_GTPC_REQ;

- GMM ºÐ¼®
GMM°°Àº °æ¿ì´Â mandatory°°Àº °æ¿ì¿¡ value¸¸ Á¸ÀçÇÏ´Â °æ¿ì°¡ ¹ß»ýÇÑ´Ù.
ÀÌ°æ¿ì¸¸ GTP¿¡ Ãß°¡¸¦ ÇØÁÖ¸é µÉ °ÍÀ¸·Î º¸ÀÌ¸ç,  GMMÀÇ ¼Ò½º¸¦ Á» ´õ º¸¾ÆÁÖ¾î¾ß ÇÒ °ÍÀÌ´Ù.
GMMÀÇ °æ¿ì ¾ó¸¶³ª ÀÏ¹ÝÀûÀÏ¼ö ÀÖ´ÂÁö¿¡ ´ëÇØ¼­ °í·Á¸¦ ÇØº¸¾Æ¾ß ÇÒ °ÍÀÌ´Ù. (¼³¸íÀ» µé¾î¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù. loop¸¦ 2¹øµ¹¸é ¸ðµç°Ô µÈ´Ù°í ÇÏ´Âµ¥, ÀÌ ÇÁ·ÎÅäÄÝ¿¡¼­¸¸ µÇ´Â °ÍÀº ¾Æ´ÑÁö?  ÀÌ°ÍÀÌ °¡´ÉÇÏ·Á¸é ¾î¶² ÇÁ·ÎÅäÄÝµé¿¡ ´ëÇØ¼­ ¾î¶»°Ô Àû¿ëÀ» ÇØ¾ß ÇÏ´ÂÁö?  protocol tableÀÌ ÁÖ¾îÁø´Ù¸é ¾î¶»°Ô ´ëÀÔÀ» ÇÏ¸é µÇ´Â ÀÏ¹ÝÀûÀÎ ¹æ½ÄÀº ¹«¾ùÀÎÁö? )
idea´Â ÁÁÀº °ÍÀ¸·Î º¸¿©Áü
FieldFormat¿¡¼­ Á¤ÀÇÇÑ °Í´ë·Î °ªµéÀ» ³Ö¾îÁÖ¸é µÇ¸ç, ÀÌ ³Ö¾îÁÖ´Â °ÍµéÀº ÇØ´ç structure¾ÈÀÇ memberµé·Î ±¸¼ºÀÌ µÇ¾îÁ®¾ß ÇÑ´Ù.
DetailFieldµµ FieldFormat°ú °°Àº ¹æ½ÄÀÌ¸ç , Á» ´Ù¸¥ Ã³¸®¸¦ ÇÏ´Â °ÍÀ¸·Î GTPC¿¡ È°¿ëÇÒ¼ö ÀÖ´Â ºÎºÐÀ¸·Î º¸¿©Áø´Ù.
°ËÅä ÀÇ°ß : GMM01 ¶ó´Â ºÎºÐÀº ¶¼¾î³»¾ß ÇÒ °ÍÀ¸·Î º¸¿©Áö¸ç, ±× °ªÀÌ ¾îµð¸¦ °¡¸®Å°´ÂÁö ÇÏ´Â °ÍÀ» ³ªÅ¸³»´Â ÀÇ°ßÀº ÁÁÀº °ÍÀ¸·Î º¸¿©Áü.
	ÀÌ ¸ð¾çÀ» ±×³É ½á¾ß ÇÒ °ÍÀÎÁö, ¾Æ´Ï¸é ´Ù¸¥ ¸ð¾çÀ¸·Î typedef°°Àº ¾È¿¡ ³ªÅ¸³»¾î Ã³¸®¸¦ ÇØ¾ß ÇÏ´ÂÁö¿¡ ´ëÇØ¼­ ÀÇ°ßÀ» ³ª´©¾î¾ß ÇÒ °ÍÀ¸·Î º¸ÀÔ´Ï´Ù.  ´Ù¸¥ ¸ð¾çÀ¸·Î ³ªÅ¸³½´Ù´Â °ÍÀº typedef¾È¿¡ Á¤º¸¸¦ ¹Ì¸® ÁÀÇÇÏ¸é ¿µÈ£¾¾°¡ Â§ ¸ð¾çÀÇ ÄÚµå·Î ³ª¿À´Â °ÍÀÎµ¥ , ¼­·»ðÀÔµÇ´Â °ÍµéÀÌ Á¤ÇüÈ­°¡ µÇ¾î Ã´ÇÏ¸é Å¹ µÚ¾î ³ª¿À°Ô ÇØ¾ß ÇÑ´Ù´Â °Í ÀÔ´Ï´Ù.
	°¢ req , respµîÀÇ structure¸¶´Ù ÇÔ¼ö¸¦ ¹Ì¸® ¸¸µé¾î ¾ÈÀ» Ã¤¿ì°Ô ÇÏ´Â °Íµµ ÇÑ°¡Áö ¹æ¹ýÀÏ¼ö ÀÖÀ» °ÍÀÌ´Ù. (VC++ programÃ³·³)
Áú¹® : ¿©±â¼­´Â RAB¿¡¼­ Ã³·³ ¿©·¯°³¸¦ ¼±¾ðÇØ¾ß ÇÏ´Â °Í¿¡ ´ëÇØ¼­´Â Ã³¸®¸¦ Ãß°¡ÇØÁÖ¾î¾ß ÇÒ °Í °°Àºµ¥... ¿©±â´Â RABlist¸¦³Ö´Â °Í °°Àº Ã³¸®´Â µé¾î°¡Áö ¾ÊÀº °ÍÀ¸·Î º¸ÀÔ´Ï´Ù.
ÀÇ°ß 2 : GMMÀ» ¸¸µå´Â °úÁ¤¿¡¼­ GTP´Â ±×³É µÇ°Ô ÇÒ¼ö ÀÖÀ» °ÍÀ¸·Î º¸¿©Áø´Ù. »ý°¢À» Àß ÇÏ¸é ÁÁÀº Çü½ÄÀÌ ¸¸µé¾îÁú¼ö ÀÖÀ» °ÍÀ¸·Î º¸¿©Áø´Ù.
ÀÇ°ß3 : IE¸¦ Á¤ÀÇ´Â µû·Î ÇØÁÖ¾î¾ß ÇÒ °ÍÀÌ´Ù. IE¸¦ Á¤ÀÇÇÏ´Â ¸ð¾çÀ» Á¤ÀÇÇÏ°í , req °°Àº ¸Þ½ÃÁö¸¦ Á¤ÀÇÇÏ´Â ¸ð¾çÀ» µû·Î Á¤ÀÇ¸¦ ÇÏ¿©¾ß ÇÒ °ÍÀÌ´Ù. 3GPP , 3GPP2¿¡¼­´Â ¸ðµç °ÍÀÌ IE¿Í MSG·Î ±¸ºÐÀ» ÇÏ¿© Ã³¸®ÇÏ±â ¶§¹®ÀÌ´Ù. 
(binary TLV TV type¿¡ ´ëÇÑ Ã³¸®ÀÇ ¿Ï¼º)

±×¾È¿¡ hash , timer¸¦ °áÇÕÇÏ´Â °ÍÀº ¿¹Á¦·Î º¸¿©ÁÖ¾î Â¥¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.
WAP1.0 È°¿ë ¹æ¾È °ËÅä ¿ä (2.0Àº httpÇü½ÄÀÌÁö¸¸, 1.0Àº binary¶ó°í ÇÔ)


- TIDY¿¡ ´ëÇÑ ºÐ¼®À» ÇØ¾ß ÇÒ °ÍÀÌ´Ù. ¹®¼­¸¦ º¸°í parsingÀ» ¾îµð±îÁö ¾î´À Á¤µµ·Î ÇØÁÖ´ÂÁö¸¦ ¾Ë¾Æ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù.

2006.06.13 È­
STAT¿¡¼­ Àß¸ø Â§ ºÎºÐÀÌ ÀÖ´Ù. (ÃÖ°úÀåÀ¸·ÎºÎÅÍ) 
Accumulate¿Í Once¸¦ STATÀ» µû·Î ¸¸µé¾î¾ß ÇÒ °ÍÀÌ´Ù.

2006.06.14 ¼ö : eosoft°ü·Ã ÀÚµ¿È­ Á¤ÀÇ ¸¶¹«¸®
IuPS°ü·Ã LOG, CF°¡ º¸¿©¾ß ÇÏ¸ç
COMBINATOION , STAT¿¡ ´ëÇÑ °¡¶ó µ¥ÀÌÅÍ·Î ¿Ï¼ºÀ» ÇÏ¿©¾ß ÇÑ´Ù. (È­¸é¿¡ º¸¿©¾ß ÇÔ)
ÀÌ°ÍµéÀ» ¼öÇàÇÒ¼ö ÀÖ´Â ¹®¼­°¡ ¸¸µé¾îÁ®¾ß ÇÏ¸ç, ÀÌ°Í´ë·Î ÇßÀ»¶§ Á¦´ë·Î µÇ¾î¾ß ÇÑ´Ù.
(½Ã°£À» º¯°æÇØ¼­ º¸³»ÁÖ´Â °ÍÀ» ÅëÇÑ log°¡ ½×ÀÌ´Â °Í¿¡ ´ëÇÑ Ã³¸® : °¡´ÉÇÏ´Ù¸é)
- ÀÌ ÇÁ·Î±×·¥Àº Àü½ÂÈÆ¾¾°¡ ¸¸µé¾îÁÖ¾î¾ß ÇÔ.

[[2006.07.25 ]]
*TEXT Parsing Ã³¸® 

*³²Àº ÀÏ 
: prefix´ë·Î ¹Ù²Ù¾î fileÀÚµ¿À¸·Î ¸¸µé±â (ÀÌ°Ç ÇÊ¿äÇÏ¸é ¼ÕÀ¸·Î ÇØÁÖ¾îµµ µÈ´Ù.)
	- ÃßÈÄ GLOBALÀ» °¡Áö°í Ã³¸®ÇÏ´Â ¸ð¾çÀ¸·Î ¸¸µé¶§ ÀÚµ¿È­¸¦ ÇÏ±â·Î ÇÑ´Ù.
: prefixºÙ¿©¼­ ´Ù¸¥ library·Î ¸¸µé¾îÁÖ°í , ÇØ´ç makefileÀ» ¸¸µé¾îÁÖ±â
°á°ú - ÀÏ´Ü ´ë·« Ã³¸® , LOG_KUN¾ÈÀÇ REQ/RESP´Â ÇÑ°³·Î ÇÕÄ§ (³»ºÎÀûÀ¸·Î prefix¸¦ °¡Áö°Ô ÇÔ)
	- µÎ°³ °¢°¢¿¡ ´ëÇØ¼­ ¼öÇà ÀßµÊ (stc.sh)

*¶Ç ÀÏ 
: BREW , WIPI¿¡ ´ëÇÑ Ã³¸® Ãß°¡ (LOGÀÇ ÀÏºÎ¸¦ Àâ°í , ¿À´Â ¸ð¾çÀ» º¸°í Ã³¸® Ãß°¡ : binary ºÎºÐ Ã³¸® Ãß°¡)
ME,KUN : µÎ°³´Â ÇÑ°³·Î º¸°í Ã³¸® (³»¿ëÀÌ °ÅÀÇ À¯»çÇÏ´Ù°íÇÔ) 
RTSP(VOD) : text parser·Î °¡´É  
- onlineÀ» ÇÏ±â À§ÇÑ applicationÀ» download
BREW download(TEXT) :  text parser·Î °¡´É
WIPI download(TEXT) :  text parser·Î °¡´É
- ¸í·É : download¸¦ ¹ÞÀº applicationÀ» ¼öÇàÇÏ¸ç Åë½ÅÇÏ´Â ³»¿ë
BREW online (binary) : binary»õ·Î Â¥¾ß ÇÔ.
WIPI online (binary) : binary»õ·Î Â¥¾ß ÇÔ.
RTP , RTCP(Jitter)

BODY -> Call -> Page
binary parsing

[[2006.07.26]] ¼³°è 
#defineÀÇ À§Ä¡¿¡ »ó°ü¾øÀÌ Ã³¸® µÇ¾îÁü

<TAG_DEFINE_START:RespCode>
#define	RespCode_A_Type  1 /* */
#define	RespCode_B_Type  2
#define	RespCode_C_Type  3
<TAG_DEFINE_END:RespCode>
    U32		<RespCode>RespCode;	
    ÀÌ·± ½ÄÀÇ Ã³¸®°¡ °¡´ÉÇÏ°Ô ÇÔ.

<TAG_DEFINE_START:AAA>
#define ....
.... (¼ýÀÚ¸¸)
<TAG_DEFINE_END:AAA>
·Î Á¤ÀÇÇÏ°í 
U32 <TAG_DEFINE:AAA>TTT;   ÀÌ·± ½ÄÀ¸·Î »ç¿ëÇÏ¸é ÁÖ¼®µîÀÌ ÀÚµ¿À¸·Î ºÙ´Â´Ù.

body¸¦ ´Ù·ç´Â ºÎºÐÀ» ´Ù·ç¾î¾ß ÇÏ³ª. HREFÀÇ °æ¿ì´Â Menu¸íÀ» ±¸ÇÏ´Âµ¥¸¸ »ç¿ëµÇ¾îÁö¸ç
IMG¿Í SOUNDµî¿¡ ´ëÇØ¼­¸¸ ´Ù·ç¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.
IMG , SOUND°¡ ¿ÔÀ»¶§ ÀÌ°ÍÀº arrary¿¡ Âß Àû¾îµÎ´Â°Ô °¡Àå ÁÁÀº ¹æ¹ýÀÌ´Ù. (MAX¸¦ µÎ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. 20°³ Á¤µµ)
IMG, SOUNDÀÌµç ¹¹µç PAGEÀÇ °³³äÀ» À§ÇÑ °ÍÀ¸·Î 

1. MENU ¸í : hashg¸¦ »ç¿ëÇÑ´Ù. size¿Í stringÀ» ºñ±³ÇÑ´Ù.  ³»¿ëÀº ¸ðµÎ ³Ö´Â °ÍÀ¸·Î ÇÑ´Ù.
	<a href...>()</a> ()¾ÈÀÇ ³»¿ë¸¸À» ÀúÀåÇÏ±â·Î ÇÑ´Ù.
2. IMG,SOUND(PAGE) : <img src= µîÀÇ ¸ð¾çÀ» »Ì¾Æ³½´Ù.  
	Àý´ë Path URLÀ» »©³»¾ß ÇÑ´Ù. (¾ÕÀÇ http:// Á¤µµ´Â ¾ø¾Ù¼öµµ ÀÖÀ» °ÍÀÌ´Ù.
	img¸¦ Â÷°îÂ÷°î µÚ¿¡ ½×´Â´Ù. PAGE¿¡¼­´Â ´ÙÀ½¿¡ ¿À´Â °ÍµéÀÌ ÀÌ ÇöÀçÀÇ Â÷°îÂ÷°î ½×ÀÎ Page¾ÈÀÇ ³»¿ë°ú °°ÀºÁö¸¦ ºñ±³
	°°À¸¸é PAGE¾È¿¡ ³Ö¾î¼­ Ã³¸®¸¦ ÇÏ°í , ¾ø´Ù¸é ÀÌ°ÍºÎÅÍ »õ·Î¿î PAGE·Î ÀÎ½ÄÀ» ÇÑ´Ù.


[[2006.07.27]]
STG_COMMON typedef struct _stg_call {
	##	;;   STG_COMMON_MEMBER{"STIME time"} =  %CreateTime% /**<  ±âº» ÁÖ¼®  : DEFAULT·Î ¾øÀ¸¸é ÀÌ°ÍÀ» »ç¿ëÇÏ°Ô µÊ : ÃÊ±îÁö ³ªÅ¸³»´Â ½Ã°£ */ 
	STIME time;	 %CreateTime% /**<  ±âº» ÁÖ¼®  : DEFAULT·Î ¾øÀ¸¸é ÀÌ°ÍÀ» »ç¿ëÇÏ°Ô µÊ : ÃÊ±îÁö ³ªÅ¸³»´Â ½Ã°£ */ 
		##	;;   STG_COMMON_MEMBER_LOG_KUN{"STIME time"} = %Time%  /**< ÁÖ¼®2 */ 	
		<TAG_COMMON_MEMBER:LOG_KUN>%Time%  /**< ÁÖ¼®2 */ 	
		##	;;   STG_COMMON_MEMBER_LOG_ME{"STIME time"} = %METime%  /**< ÁÖ¼®3 */ 	
		<TAG_COMMON_MEMBER:LOG_ME>%METime%  /**< ÁÖ¼®3 */ 
	MTIME		utime;  %MTime%	 	/**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */

<TAG_KEY>
	IP4 		uiIP;					%IPAddr%				/**< IP address */
	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
</TAG_KEY>

	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
		<TAG_COMMON_MEMBER:LOG_KUN> /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
	U32		uiSID; 				
		<TAG_COMMON_MEMBER:LOG_ME>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
		<TAG_COMMON_MEMBER:LOG_KUN>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
} LOG_CALL;

STG_LOG_TEXT_PARSING typedef struct _... {
	<STG_COMMON:LOG_CALL>
	U32		Test1;
} LOG_KUN;

STG_LOG_TEXT_PARSING typedef struct _... {
	<STG_COMMON:LOG_CALL>
	U32		Test2;
} LOG_ME;

ÀÌ°ÍÀ» ¾È¿¡ ¼±¾ðÇÒ¶§´Â <STG_CALL>
ÀÌ°Í¿¡ ´ë·¡¼­ Ã³¸®¸¦ ÇØÁÖ¾î¾ß ÇÏ´Âµ¥????
STG_CALLÀÌ¶ó´Â °ÍÀ¸·Î ÇÑ°³¸¦ ´õ ¸¸µé °ÍÀÌ´Ù.

TAG_COMMON:KEY¾ÈÀÇ °¢°¢¿¡ ´ëÇÑ KEY  HASH¸¦ ¸¸µé¾îµÎ¾î¾ß ÇÑ´Ù.
±× ¾ÈÀÇ DATA´Â À§ÀÇ LOG_CALLÀÌ µÇ¾îÁú °ÍÀÌ´Ù.
- signalÀº ¾î¶»°Ô Á¸ÇØ¸¦ ÇÒ °ÍÀÎ°¡?  uiCommand°¡ µé¾î°£ structure¸¦ ÀÚµ¿À¸·Î ÇÑ°³¾¿ ¸¸µé¾îÁØ´Ù. ÇØ´ç key·Î ¹ºÁþÀ» ÇÏ°Ô ÇÏ¸é µÉ °ÍÀÌ´Ù.
  LOG_CALL¾Õ¿¡ uiCommand ¸¸À» Ãß°¡ÇØµµ ¹®Á¦°¡ µÇÁö´Â ¾ÊÀ» °ÍÀÌ´Ù.  ±× command¸¦ º¸°í 
  ADDÀÏ °æ¿ì -> ±× ¾È¿¡ setµÇ¾îÁø °ªÀ» º¸°í IP°¡ setµÇ¾îÁ®ÀÖ´Ù¸é IP·ÎµÈ hash¾ÈÀÇ °ª¿¡ ÇöÀçÀÇ °ªµéÀ» ¹Ý¿µÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. (FIRST, LAST°¡ Á¸ÀçÇØ¾ß ÇÏ´ÂÁö´Â °í·Á???)
  	COMMON_DATA°ªµéÀº FIRST,LAST ±ÔÄ¢À» º¸°í Ãß°¡¸¦ ÇØÁÖ´øÁö ÇÏ¸é µÉ °ÍÀÌ°í, KEY°¡ ¿©·¯°³ Æ÷ÇÔµÇ´Â °ÍÀÌ¸é °¢±â Ã£¾Æ¼­ setÇØÁÖ´Â°ÍÀ» ±âº»À¸·Î ÇÑ´Ù.  
  DELÀÏ °æ¿ì -> ±× ¾È¿¡ setµÇ¾îÁø °ªÀÌ IP , TMSIÀÎ °æ¿ì´Â °¢°¢À» Ã£¾Æ¼­ HASH DELÀ» ÇØÁÖ¸é µÇ°í
  ALL_DELÀÎ °æ¿ì´Â °¢°¢À» Ã£¾Æ¼­ loop¸¦ °¢±â ÇÑ¹ø¾¿ ´õ µ¹¾Æ ¿ÏÀüÈ÷ Áö¿öÁÖ´Â °ÍÀ» ±âº»À¸·Î ÇÑ´Ù.

ÀÌ°ÍÀ» ±âº»À¸·Î »ý¼ºÇØ¾ß ÇÏ´Â °ÍÀÌ 2°¡Áö°¡ ÀÖ´Ù.
¾Õ ºÎºÐ --> À§ÀÇ ±âº» <COMMON> structure {} À¸·Î ÀÖ¾î¾ßÇÏ¸ç  KEY ¸¸ // KEY+DATA
µÞ ºÎºÐ --> ºÎ°¡ Á¤º¸¸¦ Æ÷ÇÔÇÏ´Â °Í  // KEY + DATA + Timer/Combination°°Àº ºÎ°¡ Á¤º¸ 
µÞ ºÎºÐ --> uiCommand¸¦ Æ÷ÇÔÇÏ´Â Á¤º¸·Î ÇÑ°³ ´õ Ãß°¡ (signalÀ» À§ÇÑ Á¤º¸) 
ÇÔ¼ö --> °¢ field¸¦ º¸¸é¼­ nullÀÌ ¾Æ´Ï¸é setÀ» ÇØÁÖ°Å³ª(FIRST) , LAST (°ªÀÌ NULLÀÌ ¾Æ´Ï¸é µ¤¾î¾´´Ù.)

±âÁ¸ STG_HASH_KEY¿Í´Â ¾î¶»°Ô ±¸º°À» ÇÒ °ÍÀÎ°¡? ÀÏ´Ü  structure°¡ ±¸ºÐµÇ¾îÁø´Ù.
GLOBAL¿¡´Â LOG°ü·Ã Á¤º¸°¡ ÀÖÀ¸¸ç , COMBINATION , STAT °ü·Ã Á¤º¸µéÀÌ µé¾î°¡ÀÖ´Ù.
STG¿¡ STC¸¦ ½ÖÀ¸·Î ¹­¾î¼­ ÇÑ°³ÀÇ Package·Î »ç¿ëÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù. 
(STC¿¡ PrimitivesµéÀ» Á¤ÀÇ¸¦ ÇÏ¸é ÇÑ°³ÀÇ library°¡ ³ª¿Ã¼ö ÀÖÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. makefileµµ Ãß°¡)

¹®¹ý : STG_COMMON À¸·Î ½ÃÀÛÀ» ÇÏ¸ç 
<TAG_KEY> ·Î ÀÌÁß¿¡¼­ KEY¸¸À» Á¤ÀÇ
U32 uiBase; µÚ¿¡ ³ª¿À´Â °ÍÀº ¹Ø¿¡ Á¤ÀÇµÈ°Ô ¾øÀ¸¸é default°ª
¹Ø¿¡ <TAG_COMMON_MEMBER:TT> ·Î Á¤ÀÇ µÇ¸é TT structure¿¡¼­´Â ¿©±â Á¤ÀÇµÈ ÀÇ¹Ì·Î »ç¿ëµÇ¾îÁüÀ» ÀÇ¹Ì


¿¹»ó °á°ú :
/* LOG·Î Á¤ÀÇµÇÁö ¾ÊÀ½ */
# BASIC_TYPEDEF #
typedef struct _stg_call {
	STIME time;	 /**<  ±âº» ÁÖ¼®  : DEFAULT·Î ¾øÀ¸¸é ÀÌ°ÍÀ» »ç¿ëÇÏ°Ô µÊ : ÃÊ±îÁö ³ªÅ¸³»´Â ½Ã°£ */ 
	MTIME		utime;  	/**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */

	IP4 		uiIP;					%IPAddr%				/**< IP address */
	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */

	U32		uiBase; /**< BASEID */ 	
	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  
	U32		uiSID; 				
} LOG_CALL;

#BASIC_SIGNAL #
typedef struct ... {
	U32	uiCommand;
	LOG_CALL aLOG_CALL;
} LOG_CALL_SIGNAL;

# BASIC_KEY #
typedef struct ...  {
	IP4 		uiIP;					%IPAddr%				/**< IP address */
} LOG_CALL_KEY_uiIP;

typedef struct ...  {
	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
} LOG_CALL_KEY_ucTMSI;

typedef struct ...  {
	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
} LOG_CALL_KEY_ucIMSI;

# BASIC_DATA #
typedef struct ... {
	LOG_CALL	aLOG_CALL;
	U64			TimerId;
	/* LOGÁ¤º¸ ¹Ýº¹ */
	U16 		usCntLOG_CFLOW;
	U16 		usIsDoneLOG_CFLOW;
	LOG_CFLOW 	*pLOG_CFLOW;
	/* Combination / Stat Á¤º¸ */
	COMBI_NewTable 	aCOMBI_NewTable;
	COMBI_Accum 	aCOMBI_Accum;
	COMBI_NewTest 	aCOMBI_NewTest;
	STAT_Accum 	aSTAT_Accum;
	STAT_NewTest 	aSTAT_NewTest;
} LOG_CALL_DATA;

STG_LOG_TEXT_PARSING typedef struct _... {
# BASIC_COMMON_LOG_KUN #
	STIME time;	 %Time%  /**< ÁÖ¼®2 */ 	
	MTIME		utime;  %MTime%	 	/**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */

	IP4 		uiIP;					%IPAddr%				/**< IP address */
	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */

	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#

	U32		Test1;
} LOG_KUN;

STG_LOG_TEXT_PARSING typedef struct _... {
# BASIC_COMMON_LOG_ME #
	STIME time;	 %METime%  /**< ÁÖ¼®3 */ 
	MTIME		utime;  %MTime%	 	/**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */

	IP4 		uiIP;					%IPAddr%				/**< IP address */
	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */

	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#

	U32		Test2;
} LOG_ME;

FIRST / LAST Ãß°¡ : ÇÏ´Â ±è¿¡ ÀÌ°Íµµ Ãß°¡ - combinationµî¿¡µµ Ãß°¡µÇ¾îÁ®¾ß ÇÑ´Ù.  
±×³É keyword·Î Fix¸¦ ½ÃÅ³ ¿¹Á¤ÀÌ´Ù. Æ¯¼ö¹®ÀÚ¿Í ÀÏ¹Ý ¹®ÀÚÀÇ È¥ÇÕÀÇ Keyword
#FIRST#  / #LAST#
¾øÀ¸¸é default ´Â #FIRST#
< combination°ú common ¿¡¼­¸¸ Ãß°¡µÇ¾îÁ®¾ß ÇÑ´Ù. > 


[[2006.07.28]] °³¹ß  (À§ÀÇ ³»¿ë´ë·Î ... ) 
STG_COMMON¿¡ ´ëÇÑ Ã³¸®¸¦ ÇÏ¿©¾ß ÇÑ´Ù. 
STG_COMMON ÀÏºÎ ¿Ï·á : ÃßÈÄ ½ÇÁ¦ ÇÊ¿äÇÒ¶§ ³»¿ëÀ» Ãß°¡ÇÏ´Â °ÍÀ¸·Î ÇÑ´Ù.  
SErvice (Lex libraryÇü½ÄÀ¸·Î±îÁö ¿Ï·á)
COMMON -> CALL
PAGE -> Tokening ³ª¸§´ë·Î (Á¤ÇüÈ­)


[[2006.08.01]] °³¹ß  (À§ÀÇ ³»¿ë´ë·Î ... ) 
* PAGE -> Tokening ³ª¸§´ë·Î (Á¤ÇüÈ­)
	href´Â ³ªÁß¿¡
	img¿¡ ´ëÇØ¼­ Ã³¸®ÇØÁÖ´Â °ÍÀ» È®ÀÎ
	ÇØ´ä : BODY.stc·Î ÇØ¼­ ¸¸µé±ä Çß´Âµ¥ µÇ´ÂÁö´Â ³ªÁß¿¡ ´õ »ìÆìº¸´Â °ÍÀ¸·Î ÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù.  
* shared memory°ü·Ã Â¥¾ßÇÑ´Ù. (¼³°è) - new interface
	- ¼³°è¸¦ ÇÑ´Ù. (NewInterface)

* Memg NodeÀÇ ±¸Á¶ (ÃßÈÄ ½Ã°£À» ºñ±³ÇÏ¿© ¿©·¯°¡Áö ÀÛ¾÷À» ÇÒ¼ö ÀÖ´Ù)
+-------+-----+------+------------+
|Magic# | A/F | Time | Alloc_Name |
+-------+-----+------+------------+
|      Buffer                     |
+---------------------------------+

* NewInterface NodeÀÇ ±¸Á¶
+-------+-----+------+------------+
|Magic# | A/F | Time | Alloc_Name |
+-------+-----+------+------------+
| List(cont)      ----------------------->   NewInterface Node  (ÇÑ MSG°¡ NODE SIZE¸¦ ³ÑÀ»¶§)
+---------------------------------+
| List(next)   -----------+       | 
+-------------------------|-------+
| From | To | Common      |       |
+-------------------------|-------+
|    TLVs                 |       |
+-------------------------|-------+
                          |       
                          V       
+-------+-----+------+------------+
|Magic# | A/F | Time | Alloc_Name |
+-------+-----+------+------------+
| List(cont)      ----------------------->   NewInterface Node (ÇÑ MSG°¡ NODE SIZE¸¦ ³ÑÀ»¶§)
+---------------------------------+
| List(next)   ÀÚ½Å               | 
+---------------------------------+
| From | To | Common              |
+---------------------------------+
|    TLVs                         |
+---------------------------------+
                                  
NODE :INIT

NewInterface primitives : put (link) 
	foreach  
	, freeall , unlink : ³»¿ëÀ» ÇÑ¹ø º¸°í ´Ù½Ã Á¤¸®
	put_cont , put_next

-- MSG Q·ÎºÎÅÍ ¹Þ¾ÒÀ»¶§
offset = msg_get ;
headnodeptr = OFFSET_TO_PTR(offset);
foreach(p, headnodeptr.next){
	foreach(c , p.cont){
	}
}

-- »ý¼ºÇÏ¿© MSG Q·Î º¸³»±â À§ÇÑ 
headnode listhead
ptr = alloc_node;
	ptr->.. ¿¡ ¸¶±¸ set
node ¿¬°á
	cont : put(headnode.cont , OFFSET(ptr));
	next : put(headnode.next , OFFSET(ptr));
¿¬°á ¿Ï·á
	send_to_msgQ(TO , OFFSET(ptr));

Circular Queue´Â MsgQueue·Î ´ëÄ¡Èù´Ù. 
- ÀåÁ¡  : °ü¸® ¾Ë¾Æ¼­ ÇØÁØ´Ù. Process¸¶´Ù inputÀ» ÇÑ°³¸¸ °¡Áø´Ù.
- ´ÜÁ¡  : QueueÀÇ ¿¡·¯·Î ÀÎÇÑ dataµé¿¡ ´ëÇØ¼­ ¾î¶»°Ô º¹¿øÀ» ½ÃÅ³Áö¸¦ °í·ÁÇØÁÖ¾î¾ß ÇÑ´Ù.
(ÁÖ±âÀûÀ¸·Î 30ºÐ ÀÌ»óµÈ ¸Þ¸ð¸®´Â Free·Î ¹Ù²ãÁÖ´Â ºÎºÐµµ °í·Á¸¦ ÇÒ¼ö ÀÖ´Ù. ÀÌ·²¶§ ÃßÈÄ °ü¸®¸¦ ÆíÇÏ°Ô ÇÏ±â À§ÇØ¼­´Â Freelistº¸´Ù array°¡ °ü¸®°¡ ÆíÇÒ¼ö ÀÖ´Ù.)

[[2006.08.02]]  ´Ù°æÀÌ »ýÀÏ  
* SHM¿¡¼­ 
	memg º¯°æ  :  
		½Ã°£ Ãß°¡ 
		ÀÌ°Ç »ç¿ëÇÏÁö ¾Ê°í ÀÖ³×... º¯°æ ¿Ï·á : OFFSET/PTR º¯°æ 
		»óµæ - semaphone Ãß°¡ , »ý¼º status Ãß°¡
	listo , memg , msgq ¸¦ °¡Áö°í À§ÀÇ ¸ð¾çÀ¸·Î Ã³¸®ÇÏ´Â structure¿Í TLV¸¦ Ã³¸®ÇÏ´Â structure¿Í ±×¿¡ ´ëÇÑ ÇÔ¼ö/MACROµéÀ» Á¤ÀÇÇÏ¿©¾ß ÇÑ´Ù.

* LOG°ü·Ã È¸ÀÇ¸¦ ÇÏ¿© fix¸¦ ÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù. Æ¯È÷ , Error°ü·Ã traceÇÒ¼ö ÀÖ´Â ±¸Á¶¸¦ °¡Á®°¡¾ß ÇÒ °ÍÀÌ´Ù. 


** STG_COMMON¿¡ ´ëÇÑ ¼³¸í ¹× ÇØ¼® **
<TAG_DEFINE_START:RespCode>
#define	RespCode_A_Type  1 /* TTT */
#define	RespCode_B_Type  2
#define	RespCode_C_Type  3
<TAG_DEFINE_END:RespCode>

#define TEST_TEST		333
STG_COMMON typedef struct _stg_call {
		<TAG_COMMON_MEMBER:LOG_KUN>%KUN_CTime%  /**< ÁÖ¼®2 */ 	
		<TAG_COMMON_MEMBER:LOG_ME>%ME_CMETime%  /**< ÁÖ¼®3 */ 
	STIME Ctime;	 %CCreateTime% /**<  ±âº» ÁÖ¼®  : DEFAULT·Î ¾øÀ¸¸é ÀÌ°ÍÀ» »ç¿ëÇÏ°Ô µÊ : ÃÊ±îÁö ³ªÅ¸³»´Â ½Ã°£ */ 	#FIRST#
	MTIME		Cutime;  %CMTime%	 	/**< micro ÃÊ ³ªÅ¸³»´Â ½Ã°£ */	#FIRST#

<TAG_KEY>
	IP4 		CuiIP;					%CIPAddr%				/**< IP address */
	U8			CucTMSI[DEF_SIZE_TMSI];	%CTMSI%					/**< TMSI */		#FIRST#		/* TT */
	U8			CucIMSI[DEF_SIZE_IMSI];	%CIMSI%					/**< IMSI */	/* KR */
</TAG_KEY>

		<TAG_COMMON_MEMBER:LOG_KUN> /**< NID */  %KUN_CNID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
	U32		CuiBase; 			%CBASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}# #LAST#
	U8		CuiNID[EX_MAX_NID]; 	 %CNID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  

		<TAG_COMMON_MEMBER:LOG_ME>  /**< ME_SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
		<TAG_COMMON_MEMBER:LOG_KUN>  /**< KUN_SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
	U32		<TAG_DEFINE:RespCode>CuiSID; 	#LAST#			
} LOG_CALL;

STG_COMMON À¸·Î ÇØ¼®À» ÇÑ´Ù.   COMMON INFO¸¦ ³ªÅ¸³»´Â °ÍÀ¸·Î ¿©±â¿¡´Â ¸ðµÎ °°Àº structure¸¦ °¡Áö°í ÀÖÁö¸¸, ±×°Í¿¡ ³Ö¾îÁÖ´Â °ªµéÀº ´Ù¸¦¼ö°¡ ÀÖ´Ù. <TAG_COMMOM_MEMBER: ¸¦ °¡Áö°í ¼­·Î ´Ù¸¦¶§ÀÇ ³»¿ëÀ» Àû¾îÁÖ°Ô µÈ´Ù.
<TAG_DEFINE_START:ÀÌ¸§>  ... END±îÁö  Àº defineÀ» Á¤ÀÇÇÑ °ÍÀ¸·Î ¾Æ·¡¿¡¼­ <TAG_dEFINE:ÀÌ¸§> À¸·Î »ç¿ëÇÏ¸é µÈ´Ù.
<TAG_COMMON_MEMBER:LOGÀÌ¸§> ÀÌ LOGÀÌ¸§ÀÎ °Í¿¡¼­´Â ±× µÚ¿¡ ÀÖ´Â ¸ð¾çÀ¸·Î Àû¾îÁÖ°Ô µÇ´Â °ÍÀ¸·Î 
°¢ LOGÀÌ¸§¸¶´Ù¿¡ 	<STG_COMMON:LOG_CALL> ÀÌ¶ó°í Á¤ÀÇ µÇ¾îÁö¸é ÀÌ·± ºÎºÐÀ» Àû¿ëÇÏ°Ô µÇ´Â °ÍÀÌ´Ù.


[[2006.08.03]]  
* ¿ë¾î Á¤ÀÇ 
MSG : cont , next·Î ±¸¼ºµÈ ÇÑ°³ÀÇ Ã³¸® ´ÜÀ§ (´Ù¼öÀÇ NODE°¡ 2Â÷¿øÀ¸·Î ¿¬°áµÊ)
cont : data°¡ ÇÑ°³ÀÇ NODE size¸¦ ³ÑÀ»¶§ Ãß°¡·Î ÇÒ´çµÇ¾îÁö´Â °Íµé (»õ·Î¿î buffer¿¡ ´ã¾Æ¼­ Ã³¸®ÇÏ´Â ¹æ½Ä ¼±ÅÃ) - ¸Þ¸ð¸® ³¶ºñ¸¦ ¸·±â À§ÇÑ Á¶Ä¡
next : header , bodyµî°ú °°ÀÌ ¿©·¯°³°¡ ÇÑ°³ÀÇ ²Ù·¯¹Ì·Î Ã³¸®µµ¾îÁ®¾ß ÇÒ¶§ (ÇÑ ²Ù·¯¹Ì ¾ÈÀÇ °ÍÀº sync°¡ ¸Â°Ô Ã³¸®ÇØ¾ß ÇÒ¶§ »ç¿ëµÊ)

* newifo ¼³°è (primitives)
node = * newifo_node_alloc(info);
	: NODE 1°³ ÇÒ´ç (¾îµð¿¡µµ link°¡ ¿¬°áµÇÁö ¾ÊÀº ¸ð¾ç) 

newifo_Write(MSGQ_ID,&node_head , &status);
	: MSGQ·Î node¸¦ Àü¼Û (´ÙÀ½ process¿¡¼­ nodeÀÇ offset¸¦ º¸°í Ã³¸®)
	: Àü¼Û½Ã´Â OFFSET() À¸·Î Àü¼Û
node_head = * newifo_make_msg(common_info[FROM|TO|COMMON] , buffer , size);
node_cont_head = * link_cont(node_cont_head, node);
node_next_head = * link_next(node_next_head, node);
node_head = * link(node_head,node);		// µÚ¿¡ Ãß°¡   node = * link(node,node_head); ¾Õ¿¡ Ãß°¡

node_head = * newifo_Read( MSGQ_ID, &status);
	; msg Q·Î ºÎÅÍ ÇÑ°³¸¦ ÀÐ´Â´Ù.
	: ÀÐÇôÁø node´Â cont , next·Î ±¸¼ºµÈ ÇÑ°³ÀÇ MSG ´ÜÀ§ÀÌ´Ù.
	: OFFSETÀ¸·Î Àü¼ÛµÈ °ªÀ» pointer·Î ¹Ù²Ù¾î return
for_each_start(init ; node_next = ; node_next = node_next->next)  : MACROÁ¤ÀÇ
	: node_next¿¡´Â cont·Î ¿¬°áµÈ °ªµéÀ» ÇÑ¹ø¿¡ ÀâÀº pointer°¡ returnµÇ¾îÁü
for_each_end(init ; node_next = ; node_next = node_next->next)  : MACROÁ¤ÀÇ
	: °ü·ÃµÈ nodeµéÀ» freeÇØÁÖ´Â ÀÏÀ» ´ã´ç
node_cont_head = * unlink_cont(node_cont_head, node);
node_next_head = * unlink_next(node_next_head, node);
node_head = * unlink(node_head, node);  // 1°³ÀÇ node¸¦ linkµé¿¡¼­ »èÁ¦
:: bypassÇØÁÖ¾î¾ß ÇÏ´Â °Íµé¿¡ ´ëÇÑ Ã³¸® Ãß°¡(cont¸¦ ÇÕÄ¡´Â °úÁ¤µµ ¾Æ±õ´Ù.) 
::   FROM | TO | COMMON ÀÚ·á¸¦ º¸°í bypassÇÒÁö¸¦ °áÁ¤


[[2006.08.04]]  
* °³¹ß ÀÏÁ¤ °ËÅä : ¸ÖÆ¼ÆÑÀ» Ãß°¡ÇØ¼­ ºÐ¼®ÇÏ´Â ºÎºÐ±îÁö °í·Á
¸ÖÆ¼ÆÑ °ü·Ã download¿Í onlineÀ» ÇÑ´Ù´Â °ÍÀº °á±¹ ME/KUNµµ ±âº»ÀûÀ¸·Î µÈ´Ù´Â °ÍÀÓ.

* TCP¿Í HTTP¿¡ ´ëÇÑ °³¹ß ¹æ¹ý ³íÀÇ : ¸ÖÆ¼ÆÑ °ü·Ã Ãß°¡

* À§ MSGÀÇ ±¸Á¶ Á¤ÀÇ : Á¦¾à »çÇ× Á¤ÀÇ


[[2006.08.14]]
* PAGE °ü·Ã Flow Ã³¸® ¼³°è
[STGÁ¾·ùÀÇ ¹®¹ý]
%NEW_MSG : STATE : which variable : value : NEXT STATE%  #Action#

»õ·Î¿î MSG¸¦ ¹Þ°Ô µÇ¸é 
+-------------+
|    STATE    |
|   #action#  |
+-------------+  --------------------------->  ,_____________,
                   Which variable == value     | NEXT STATE  |
                                               +_____________+

<TAG_FLOW_START:PAGE_FLOW>
%OTHERMSG : OK:(D)thisLOG->SrvL7code:(Y) MENU:TEXT_MENU%  #OK_action a  stateº¯°æ#
%CONTINUE:TEXT_MENU:(L)thisPage->urllistinfo:(Y)thisLOG->url:TEXT_MENU%  #TEXT_MENU_action a stateº¯°æ#
%CONTINUE:TEXT_MENU:(L)thisPage->urllistinfo:(N)thisLOG->url:NEXT_STATE%   #TEXT_MENU_action a stateº¯°æ#
<TAG_FLOW_END:PAGE_FLOW>

(S) : String Compare
(D) : Digit Compare
(L) : String List Compare

(Y) : (L)¿¡¼­¸¸ »ç¿ëÇÏ´Â °ÍÀ¸·Î List¾È¿¡ MatchingÀÌ µÉ¶§  or  Á¤ÀÇ ÇÒ¶§ 
(N) : (L)¿¡¼­¸¸ »ç¿ëµÇ´Â °ÍÀ¸·Î Matching StringÀÌ ¾øÀ»¶§

this , p ~ µÚ¿¡ ºÙ´Â ÀÌ¸§Àº typdefÀÇ ÀÌ¸§À» ±×´ë·Î »ç¿ëÇÏ´Â °ÍÀ» ¿øÄ¢À¸·Î ÇÑ´Ù.


±¸Çö ¹æ¹ý : 
OK_if(srvL7Code){
  switch(srvL7Code){
  case MENU: return TEXT_MENU;
  ¡¦
}
OK_on(isSTART_CALL){
  isNEED_NEW=NO;
  page_state = OK;
  OK_action();
  if(isNEED_NEW==YES &&
     isSTART_CALL == NO)  return ;
  state_go(OK_if(svrL7Code),isSTART_CALL=NO);
} 

TEXT_MENU_if(thisurlListinfo , newurl){
  if(Does thisurlList include newurl == YES) return TEXT_MENU;
  else NEXT_STATE;
}
TEXT_MENU_on(isSTART_CALL){
  isNEED_NEW = YES
  page_state = TEXT_MENU
  page_cateroty = MENU
  TEXT_MENU_action(); a body_parsing&save
  if(isNEED_NEW==YES &&
     isSTART_CALL == NO)  return ;
  state_go(TEXT_MENU_if(),isSTART_CALL=NO);
}

state_go(state_num,isSTART_CALL){
  switch(state_num){
  case OK: OK_on(isSTART_CALL);
  case TEXT_MENU: TEXT_MENU_on(isSTART_CALL);
  ¡¦
  }
}

main(){
  Read_NODE();
  state_go(page_state,isSTART_CALL=YES);
}



[[2006.08.14]]
ÀÏ´Ü dot ±×¸²À» ±×¸®´Â °ÍÀ» ¸ÕÀú ÇØ¾ß ÇÒ °ÍÀÌ´Ù. 

ITERATE ¾È¿¡¼­¸¸ IFEQUAL Ãß°¡   ÇÑ°³ÀÇ lineÀ¸·Î¸¸ ±¸¼ºµÇµµ·ÏÇÔ.



ÀÌ°ÍÀ» ³Ö´Â ÀÌÀ¯´Â C++ÀÇ get/set member functionµéÀ» ¸¸µé±â À§ÇØ¼­ÀÌ´Ù. 
$save_typedef_name_(typedef_name){member¸í} = membertype;
$save_typedef_member_(member¸í){typedef_name} = membertype;
$save_typedef_member{member¸í} = membertype; // Ã³À½ °ÍÀ» setÇÏ°í ´ÙÀ½ °ÍµéÀº ¸ðµÎ °°Àº °ªÀÌ¾î¾ß ÇÑ´Ù.

/** LOG_member_Get_func.c ¾È¿¡ Á¤ÀÇµÇ¾îÁö°Ô µÈ´Ù. 
±âº»ÀûÀ¸·Î °¡Á®¾ß ÇÏ´Â °ÍµéÀ» ¾îµð¿¡ Á¤ÀÇ¸¦ ÇØµÑ ÇÊ¿ä°¡ ÀÖÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. ÀÌ°ÍÀº OUTPUT¿¡ °°ÀÌ »ý¼ºÀÌ µÇ°Ô ÇÏ¸ç Makefile¿¡µµ ³Ö¾î¼­ compileÀÌ µÇ°Ô ÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù.  */

stc.uprÀ» ¸¸µé¾î¼­ ±âº»ÀûÀ¸·Î °¡Áö°í ÀÖ¾î¾ß ÇÏ´Â °ÍµéÀ» Á¤ÀÇÇØ¼­ »ç¿ëÇÏ°Ô ÇÏ´Â °ÍÀÌÁÁÀ» µíÇÏ´Ù.



[[2006.08.21]]
Àú³á¿¡ °¡´Ù ÀÌ¾ß±â ÇÑ ºÎºÐ:
v1.84 : LOG table¿¡¼­¸¸ °°Àº ÀÌ¸§¿¡ ´Ù¸¥ typeÀÌ¸é die ·Î º¯°æ  (Ãß°¡ ¿Ï·á)   v1.84

page state diagram test program ¼öÇà ¿Ï·á (flow.stg,flow.stc)
structg.pl : v1.87 
flow.stc : v1.5
flow.stg : v1.8
LOG_member_Get_func.c : v1.2


precompile : STG_COMMON ¿¡¼­ alternative¸¦ ÇÑ°³µµ »ç¿ëÇÏÁö ¾ÊÀ»¶§ ¹®Á¦ ÇØ°á (STG_BASICÀ» »ç¿ë)
aqua.stg : v1.3
structg_precompile1.pl : v1.5




[[2006.08.22]]
(¿Ï·á) 1. precomileÀ» ÇØ¾ßÇÏ´Â °Íµé¿¡ ´ëÇÑ È®ÀåÀÚ´Â .pstg ·Î ÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù. ÀÌ°ÍÀ» ÇÏ¸é È®ÀåÀÚ°¡ .stg·Î ³ª¿À°Ô ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.
	pstg.pl »ý¼º
	pstg¿ë fileµé : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
	Makefile¿¡ flow , aqua , test  ¿©·¯±âÁö Ãß°¡
(¿Ï·á) 2. stg¸¦ multi·Î Ã³¸®ÇÒ¼ö ÀÖ°Ô ¼öÁ¤ stgµéÀÇ ¸ðÀ½ÀÌ ÀÖÀ»°æ¿ì¿¡´Â ÀÌ°ÍµéÀ» ÂÓ Ã³¸®ÇÒ¼ö ÀÖ´Â stglÀ» ¸¸µé´øÁö ÇØ¾ß ÇÒ °ÍÀ¸·Î º¸ÀÎ´Ù. (ÀÔ·Â fileÀÌ stgl ÀÎ °æ¿ì¿¡´Â List·Î ÇØ¼®ÇÏ¿© Ã³¸®ÇÏµµ·Ï structg.pl À» ¼öÁ¤ÇÏ¸é µÉ °ÍÀ¸·Î º¸ÀÎ´Ù.) - precompile°ü·Ã±îÁö Ãß°¡¸¦ ÇÏ´Â °ÍÀÌ ÁÁÀ» °ÍÀ¸·Î º¸ÀÎ´Ù.
    ÇÑ°³·Î ¸ð¾ÆÁÖ´Â °ÍÀÌ ¸ÂÀ» °ÍÀÌ¶ó »ý°¢µÈ´Ù. FileNameÀ¸·Î .h°¡ »õ·Î »ý¼ºÀÌ µÇ´Â °ÍÀÌ°í, stg¾È¿¡ ÀÖ´Â FileNameÀº ¹«½Ã µÇ°Ô µÉ °ÍÀÌ´Ù.
    test.stg , flow.stg°¡ ÀÖ´Ù°í ÇÏ¸é __ FileNameÀº ¹«½Ã , STC_FileName Àº ÇÕÄ¡°í ,  
    *.stg¿¡ ³ª¿Â °ÍµéÀ» FileName.h -> $outputdir/FileName.stg·Î ¸ðÀº´Ù. ÀÌ ¸ð¾ÆÁø °ÍÀ» °¡Áö°í Ã³¸®¸¦ ÇÑ´Ù.
(¿Ï·á) 3. ¸ÖÆ¼·Î action ¹× IFEQUAL¿¡¼­µµ Ã³¸® °¡´ÉÇÏ°Ô ÇÔ.
	action°ü·Ã Ã³¸®¿¡¼­ ÇöÀç´Â °¡´Â ¹æÇâ¿¡¼­  actionÀ» ÃëÇÏ°Ô ÇÏ¿´Áö¸¸, ½ÇÁ¦·Î´Â vertex·Î °¬À»¶§ actionÀ» ÃëÇÏ´Â °ÍÀÌ ¸Â´Ù°í »ý°¢ÀÌ µÈ´Ù.
#{    ...    }#   À¸·Î    multi-line Ãß°¡ °¡´É
4. PREA , CAPD°ü·Ã binaryÃ³¸®¸¦ ÇØ¾ß ÇÒ °Í : BILLCOMM°ü·Ã signature2µµ °í·Á
5. ÁÖ¼® ´Þ¾Æ¾ß ÇÑ´Ù.
6. state°ü·Ã Ã³¸®¿¡¼­ actionÀº stateº°·Î µÎ¾î¾ß ÇÔ. (Áö±Ý°ú °°ÀÌ edge¿¡ µÎ¸é ¾ÈµÇ°í, vertex¸¶´Ù µÎ¾î¾ß ÇÔ)




[[2006.08.23]] ¼ö
¿ì¸®°¡ »ç¿ëÇÏ±â ¿øÇÏ´Â binary Ã³¸®´Â ¾î¶² °ÍÀ» ¿øÇÏ´Â °ÍÀÎ°¡?
ÀÏ´Ü Fixed typeµéÀÌ RFC¾È¿¡¼­ »ç¿ëµÇ¾îÁø´Ù. ±× ¾ÈÀÇ ¾î¶² type°ªÀ» º¸°í ´ÙÀ½¿¡ ¿Ã structure¸¦ ¾Ë·ÁÁÖ´Â ±¸Á¶¸¦ °¡Áø´Ù.
 



