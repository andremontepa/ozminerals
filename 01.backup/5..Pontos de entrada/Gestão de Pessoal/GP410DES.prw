#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma GP410DES        Autor EVANDRO HORMอZIDO              20/08/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. :   |Ponto de Entrada  para gerar bordero para DOC ou TED        บฑฑ
ฑฑบ          ณ 	                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |Ponto de Entrada                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*
User Function GP410DES()  
LOCAL XAREA   := GETAREA()
LOCAL OK := .T.   
  
    
   IF UPPER(ALLTRIM(CARQENT)) = "santcc.2re"  
      
         IF ALLTRIM(SUBS(cBanco,1,3)) <> "033" 
            OK := .F.
         ENDIF

   ENDIF

   IF UPPER(ALLTRIM(CARQENT)) = "hsbccc.2re"  

         IF ALLTRIM(SUBS(cBanco,1,3)) <> "399" 
            OK := .F.
         ENDIF
      
   ENDIF

 //  IF UPPER(ALLTRIM(CARQENT)) = "santDOC.2re" 
      
 //        IF ALLTRIM(SUBS(cBanco,1,3)) = "033" .OR. NVALOR > 4999 
 //           OK := .F.
 //        ENDIF
 //  ENDIF


   IF UPPER(ALLTRIM(CARQENT)) = "santted2.2re" 
      
         IF ALLTRIM(SUBS(cBanco,1,3)) = "033" // .OR. NVALOR <= 4999 
            OK := .F.
         ENDIF
   ENDIF  

   IF UPPER(ALLTRIM(CARQENT)) = "hsbcted.2re" 
      
         IF ALLTRIM(SUBS(cBanco,1,3)) = "399" //.OR. NVALOR <= 4999 
            OK := .F.
         ENDIF
   ENDIF  
 
RESTAREA(XAREA)

Return(OK)