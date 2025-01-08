#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AESS016 ºAutor  ³ Ismael Junior        º Data ³  26/11/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de aprovação dos titulos bloquados                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AESS016()                          
Public ProdEtiq1
Public ProdEtiq2
Private nCarreg := 0
Private oOk		   := LoadBitMap(GetResources(), "LBTIK")
Private oNo		   := LoadBitMap(GetResources(), "LBNO")
Private _oBrowse   := Nil
Private _aDados    := {}
Private _aColunas  := {}
Private _aTamanhos := {}
Private _aSZI      := {}
Private _aCols     := {}
Private _aCols2    := {}
Private lTodos  := .t.  
Private aArea := GetArea()

Private _cbLinha
Private cFilial1  := space(tamSX3("ZC_FILIAL")[1])
Private cFilial2  := 'ZZ'
Private cNtitul1  := space(tamSX3("ZC_NUM")[1])
Private cNtitul2  := 'ZZZZZZZZZ'
Private cPrefix1  := space(tamSX3("ZC_PREFIXO")[1])
Private cPrefix2  := 'ZZZ'
Private cFornec1  := space(tamSX3("ZC_FORNECE")[1])
Private cFornec2  := 'ZZZZZZ'
Private cLoja1	  := space(tamSX3("ZC_LOJA")[1])
Private cLoja2	  := 'ZZ'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//											MONTANDO O BROWSE
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Aadd(_aColunas , ''); Aadd(_aTamanhos, 5); Aadd(_aCols,0); _cbLinha := '{IIF(_aDados[_oBrowse:nAt,1] > 0,oOk,oNo)' // Marcado / Nao marcado / N 1
Aadd(_aColunas, 'Item'); Aadd(_aTamanhos, 15); Aadd(_aCols,'00001'); _cbLinha += ", _aDados[_oBrowse:nAT][2]" // Item (C 5)
Aadd(_aColunas, 'Filial'); Aadd(_aTamanhos, 25); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][3]"
Aadd(_aColunas, 'Titulo'); Aadd(_aTamanhos, 25); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][4]"
Aadd(_aColunas, 'Prefixo'); Aadd(_aTamanhos, 15); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][5]"
Aadd(_aColunas, 'Parcela'); Aadd(_aTamanhos, 15); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][6]" 
Aadd(_aColunas, 'Tipo'); Aadd(_aTamanhos, 15); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][7]"
Aadd(_aColunas, 'Fornecedor'); Aadd(_aTamanhos, 20); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][8]"
Aadd(_aColunas, 'Loja'); Aadd(_aTamanhos, 10); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][9]"
Aadd(_aColunas, 'Nome Fornecedor'); Aadd(_aTamanhos, 120); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][10]" 
Aadd(_aColunas, 'Vencimento'); Aadd(_aTamanhos, 40); Aadd(_aCols,''); _cbLinha += ", _aDados[_oBrowse:nAT][11]"
Aadd(_aColunas, 'Valor'); Aadd(_aTamanhos, 40); Aadd(_aCols,0); _cbLinha += ", _aDados[_oBrowse:nAT][12]" 
Aadd(_aDados, _aCols)          
_cbLinha += "}"
                        
aSizeAut  := MsAdvSize(,.F.,400)
_nUltLin  := aSizeAut[6]
_nUltCol  := aSizeAut[5]            
_nAltBut  := 60
_nCompBut := 20
_nLinBut  := _nUltLin - (_nAltBut + 4)

//Alimentando variaveis para preenchimento da tela

//Montando a tela
@ 064,250 To 450,1003 Dialog _oDlg Title "Titulos Bloqueados "
@ aSizeAut[7],0 TO _nUltLin,_nUltCol Dialog _oDlg Title "Liberar Titulos Bloqueados "+SM0->M0_NOMECOM

@ 003,007 TO 026,070 Title OemToAnsi(" Filial ")
@ 013,013 Get    cFilial1 		 		Size 020,070 PICTURE "@!" 
@ 013,040 Get    cFilial2 		 		Size 020,070 PICTURE "@!" 
                                         
//GroupBox dos dados do Produto
@ 003,090 To 026,350 Title OemToAnsi(" fornecedor e loja ")  //montando box = linha,coluna,altura,comprimento
@ 013,093 Get    cFornec1	 	Size 080,070 F3("SA1") 
@ 013,183 Get    cFornec2		Size 080,070 F3("SA1") 
@ 013,273 Get    cLoja1	 		Size 020,070 
@ 013,303 Get    cLoja2		 	Size 020,070 

//GroupBox dos dados do fornecedor
@ 027,007 To 050,265 Title OemToAnsi(" Titulo e prefixo")  //montando box = linha,coluna,altura,comprimento
@ 036,013 Get    cNtitul1 		    Size 080,070 PICTURE "@!" 
@ 036,100 Get    cNtitul2  		 	Size 080,070 PICTURE "@!" 
@ 036,190 Get    cPrefix1  		 	Size 020,070 PICTURE "@!" 
@ 036,217 Get    cPrefix2  		 	Size 020,070 PICTURE "@!" 

@ 011,620 BUTTON 'Carregar'   	  	Size _nAltBut-30 ,_nCompBut  Action Processa({|| GetTit()},"Aguarde...") OF _oDlg PIXEL

@ 033,275 BUTTON 'Marca Todos'    	Size _nAltBut ,_nCompBut  Action Marcatodos()  OF _oDlg PIXEL  
@ 033,340 BUTTON 'Liberar'  Size _nAltBut ,_nCompBut  Action (GravaLib())  OF _oDlg PIXEL 
@ 033,405 BUTTON 'Sair'    			Size _nAltBut ,_nCompBut  Action (IiF(MsgYesNo("Deseja sair?"),_oDlg:End(),))  OF _oDlg PIXEL  //"Sair"
TButton():New(033,470, 'Aprovadores', _oDlg,\{|| A16APRV(_aDados[_oBrowse:nAt,3],_aDados[_oBrowse:nAt,4],_aDados[_oBrowse:nAt,5],_aDados[_oBrowse:nAT][7],_aDados[_oBrowse:nAT][8],_aDados[_oBrowse:nAT][9])\},_nAltBut,10,,,,(.T.))\
TButton():New(033,535, 'Conhecimento', _oDlg,\{|| PedCom(_aDados[_oBrowse:nAt,3],_aDados[_oBrowse:nAt,4],_aDados[_oBrowse:nAt,7],_aDados[_oBrowse:nAT][8],_aDados[_oBrowse:nAT][9])\},_nAltBut,10,,,,(.T.))\
_oBrowse:= TWBrowse():New( 055,005,660,250,,_aColunas,_aTamanhos,_oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    //Linha,Coluna,Comprimento,Altura
_oBrowse:nFreeze		:= 1
_oBrowse:bLDblClick 	:= { || iif(_aDados[_oBrowse:nAt,1] == 0,_aDados[_oBrowse:nAt,1] := 1,_aDados[_oBrowse:nAt,1] := 0)}
_oBrowse:SetArray(_aDados)
_oBrowse:bLine 			:= { || &_cbLinha}
Activate Dialog _oDlg     

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gettit  ºAutor  ³Ismael Junior    	 º Data ³  26/11/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de montagem                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Gettit()
Local lRet 		:= .F.
Local _nItem  	:= 0
Local cUsuario := __cUserId 	     	
	_aDados 	:= {}                                                                  

	cQuery := "SELECT ZC_FILIAL,ZC_PREFIXO,ZC_NUM,ZC_PARCELA,ZC_TIPO,ZC_FORNECE,ZC_LOJA,SA2.A2_NOME E2_NOMFOR,E2_VENCREA,E2_VALOR "
	cQuery += "FROM "+RetSQLName("SZC")+" SZC "
	cQuery += "INNER JOIN "+RetSQLName("SE2")+" SE2 ON E2_NUM = ZC_NUM AND E2_PREFIXO = ZC_PREFIXO AND E2_FORNECE = ZC_FORNECE AND E2_LOJA = ZC_LOJA AND E2_FILIAL = ZC_FILIAL AND SE2.D_E_L_E_T_ = ' ' "
    cQuery += "INNER JOIN "+RetSQLName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_COD = SZC.ZC_FORNECE AND SA2.A2_LOJA = SZC.ZC_LOJA "
	cQuery += "WHERE ZC_DATALIB = '' "
	cQuery += "AND ZC_FILIAL BETWEEN '" + cFilial1 + "' AND '" + cFilial2 + "' "
	cQuery += "AND ZC_NUM BETWEEN '" + cNtitul1 + "' AND '" + cNtitul2 + "' "
	cQuery += "AND ZC_PREFIXO BETWEEN '" + cPrefix1 + "' AND '" + cPrefix2 + "' "
	cQuery += "AND ZC_FORNECE BETWEEN '" + cFornec1 + "' AND '" + cFornec2 + "' "
	cQuery += "AND ZC_LOJA BETWEEN '" + cLoja1 + "' AND '" + cLoja2 + "' "
    cQuery += "AND ZC_APROVA = '" + cUsuario + "' "
	cQuery += "AND SZC.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY ZC_NUM " 
     
	cQuery := changequery(cQuery)	
	TCQUERY cQuery NEW ALIAS "SQL"
		
	dbSelectArea("SQL")
	SQL->(dbGoTop())
		
	ProcRegua(SQL->(RecCount()))
	
	SQL->(DbGoTop())                       
	While !SQL->(Eof())            
	 	_nItem ++
		_aCols  := {} 
		_aCols2 := {} 
		
		SQL->(IncProc())
		
		//Preenchendo aCols com as variaveis ZC_FILIAL,ZC_PREFIXO,ZC_NUM,ZC_PARCELA,ZC_TIPO,ZC_FORNECE,ZC_LOJA,E2_NOMFOR,E2_VENCREA,E2_VALOR
	 	Aadd(_aCols2, 0)          										        //aCols[1] // 1 Marcado / Nao marcado 
		Aadd(_aCols2, strzero(_nItem,5))  										//aCols[2] // 2 Item 
	  	Aadd(_aCols2, SQL->ZC_FILIAL)    	 										
	    Aadd(_aCols2, SQL->ZC_NUM)  
        Aadd(_aCols2, SQL->ZC_PREFIXO)    	 										
	    Aadd(_aCols2, SQL->ZC_PARCELA)
        Aadd(_aCols2, SQL->ZC_TIPO)    	 										
	    Aadd(_aCols2, SQL->ZC_FORNECE) 
        Aadd(_aCols2, SQL->ZC_LOJA)    	 										
	    Aadd(_aCols2, SQL->E2_NOMFOR) 
        Aadd(_aCols2, DTOC(STOD(SQL->E2_VENCREA)))    	 										     										 
	    Aadd(_aCols2, TransForm(SQL->E2_VALOR,PesqPict("SE2","E2_VALOR")))        
	    	  		        		                                                                                               		
		// Montando Array
	    Aadd(_aCols, _aCols2[1]) 			
	    Aadd(_aCols, _aCols2[2]) 			
	    Aadd(_aCols, _aCols2[3])    		
	    Aadd(_aCols, _aCols2[4])     			
	    Aadd(_aCols, _aCols2[5])          	
	    Aadd(_aCols, _aCols2[6])            
        Aadd(_aCols, _aCols2[7]) 		
	    Aadd(_aCols, _aCols2[8]) 		
	    Aadd(_aCols, _aCols2[9])    	
	    Aadd(_aCols, _aCols2[10])     			
	    Aadd(_aCols, _aCols2[11])         
	    Aadd(_aCols, _aCols2[12])            
	    	    	    	    	    	    	    	    	 				
		Aadd(_aDados, _aCols)
	
	    SQL->(dbSkip())   
	enddo              
	
	SQL->(dbCloseArea())
    If Empty(_aDados)
        _aCols  := {} 
	 	Aadd(_aCols, 0)          										      
		Aadd(_aCols, '00001')  									
	  	Aadd(_aCols, '')    	 										
	    Aadd(_aCols, '')  
        Aadd(_aCols, '')    	 										
	    Aadd(_aCols, '')
        Aadd(_aCols, '')    	 										
	    Aadd(_aCols, '') 
        Aadd(_aCols, '')    	 										
	    Aadd(_aCols, '') 
        Aadd(_aCols, '')    	 										     										 
	    Aadd(_aCols, 0) 
        Aadd(_aDados, _aCols)    
    endif
	_oBrowse:SetArray(_aDados)
	_oBrowse:bLine := { || &_cbLinha}
		        
Return lRet
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcaTodos ºAutor  ³Ismael Junior      º Data ³  27/11/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para marcar/desmarcar todas as linhas.  			  º±±
±±º          ³   		                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos
Local _nT := 0
	_nMarca := iif(_aDados[1][1] = 1,0,1)
	For _nT := 1 to Len(_aDados)                        
	  _aDados[_nT][1] := _nMarca
	Next

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaLib ºAutor  ³Ismael Juniorº       Data ³  27/11/2021   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para gravar na SB0, os precos gerados.			      º±±
±±º          ³   		                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaLib()
Local _nTx := 0 
Local cUsuario := __cUserId 
Local cMsglibS := '' 
Local cMsglibAN := ''
Local nlibs := nliban := 0                       
If Empty(_aDados[1][3])
    MsgInfo("Não a dados", "Atenção")
    Return()
Endif
For _nTx := 1 to Len(_aDados)                       
    if _aDados[_nTx][1] = 1 
        cQuery:="SELECT ZC_NUM,ZC_GRUPO "
        cQuery+="FROM " + RetSqlName("SZC") + " SZC "
        cQuery+="WHERE ZC_DATALIB = '' "
        cQuery+="AND ZC_FILIAL = '" + _aDados[_nTx][3] + "' "
        cQuery+="AND ZC_NUM = '" + _aDados[_nTx][4] + "' "
        cQuery+="AND ZC_PREFIXO = '" + _aDados[_nTx][5] + "' "
        cQuery+="AND ZC_FORNECE = '" + _aDados[_nTx][8] + "' "
        cQuery+="AND ZC_LOJA = '" + _aDados[_nTx][9] + "' "
        cQuery+="AND SZC.D_E_L_E_T_ = ' ' "
        If SELECT("SZCTB") > 0
            SZCTB->(DbCloseArea())
        Endif
        ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SZCTB",.T.,.T.)
        If !empty(SZCTB->ZC_NUM)
            cQuery:="SELECT AL_USER,AL_NIVEL,AL_COD "
            cQuery+="FROM "+RetSqlName("SAL")+" SAL " 
            cQuery+="WHERE AL_FILIAL='"+xFilial("SAL")+"' 
            cQuery+="AND AL_USER = '" + cUsuario + "' "
            cQuery+="AND AL_COD = '" + SZCTB->ZC_GRUPO + "' " 
            cQuery+="AND SAL.D_E_L_E_T_ = ' ' "
            If SELECT("SALTB") > 0
                SALTB->(DbCloseArea())
            Endif
            ChangeQuery(cQuery)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALTB",.T.,.T.)
            If !empty(SALTB->AL_NIVEL)
                cQuery:="SELECT TOP 1 AL_NIVEL,DHL_LIMMIN "
                cQuery+="FROM "+RetSqlName("SAL")+" SAL " 
                cQuery+="INNER JOIN "+RetSqlName("DHL")+" DHL ON DHL_COD = AL_PERFIL AND DHL.D_E_L_E_T_ = ' ' "
                cQuery+="WHERE AL_COD = '" + SALTB->AL_COD + "' " 
                cQuery+="AND SAL.D_E_L_E_T_ = ' ' "
                cQuery+="ORDER BY AL_NIVEL DESC "
                If SELECT("SALTB2") > 0
                    SALTB2->(DbCloseArea())
                Endif
                ChangeQuery(cQuery)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALTB2",.T.,.T.)
                    cUpde2 := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
                    cUpde2 += "WHERE E2_FILIAL = '" + _aDados[_nTx][3] + "' ""
                    cUpde2 += "AND E2_PREFIXO = '" + _aDados[_nTx][5] + "' "
                    cUpde2 += "AND E2_NUM = '" + _aDados[_nTx][4] + "' "
                    cUpde2 += "AND E2_TIPO = '" + _aDados[_nTx][7] + "' "
                    cUpde2 += "AND E2_FORNECE = '" + _aDados[_nTx][8] + "' "
                    cUpde2 += "AND E2_LOJA = '" + _aDados[_nTx][9] + "' "
                    cUpde2 += "AND D_E_L_E_T_ = ' ' "  

                    cUpdate := "UPDATE " + RetSqlName("SZC") + " SET ZC_DATALIB = '" + DTOS(Date()) + "', ZC_LIBERA = 'OK'  "
                    cUpdate += "WHERE ZC_FILIAL = '" + _aDados[_nTx][3] + "' "
                    cUpdate += "AND ZC_PREFIXO = '" + _aDados[_nTx][5] + "' "
                    cUpdate += "AND ZC_NUM = '" + _aDados[_nTx][4] + "' "
                    cUpdate += "AND ZC_TIPO = '" + _aDados[_nTx][7] + "' "
                    cUpdate += "AND ZC_FORNECE = '" + _aDados[_nTx][8] + "' "
                    cUpdate += "AND ZC_LOJA = '" + _aDados[_nTx][9] + "' "
                    cUpdate += "AND D_E_L_E_T_ = ' ' "  

                If SALTB->AL_NIVEL = SALTB2->AL_NIVEL .OR. SALTB2->DHL_LIMMIN > Val(StrTran(StrTran(Alltrim(_aDados[_nTx][12]),".",""),",","."))
                    nFlag := TcSqlExec(cUpde2)
                    nFlag := TcSqlExec(cUpdate)
                    nlibs := nlibs + 1 
                    cMsglibS := str(nlibs) + " Titulos liberados com Sucesso..."
                else
                    cUpdate += "AND ZC_NIVEL = '" + SALTB->AL_NIVEL + "' "
                    nFlag := TcSqlExec(cUpdate) 
                    //MsgAlert('Nivel ' + SALTB->AL_NIVEL + ' liberado com Sucesso. Aguardando proximo nivel!')
                    nliban := nliban + 1
                    cMsglibAN := "Nivel " + SALTB->AL_NIVEL + " - " + str(nliban) + " liberado com Sucesso. Aguardando proximo nivel!"
                Endif     
            Else 
                MsgAlert("Você não é aprovador teste titulo!", "Atenção")
                Exit
            Endif
        Endif                              
    endif 
Next
    MsgAlert(cMsglibs + CHR(13)+CHR(10) + cMsglibAN)
    Processa({|| GetTit()},"Aguarde...")
    _oBrowse:REFRESH()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  A16APRV  ºAutor  ³Ismael Junior       º Data ³  27/11/21     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista os aprovadores e mostra o status de cada aprovação   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A16APRV(_cfil,ctit,cPrefix,ctipo,cfornec,cLoj)
Local oButton1
Private fil     := _cfil
Private tit     := ctit
Private prefix  := cPrefix
Private tipo    := ctipo
Private fornec  := cfornec
Private loj     := cLoj 
Static oDlg7

  DEFINE MSDIALOG oDlg7 TITLE "Aprovadores" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

    fprovadores()
    @ 084, 207 BUTTON oButton1 PROMPT "Ok" SIZE 037, 012 OF oDlg7 ACTION oDlg7:END()  PIXEL

  ACTIVATE MSDIALOG oDlg7 CENTERED
Return  

//------------------------------------------------
Static Function fprovadores()
//------------------------------------------------
Local Aprovadores
Local cNomeAprov  := ""
Local cStatus := ""
Local cSQL:= "TBSZC"
Local aDados2 := {}
cQuery := " SELECT ZC_NIVEL,ZC_APROVA,ZC_DATALIB,ZC_LIBERA,ZC_NUM "
cQuery += " FROM " + RetSqlName("SZC") + " SZC "
cQuery += " WHERE ZC_FILIAL = '" + fil + "' "
cQuery += " AND ZC_PREFIXO = '" + prefix + "' "
cQuery += " AND ZC_NUM = '" + tit + "' "
cQuery += " AND ZC_TIPO = '" + tipo + "' "
cQuery += " AND ZC_FORNECE = '" + fornec + "' "
cQuery += " AND ZC_LOJA = '" + loj + "' "
cQuery += " AND SZC.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY ZC_NIVEL "
		
    If SELECT(cSQL) > 0
        (cSQL)->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
    If !Empty((cSQL)->ZC_APROVA)
      Do While (cSQL)->(!Eof())
          PswOrder(1)    // ordenado pelo codigo
          If PswSeek((cSQL)->ZC_APROVA, .T. )
              aInfo := PswRet()
              cNomeAprov  := Alltrim(aInfo[1][2])
          EndIf
          If (cSQL)->ZC_LIBERA == 'OK'
              cStatus := 'Liberado'
          Else
              cStatus := 'Aguardando Lib.'
          Endif            
          Aadd(aDados2,{cNomeAprov,(cSQL)->ZC_NIVEL,cStatus})
          (cSQL)->(dbSkip())
      EndDo
      @ 004, 003 LISTBOX Aprovadores Fields HEADER "APROVADOR","NIVEL","STATUS" SIZE 243, 077 OF oDlg7 PIXEL ColSizes 50,50
      Aprovadores:SetArray(aDados2)
      Aprovadores:bLine := {|| {;
        aDados2[Aprovadores:nAt,1],;
        aDados2[Aprovadores:nAt,2],;
        aDados2[Aprovadores:nAt,3];
      }}
    else
      MsgInfo("Alçada de aprovação não encontrada", "Atenção")
      oDlg7:END()
    Endif    
    // DoubleClick event
    //Aprovadores:bLDblClick := {|| aprovadores[Aprovadores:nAt,1] := !aprovadores[Aprovadores:nAt,1],;
      //Aprovadores:DrawSelect()}

Return

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | PedCom.prw       | AUTOR | ISMAEL JUNIOR |DATA | 14/02/2019   |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - PedCom()                                               |//
//|           |                                                                 |//
//|           | Visualização dos documento no banco de conhecimento na rotina   |//
//|           | de Liberação de Documentos                                      |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

Static Function PedCom(_cFili,cPedido,cTipo,cFornec,cLoja)
Local cExprFilTop  := ""
Local cTabela := "" 
Private cCadastro := "Conhecimento"
Private aRotina := { {"Conhecimento","MsDocument",0,4} }

Private cDelFunc := ".T." 
Private bFiltraBrw   := { || .F. } 
If Empty(cPedido)
    MsgInfo("Não a dados", "Atenção")
    Return()
Endif
        /*----------------- 
        Lucas Costa - STARSOFT INFORMÁTICA LTDA - 27/04/2021 
        Tratariva para agregar os anexos das Notas Fiscais para a rotina de liberação de documentos
        Chamado 4386
        *///-----------------
if cTipo = 'NF' //Filtro para Nota Fiscal
		cTabela := "SF1"
        cExprFilTop    := "F1_DOC "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "SF1.F1_DOC "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "SF1" ) + " SF1 "
        cExprFilTop    += "WHERE SF1.D_E_L_E_T_ = ' ' "
        cExprFilTop    += " AND SF1.F1_FILIAL='" + Alltrim( _cFili) + "'"
        cExprFilTop    += " AND SF1.F1_DOC='"+ Alltrim(substr(cPedido,0,9)) + "' "
        cExprFilTop    += " AND SF1.F1_FORNECE='"+ Alltrim(cFornec) + "' "
        cExprFilTop    += " AND SF1.F1_LOJA='"+ Alltrim(cloja) + "' "
        cExprFilTop    += ")" 
	                	
	Endif		
MBrowse(6,1,22,75,cTabela,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cExprFilTop)

Return   


