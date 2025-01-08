#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

user function GRVLACRE(nOpcao,nConfirma)

	Local az01Are := GetArea()
    local nOrdem := 1
    local cCHVNFE := ''
    if nOpcao == 3 .and. nConfirma == 1

        cQuery := "  select *  "
        cQuery += "  from " + RetSQLName("SD1") + " SD1 "  
        cQuery += "  WHERE D_E_L_E_T_ = '' "
        cQuery += "    AND D1_FILIAL = '"+SF1->F1_FILIAL+"' "
        cQuery += "    AND D1_DOC = '"+SF1->F1_DOC+"' "
        cQuery += "    AND D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQuery += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQuery += "    AND D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQuery += "    AND D1_TES = '495' "

        //TCQUERY cQuery NEW ALIAS TRC

        If Select('TZ3') <> 0
		    dbSelectArea('TZ3')
		    TZ3->(dbCloseArea())
	    EndIf
	
	    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TZ3',.F.,.F.)


        DBSELECTAREA("TZ3")
        TZ3->(dbGoTop())

        WHILE TZ3->(!EOF())	 

            nOrdem := U_PegaProx()
            DBSELECTAREA("SF2")
            SF2->(DbSetOrder(1))
            iF SF2->( dbSeek(SF1->F1_FILIAL+TZ3->D1_NFORI+TZ3->D1_SERIORI))
                cCHVNFE  := SF2->F2_CHVNFE
                nF2_PLQUI := SF2->F2_PLIQUI
                nF2_PBRUTO := SF2->F2_PBRUTO
            EndIF 
            DBSELECTAREA("Z01")
            Z01->(DbSetOrder(1))
			Z01->(DBGOTO(1))
            If !Z01->( dbSeek(xFilial("Z01")+SF1->F1_DOC+SF1->F1_SERIE))
            
                RecLock( "Z01", .T. )
                    Z01->Z01_FILIAL  := cFilAnt
                    Z01->Z01_SERIE   := SF1->F1_SERIE
                    Z01->Z01_DOC     := SF1->F1_DOC
                    Z01->Z01_FORNEC  := SF1->F1_FORNECE
                    Z01->Z01_LOJA    := SF1->F1_LOJA
                    Z01->Z01_EMISSA  := SF1->F1_EMISSAO
                    Z01->Z01_ORDEM   := nOrdem  
                    Z01->Z01_NLACRE  := SF1->F1_XLACRE
                    Z01->Z01_NFORI   := TZ3->D1_NFORI
                    Z01->Z01_SERIORI := TZ3->D1_SERIORI
                    Z01->Z01_ITEMOR  := TZ3->D1_ITEMORI
                    Z01->Z01_CHAVE   := cCHVNFE
                    Z01->Z01_PLQUI   := nF2_PLQUI
                    Z01->Z01_PBRUT   := nF2_PBRUTO
                    Z01->Z01_PRODUT  := TZ3->D1_COD
                    Z01->Z01_QTDVEN  := TZ3->D1_QUANT 
                Z01->( MsUnlock() )
			EndIF
        	TZ3->(DBSKIP())
       ENDDO

            
	Elseif nOpcao == 5 .and. nConfirma == 1
			cQuery := "  select *  "
			cQuery += "  from " + RetSQLName("Z01") + " Z01 "  
			cQuery += "  WHERE D_E_L_E_T_ = '' "
			cQuery += "    AND Z01_FILIAL = '"+SF1->F1_FILIAL+"' "
			cQuery += "    AND Z01_DOC = '"+SF1->F1_DOC+"' "
			cQuery += "    AND Z01_SERIE = '"+SF1->F1_SERIE+"' "
			
			//TCQUERY cQuery NEW ALIAS TRC

			If Select('TZ4') <> 0
				dbSelectArea('TZ4')
				TZ4->(dbCloseArea())
			EndIf
		
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TZ4',.F.,.F.)


			DBSELECTAREA("TZ4")
			TZ4->(dbGoTop())

			WHILE TZ4->(!EOF())	

				DBSELECTAREA("Z01")
				Z01->(DbSetOrder(1))
				Z01->(DBGOTO(1))
				If Z01->( dbSeek(xFilial("Z01")+TZ4-Z01_DOC+Z01->Z01SERIE))
					RecLock( "Z01", .F. )
						Z01->(DbDelete())
					Z01->( MsUnlock() )					
				EndIF	
				TZ3->(DBSKIP())
			EndDO
	Endif 

RestArea(az01Are)
Return



user function PegaProx()
Local az01Are := GetArea()
Local cQuery := ''
local nOrdem1 := 1
Local nLOte  := SUPERGETMV("OZ_LOTE")

        cQuery := "  select MAX(Z01_ORDEM) MAXoRDE  "
        cQuery += "  from " + RetSQLName("Z01") + " Z01  
        cQuery += "  WHERE Z01.D_E_L_E_T_ = '' "
        cQuery += "    AND Z01.Z01_FILIAL = '"+cFilAnt+"' "

		If SELECT("TZ2") > 0
			("TZ2")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ2",.T.,.T.)

        DBSELECTAREA("TZ2")

        iF nLOte <= TZ2->MAXoRDE 
            nOrdem1 := TZ2->MAXoRDE+1
        Else 
            nOrdem1  := nLOte 
        ENDIF

        DBCLOSEAREA()
RestArea(az01Are)

Return(nOrdem1)



user function bUSCAnFE(xFilial,cNota,cSerie)
Local az01Are := GetArea()
Local cQuery := ''
local lRet := .f.
Local ctes := SUPERGETMV("OZ_TES")

        cQuery := "  select distinct D1_TES  "
        cQuery += "  from " + RetSQLName("SD1") + " SD1 "  
        cQuery += "  WHERE SD1.D_E_L_E_T_ = '' "
        cQuery += "    AND SD1.D1_FILIAL = '"+cFilAnt+"' "
        cQuery += "    AND SD1.D1_TES = '"+ctes+"' "
        cQuery += "    AND SD1.D1_DOC = '"+cNota+"' "
        cQuery += "    AND SD1.D1_SERIE = '"+cSerie+"'

		If SELECT("TZ1") > 0
			("TZ1")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ1",.T.,.T.)

        DBSELECTAREA("TZ1")

        WHILE !TZ1->(EOF()) .and. !lRet
            
            U_FATA100C(cFilAnt,cNota,cSerie)
            
            lRet := .t.
        EndDO    
        DBCLOSEAREA()
RestArea(az01Are)
Return(lRet)


User Function FATA100C(cFilatu, cDoc, cSer)

Private aArea  := GetArea()
Private oFont1 := TFont():New("Calibri",,016,,.F.,,,,,.F.,.F.)
Private oFont2 := TFont():New("Calibri",,016,,.T.,,,,,.F.,.F.)
Private cGet1  := space(60)
//Private cGet2  := cObs
Private cNot := cDoc
Private cSeri := cSer

Private oButton1
Private oButton2
Private oGet1 
//Private oGet2

Private oSay1 
//Private oSay2

Private oDlg
//660
DEFINE MSDIALOG oDlg TITLE "Informe o numero do Lacre." FROM 000,000  TO 180,400 COLORS 0,16777215 PIXEL

@ 010,005 SAY oSay1 PROMPT "Num Lacre" SIZE 050,012 OF oDlg COLORS 0,16777215 FONT oFont1 PIXEL

@ 010,100 MSGET oGet1 VAR cGet1 SIZE 060,015 OF oDlg PICTURE "@!" COLORS 0,16777215  FONT oFont2 PIXEL


@ 050,120 BUTTON oButton1 PROMPT "Confirma" SIZE 040,012 ACTION FATA1001A(cfilatu,cDoc,cSeri, oGet1) OF oDlg PIXEL
@ 050,065 BUTTON oButton2 PROMPT "Cancela" SIZE 040,012 ACTION oDlg:END() OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return

Static Function FATA1001A(CfiL,cnOTA,cSerie, cLacre )

//Local cQuery := ""

If Empty(cLacre)
	ShowHelpDlg("Aviso", {"Informe o numero do Lacre.",""},5,{"" ,""},5)
	oDlg:END()
	Return
Else
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1")+cNota+cSerie))
	If SF1->(Found())
		If RecLock("SF1",.F.)
			SF1->F1_XLACRE  := cGet1
			MsUnLock()
		Endif
	Endif

Endif

oDlg:END()

      
Return
