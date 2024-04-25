#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa GP410DES        Autor EVANDRO HORM�ZIDO              20/08/12 ���
�������������������������������������������������������������������������͹��
���Desc. :   |Ponto de Entrada  para gerar bordero para DOC ou TED        ���
���          � 	                                                          ���
�������������������������������������������������������������������������͹��
���Uso       |Ponto de Entrada                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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