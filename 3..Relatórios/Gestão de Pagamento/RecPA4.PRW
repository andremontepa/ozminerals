#include "Protheus.ch"
#INCLUDE "Print.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RecPA4  ³ Autor ³ Eduardo Clemente      ³ Data ³ 19/01/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao de Recibos de Pagamento p/ V12                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RecPA4                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            Contracheque para uso na versão 12                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Toni Aguiar³ 01/07/2016    ³ Adaptação do fonte para rodar na Versão 12±±
±±³ Toni Aguiar³ 01/12/2016    ³ Adaptação de 1 via de contracheque por   ³±±
±±³            ³               ³ funcionário.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RecPA4()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cString := "SRA"        // alias do arquivo principal (Base)
Local aOrd    := {"Matricula","C.Custo + Matr.","Nome","C.Custo + Nome"} 
Local cDesc1  := "Emiss„o de Recibos de Pagamento."
Local cDesc2  := "Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := "usuario."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nExtra, cIndCond, cIndRc
Local Baseaux := "S"
Local cDemit  := "N"
Public _oPrint

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
Private nomeprog := "RGPER01"
Private aLinha   := { },nLastKey := 2
Private cPerg    := "RGPE01"
Private cSem_De  := "  /  /    "
Private cSem_Ate := "  /  /    "
Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe
Private cCompac , cNormal
Private aDriver

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aFunc    := {}
Private aProve   := {}
Private aDesco   := {}
Private aBases   := {}
Private aInfo    := {}
Private aCodFol  := {}
Private li       := _PROW()
Private Titulo   := "EMISSAO DE RECIBOS DE PAGAMENTOS"
Private nTamanho := "M"
Private limite	 := 132
Private cMesAno  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fValidSX1()
Pergunte(cPerg,.F.)
wnrel  := "RGPER01"            //Nome Default do relatorio em Disco
wnrel  := SetPrint(cString,wnrel   ,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,   ,nTamanho )
nOrdem :=  aReturn[8]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataRef   := mv_par01                     	// Data Referencia
nTipRel    := 1                            	// Tipo de Impressão
Esc        := mv_par02
cFilDe     := mv_par03						//Filial De
cFilAte    := mv_par04						//Filial Ate
cCcDe      := mv_par05						//Centro de Custo De
cCcAte     := mv_par06						//Centro de Custo Ate
cMatDe     := mv_par07						//Matricula Des
cMatAte    := mv_par08						//Matricula Ate
cNomDe     := mv_par09						//Nome De
cNomAte    := mv_par10						//Nome Ate
Mensag11   := substr(mv_par11,1,1)			//Mensagem 1
Mensag12   := substr(mv_par11,2,1)			//Mensagem 1
Mensag21   := substr(mv_par12,1,1)			//Mensagem 2
Mensag22   := substr(mv_par12,2,1)			//Mensagem 1
Mensag31   := substr(mv_par13,1,1)			//Mensagem 3
Mensag32   := substr(mv_par13,2,1)			//Mensagem 1
Mensag4    := mv_par14						//Mensagem 3
Mensag5    := mv_par15						//Mensagem 3
cSituacao  := mv_par16						//Situacoes a Imprimir
cCategoria := mv_par17						//Categorias a Imprimir
cBaseAux   := If(mv_par18 == 1,"S","N")		//Imprimir Bases
cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
cAnoMesRef := StrZero(Year(dDataRef),4) + StrZero(Month(dDataRef),2)  
cAnoRef13  := StrZero(Year(dDataRef),4)
cMesAno    := mv_par21						// Mês e ano do contracheque a imprimir, yyyymm

If aReturn[5] == 1 .and. nTipRel == 1
	li	:=  0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Impressao                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !fInicia(cString,nTipRel)
	Return
Endif

RptStatus({|lEnd| R030ImpL(@lEnd,wnRel,cString,cMesAnoRef)},Titulo)  // Chamada do Relatorio  

Set Device To Screen

MS_FLUSH()

Return(  NIL )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R030IMP  ³ Autor ³ Eduardo Clemente      ³ Data ³ 19.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento Para emissao do Recibo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R030ImpL(lEnd,WnRel,cString,cMesAnoRef)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lIgual                 //Vari vel de retorno na compara‡ao do SRC
Local cArqNew                //Vari vel de retorno caso SRC # SX3
Local aOrdBag     := {}
Local cMesArqRef  := If(Esc == 4,"13"+Right(cMesAnoRef,4),cMesAnoRef)
Local cArqMov     := ""
Local cNroHoras   := &("{ || If(SRC->RC_QTDSEM > 0, SRC->RC_QTDSEM, SRC->RC_HORAS) }")
Local nHoras      := 0
Local nMes, nAno
Public cCodFunc	  := ""		//-- codigo da Funcao do funcionario
Public cDescFunc  := ""		//-- Descricao da Funcao do Funcionario
Public _n         := 1
Private aCodBenef   := {}
Private cDtPago
Private cAliasMov := ""
Private cPict1	  := "@E 999,999,999.99"
Private cPict2    := "@E 99,999,999.99"
Private cPict3    := "@E 999,999.99"

If MsDecimais(1) == 0
   cPict1	:=	"@E 99,999,999,999"
   cPict2 	:=	"@E 9,999,999,999"
   cPict3 	:=	"@E 99,999,999"
Endif

If Esc == 4
	cMesArqRef := "13" + Right(cMesAnoRef,4)
Else
	cMesArqRef := cMesAnoRef
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se existe o arquivo de fechamento do mes informado  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, @dDataRef , NIL  )
	Return(  NIL  )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando a Ordem de impressao escolhida no parametro.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRA")
If nOrdem == 1      // RA_FILIAL+RA_MAT
	dbSetOrder(1)
ElseIf nOrdem == 2  // RA_FILIAL+RA_CC+RA_MAT
	dbSetOrder(2)
ElseIf nOrdem == 3  // RA_FILIAL+RA_NOME+RA_MAT
	dbSetOrder(3)
ElseIf nOrdem == 4  // RA_FILIAL+RA_CC + RA_NOME
	dbSetOrder(8)
Endif
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando o Primeiro Registro e montando Filtro.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	dbSeek(cFilDe + cMatDe,.T.)
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	dbSeek(cFilDe + cNomDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomAte + cMatAte
ElseIf nOrdem == 4
	dbSeek(cFilDe + cCcDe + cNomDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME"
	cFim     := cFilAte + cCcAte + cNomAte
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
SetRegua(RecCount())	// Total de elementos da regua

aFunc      :={}         // Zera Lancamentos
aProve     :={}         // Zera Lancamentos
aDesco     :={}         // Zera Lancamentos
aBases     :={}         // Zera Lancamentos
aImpos     :={}         // Zera Lancamentos
DESC_MSG   :={}
FLAG       := 0
CHAVE      := 0
Desc_Fil   := Desc_End := DESC_CC:= DESC_FUNC:= ""
DESC_MSG1  := DESC_MSG2:= DESC_MSG3:= Space(01)
DESC_MSG4  := DESC_MSG5:= Space(62)
cFilialAnt := "  "
Vez        := 0
OrdemZ     := 0

Do While SRA->( !Eof() .And. &cInicio <= cFim )
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Movimenta Regua Processamento                                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IncRegua()  // Anda a regua
	
    If lEnd
 	   @Prow()+1,0 PSAY cCancel
	   Exit
    Endif
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_NOME < cNomDe) .Or. (SRA->Ra_NOME > cNomAte) .Or. (SRA->RA_MAT < cMatDe) .Or. (SRA->Ra_MAT > cMatAte) .Or. ;
	   (SRA->RA_CC < cCcDe)    .Or. (SRA->Ra_CC > cCcAte)
	    SRA->(dbSkip(1))
	    Loop
	EndIf
	
	nAteLim   := 0.00 
	nBaseFgts := 0.00
	nFgts     := 0.00
	nBaseIr   := 0.00
	nBaseIrFe := 0.00
	Ordem_rel := 1     // Ordem dos Recibos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Data Demissao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSitFunc  := SRA->RA_SITFOLH
	dDtPesqAf := CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4))
	If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
		cSitFunc := " "
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste situacao e categoria dos funcionarios			     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( cSitFunc $ cSituacao ) .OR. !( SRA->RA_CATFUNC $ cCategoria )
		dbSkip()
		Loop
	Endif
	If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
		dbSkip()
		Loop
	Endif
	
	aArea	:= SRA->(GetArea())
	fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )
	cCodCBO	:= fCodCBO(xFilial("SRJ"),cCodFunc ,dDataRef)
	cDescCC	:= Posicione("CTT",1,xFilial("CTT")+SRA->RA_CC,"CTT_DESC01")
	RestArea( aArea ) 
	
	
	//Adiciona dados do Funcionario
	aAdd(aFunc,{SRA->RA_MAT, Left(SRA->RA_NOME,28), cCodCBO, SRA->RA_CC, cDescCC,	SRA->RA_Filial, TRANSFORM(strzero(ORDEM_REL,3),"9999"),;
	cCodFunc, cDescFunc, SRA->RA_SALARIO, MONTH(SRA->RA_NASC),	Substr(Sra->Ra_BcDepSal,1,3), SRA->RA_BCDEPSAL, SRA->RA_CTDEPSAL,;
	Dtoc(SRA->RA_ADMISSA), SRA->RA_CIC, Alltrim(SRA->RA_NUMCP), Alltrim(SRA->RA_SERCP), Left(SRA->RA_NOMECMP,28)}) // Adicionado mais campos para impressão - Charles Lima - SIGASERVICE
 
	If SRA->RA_Filial # cFilialAnt
		If ! Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. ! fInfo(@aInfo,Sra->Ra_Filial)
			Exit
		Endif
		Desc_Fil  := aInfo[3]
		Desc_End  := aInfo[4]         // Dados da Filial
		Desc_CGC  := aInfo[8]
		DESC_MSG1 := DESC_MSG2 := DESC_MSG3 := Space(01)
		DESC_MSG4 := DESC_MSG5 := Space(62)
		
		// MENSAGENS
		dbSelectArea("SRA")
		cFilialAnt := SRA->RA_FILIAL
	Endif
	
	//Adiciona Mensagens
	aAdd(DESC_MSG,{DESC_MSG1,DESC_MSG2,DESC_MSG3,DESC_MSG4,DESC_MSG5})
	dbSelectArea("SRA")	
	
	If nTipRel == 1
	   If Vez = 0  .and. nTipRel # 3  .and. aReturn[5] # 1
	  	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Descarrega teste de impressao                                ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Endif
	Endif
	
	dbSelectArea("SRA")
	SRA->( dbSkip() )
	_TOTDESC := 0
	_TOTVENC := 0
	_n++
	
EndDo

// Impressao do Recibo de Pagamento
fImpressaoL()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRI")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRA")
SET FILTER TO
RetIndex("SRA")

If !(Type("cArqNtx") == "U")
	fErase(cArqNtx + OrdBagExt())
Endif


Return
  
     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpressao³ Autor ³ Eduardo Clemente      ³ Data ³ 19.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO DO RECIBO                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpressao()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpressaoL()

Local nConta  	:= nContr := nContrT:=0
Local aDriver 	:= LEDriver()
Local _i        := 0
Local _aPos1    := {2000, 1900, 2100, 2300}
Local _aPos2    := {2270, 1900, 2340, 2300}
Local _aBmp 	:= {}
Local _aEmp 	:= {}
Local _oFont8   := Nil
Local _oFont10  := Nil
Local _oFont12  := Nil
Local _oFont16  := Nil
Local _oFont16n := Nil
Local _oFont24  := Nil
Local _oBrush   := Nil
Local cString   := ""
Local nCol 		:= 0
Local _lmesmo 	:= .F.
Local _cont		:= 0
Local _pag 		:= 0 
Local z         := 0
Local y         := 0
Local nVias     := If(MV_PAR22=1, 2, 1)
Local nRecFol   := 0				// conta o número de contracheques de uma via impressos em uma única folha

Private TOTVENC  := {}
Private TOTDESC  := {}
Private aLanca   := {}
Private aImpos   := {}
Private nLinhas	 := 30              // Numero de Linhas do Miolo do Recibo
Private cCompac  := aDriver[1]
Private cNormal  := aDriver[2]
Private _tipofol := ""       
Private cPerAberto					// define se irá buscar as informações na SRC ou SRD
                              

Ordem_Rel := 1
_oPrint   := TMSPrinter():New( "Recibo Laser" )
_oPrint:SetPortrait() // ou SetLandscape()
_oPrint:SetPaperSize(9) // Charles Lima - Ajustado para impressão em folha A4.

// Fontes da Impressão
//_oFont8 := TFont():New("Verdana"    ,9,6 ,.T.,.F.,5,.T.,5,.T.,.F.)
//_oFont8   := TFont():New("Courier New",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont8   := TFont():New("Courier New",9,6 ,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont8n  := TFont():New("Verdana"    ,9,6 ,.T.,.T.,5,.T.,5,.T.,.F.)
//_oFont8 := TFont():New("Courier"    ,9,8 ,   ,.F., ,   , ,   ,.F.)
_oFont10  := TFont():New("Verdana"    ,9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont10n := TFont():New("Verdana"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
//_oFont10:= TFont():New("Courier"    ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont12  := TFont():New("Courier"    ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont16  := TFont():New("Courier"    ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
_oFont16n := TFont():New("Courier"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
_oFont24  := TFont():New("Courier"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
_oFontCP  := TFont():New("Arial"      ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
_oBrush   := TBrush():New("",4)

DEFINE PEN oPenCP WIDTH 3 COLOR CLR_GRAY

For _I := 1 TO Len(aFunc)
	
	aLanca    := {}  // Zera Lancamentos
	TOTVENC   := {}  // Zera Vencimentos
	TOTDESC   := {}  // Zera Descontos
	aImpos    := {}  // Zera Impostos
	llanca(aFunc[_I][1],aFunc[_I][4],aFunc[_I][6])	
	Z         := 0
	_nctaz    := 1
	_MaxLin   := 14  // Maximo de Linhas nos Lancamentos
	nDivisao  := (Len(aLanca) / _MaxLin)
	_StopLanc := 0  
	
	If Int(nDivisao) <> nDivisao // Calculo de numeros paginas necessarios para mostrar TODOS os lançamentos
		_pag := Int(nDivisao) + 1
	Else
		_pag := nDivisao
	Endif
	
	For y:=1 to _pag
	    
	    //-- Toni Aguiar - TOTVS STARSOFT em 01/12/2016
	    //-- Controle de contracheques por páginas
	    If nRecFol=0			// controle de contracheques impressos, se for o primeiro contracheque da página a imprimir,
		   _cont := -50         // starta o primeiro contracheque a partir do cabeçalho
		   _oPrint:StartPage()  // Inicia uma nova página 
	    Endif
		
		//Imprime duas vezes na mesma pagina
		For z:= 1 to nVias //2
            
            nRecFol++			// controle de impressão de contracheque
			//Adiciona dados da Empresa e Filial do Funcionario
			dbSelectArea("SM0")
			dbSetOrder(1)
			dbSeek(cEmpAnt+aFunc[_I][6],.T.)
			
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	        //³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )
			
			Do Case
			   Case MV_PAR02 = 1
				    _tipoFol:= "ADI"
			   Case MV_PAR02 = 2
			        _tipoFol:= "FOLHA"
			   Case MV_PAR02 = 3
			        _tipoFol:= "13 SAL. PARC. 1"
			   Case MV_PAR02 = 4
			        _tipoFol:= "13 SAL. PARC. 2"
			   Case MV_PAR02 = 5
			        _tipoFol:= "VALORES EXTRAS"
			EndCase  
			
			_oPrint:Box(_cont+0100,0130, _cont+0230, 2250)  																// Primeiro Box
			_oPrint:Say(_cont+100, 0145, Alltrim(SM0->M0_NOMECOM), _oFont10n)												// Nome da Empresa
			_oPrint:Say(_cont+180, 0900, "DEMONSTRATIVO DE PAGAMENTO DE " + _tipoFol, _oFont10n) 							// Titulo -  tirei 1625 - 625
			_oPrint:Say(_cont+140, 0145, Alltrim(SM0->M0_ENDCOB)+", "+AllTrim(SM0->M0_BAIRCOB)+ "- "+AllTrim(SM0->M0_CIDCOB)+"-"+SM0->M0_ESTCOB, _oFont8n)  	// Endereco da Empresa
			_oPrint:Say(_cont+140, 1850, "MÊS : " + MesExtenso(MONTH(dDataRef)) + " de "+ STR(YEAR(dDataRef),4), _oFont8n)	// Mes da Folha
			_oPrint:Say(_cont+180, 0145, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), _oFont10n) 															// CNPJ
			
			If Z == 1
 			   _oPrint:Say(_cont+180, 1850, "1 - Via da Empresa ", _oFont8) 	   											// Via 1
			Else            
 			   _oPrint:Say(_cont+180, 1850, "2 - Via do Funcionario ", _oFont8) 											// Via 2
			Endif
			
		   	_oPrint:Box(_cont+0230, 0130, _cont+0400, 2250)  																    // Segundo Box
			_oPrint:Say(_cont+0250, 0145, "Código", _oFont8n)   																// Codigo
			_oPrint:Say(_cont+0250, 0290, "Nome do Funcionário", _oFont8n)  													// Nome do Funcionario
			_oPrint:Say(_cont+0250, 0845, "CBO", _oFont8n)      																// CBO
			_oPrint:Say(_cont+0250, 0995, "C.Custo", _oFont8n)  																// C.Custo
//			_oPrint:Say(_cont+0250, 1206, "Descrição C.Custo", _oFont8n)  													// Descricao C.Custo
			_oPrint:Say(_cont+0250, 1450, "Admissão", _oFont8n)               											    // Dt. Admissão
			_oPrint:Say(_cont+0250, 1650, "CPF", _oFont8n)               											        // CPF			
			_oPrint:Say(_cont+0250, 1900, "CTPS", _oFont8n)               											        // CTPS			
			_oPrint:Say(_cont+0250, 2140, "Pág.", _oFont8n)                													// Pág./Fl.
			//----------------------------
			_oPrint:Say(_cont+0300, 0145, aFunc[_I][1], _oFont8)															// Codigo
			_oPrint:Say(_cont+0300, 0290, aFunc[_I][2], _oFont8)															// Nome do Funcionario
			_oPrint:Say(_cont+0300, 0845, aFunc[_I][3], _oFont8)															// CBO
			_oPrint:Say(_cont+0300, 0995, alltrim(aFunc[_I][4])+" - "+alltrim(SubStr(aFunc[_I][5],1,25)), _oFont8)			// C.Custo
//			_oPrint:Say(_cont+0300, 1206, alltrim(aFunc[_I][5]), _oFont8)													// Descricao C. Custo
			_oPrint:Say(_cont+0300, 1450, aFunc[_I][15], _oFont8)															// Dt. Admissão
			_oPrint:Say(_cont+0300, 1650, Transform(aFunc[_I][16],"@R 999.999.999-99"), _oFont8)							// CPF			
			_oPrint:Say(_cont+0300, 1900, aFunc[_I][17]+" / "+aFunc[_I][18], _oFont8)   									// CTPS						
			_oPrint:Say(_cont+0300, 2140, strzero(y,3) , _oFont8)															// Pág./Fl.
			
			_oPrint:Say(_cont+0350, 0145, "Função : ", _oFont8n)  															// Funcao
			_oPrint:Say(_cont+0350, 0290, aFunc[_I][8]+" - "+aFunc[_I][9], _oFont8)										    // Codigo e Descricao
			
		   	_oPrint:Box(_cont+0400, 0130, _cont+1700, 2250)         														// Box dos lançamentos
			_oPrint:Line(_cont+0450, 0130, _cont+0450, 2250)        														// Horizontal do cabecalho dos lançamentos
			_oPrint:Say(_cont+0405, 0145, "Cód.", _oFont8n) 																// Codigo
			_oPrint:Line(_cont+0405, 0250, _cont+1100, 0250)        														// Linha Vertical 1
			_oPrint:Say(_cont+0405, 0655, "Descrição", _oFont8n)   															// Descricao
			_oPrint:Line(_cont+0405, 1155, _cont+1100, 1155)        														// Linha Vertical 2
			_oPrint:Say(_cont+0405, 1190, "Ref.", _oFont8n)        															// Ref.
			_oPrint:Line(_cont+0405, 1300, _cont+1250, 1300)        														// Linha Vertical 3
			_oPrint:Say(_cont+0405, 1480, "Proventos", _oFont8n)      														// Vencimentos
			_oPrint:Line(_cont+0405, 1800, _cont+1160, 1800)        														// Linha Vertical 4
			_oPrint:Say(_cont+0405, 1965, "Descontos", _oFont8n)    														// Descontos
			
			_W 		:= 1
			_ncont	:= 0
			If Z == 1
			   If _StopLanc == 0
				  _nctaz  := 1   // Comeca imprimindo desde o PRIMEIRO lançamento
			   Else
			  	  _nCtaz  := _StopLanc
			   Endif
			Endif

		    nColPro := 1540		// Posição da coluna de valores dos proventos
		    nColDes := 1980		// Posição da coluna de valores dos descontos
			For nConta := _nctaz To Len(aLanca)
				If nConta <= iif(Y >= 2,(nlinhas + _nctaz), nlinhas)
				   _W      := _W + 45
				   cString := PadL(AllTrim(Transform(aLanca[nConta,5],cPict2)),17," ")
				   nCol    := If(aLanca[nConta,1] = "P", nColPro, If(aLanca[nConta,1] = "D", nColDes, 0255))
					
				   _oPrint:Say(_cont+0405+_W, 0155, aLanca[nConta,2] , _oFont8)  											// Codigo da Verba
				   _oPrint:Say(_cont+0405+_W, 0260, aLanca[nConta,3] , _oFont8)  											// Nome da Verba
					
					If aLanca[nConta,1] # "B"        																		// So Imprime se nao for base
						If aLanca[nConta,4] <= 9.99
							_oPrint:Say(_cont+0405+_w, 1190, TRANSFORM(aLanca[nConta,4],"999.99"), _oFont8)  				// Referencia Horas
						Endif
						If aLanca[nConta,4] <= 99.99 .and. aLanca[nConta,4] > 9.99
							_oPrint:Say(_cont+0405+_w, 1190, TRANSFORM(aLanca[nConta,4],"999.99"), _oFont8)  				// Referencia Horas
						Endif
						If aLanca[nConta,4] <= 999.99 .and. aLanca[nConta,4] > 99.99
							_oPrint:Say(_cont+0405+_w, 1190, TRANSFORM(aLanca[nConta,4],"999.99"), _oFont8)  				// Referencia Horas
						Endif
					Endif                      
					
					If aLanca[nConta,5] <= 9.99
					   _oPrint:Say(_cont+0405+_w, nCol, cString, _oFont8)
					Endif
					If aLanca[nConta,5] <= 99.99 .and. aLanca[nConta,5] > 9.99   											// Referencia Valor
						_oPrint:Say(_cont+0405+_w, nCol, cString, _oFont8)
					Endif
					If aLanca[nConta,5] <= 999.99 .and. aLanca[nConta,5] > 99.99                                          // Referencia Valor
						_oPrint:Say(_cont+0405+_w, nCol, cString, _oFont8)
					Endif
					If aLanca[nConta,5] <= 9999.99 .and. aLanca[nConta,5] > 999.99                                        // Referencia Valor
						_oPrint:Say(_cont+0405+_w, nCol, cString, _oFont8)
					Endif
					If aLanca[nConta,5] <= 99999.99 .and. aLanca[nConta,5] > 9999.99                                      // Referencia Valor
						_oPrint:Say(_cont+0405+_w, nCol, cString, _oFont8)
					Endif
					
					nContr++
					nContrT++
					_ncont++
					
					//   --------------------------------------------------------------------------------------------------
					//                                 Tratamento da QUEBRA de PÁGINA
					//   --------------------------------------------------------------------------------------------------
					If _nCont == _MaxLin
						If Len(aLanca) > _nCont
							_W 		  := _W + 45
							_StopLanc := nConta + 1
							_oPrint:Say(_cont+0400+_W, 0255, "CONTINUA !!!", _oFont8)
						Endif
						Exit
					Endif
					
				Endif
				
			Next nConta
			
			If !_lmesmo .or. (Y >= 2 .and. _lmesmo)
				// Impreme Mensagens
				_oPrint:Say(_cont+1290, 0145, DESC_MSG[_I][1], _oFont8)
				_oPrint:Say(_cont+1310, 0145, DESC_MSG[_I][2], _oFont8)
				_oPrint:Say(_cont+1320, 0145, DESC_MSG[_I][3], _oFont8)
				IF MONTH(dDataRef) = aFunc[_I][11]
					_oPrint:Say(_cont+1640, 0215, "F E L I Z   A N I V E R S A R I O  ! !", _oFont12)
					_oPrint:Say(_cont+1470, 0145, DESC_MSG[_I][4], _oFont8)
					_oPrint:Say(_cont+1495, 0145, DESC_MSG[_I][5], _oFont8)
					
				ELSE
					_oPrint:Say(_cont+1470, 0145, DESC_MSG[_I][4], _oFont8)
					_oPrint:Say(_cont+1495, 0145, DESC_MSG[_I][5], _oFont8)
				ENDIF
				
				//Mensagens da conta corrente
				If SRA->RA_BCDEPSAL # SPACE(8)
				   If aFunc[_I][12] == "237"
					  Desc_Bco := "Banco Bradesco  "
				   Else
					  If aFunc[_I][12] == "341"
						 Desc_Bco := "Banco Itau      "
				      Endif
					Endif
					Desc_Bco := ALLTRIM(DescBco(Sra->Ra_BcDepSal,Sra->Ra_Filial))
					_oPrint:Say(_cont+1200, 0145, "CRED: "+aFunc[_I][13]+" - "+DESC_BCO+"   CONTA: " + aFunc[_I][14], _oFont8)					
				Endif
				
				_oPrint:Line(_cont+1100, 0130, _cont+1100, 2250)  // linha horizontal no final dos lançamentos
				_oPrint:Line(_cont+1160, 1300, _cont+1160, 2250)  // linha horizontal antes do Valor liquido
				_oPrint:Say(_cont+1200, 1315, "Valor Liquido      ==>"   , _oFont10n)
				
				//===============> PROVENTOS
				lMostraTot := .T.
				If Y < _Pag
					lMostraTot := .F.
				Endif  
				     
				If TOTVENC[1][2] <= 9.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColPro,PadL(AllTrim(Transform(TOTVENC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTVENC[1][2] <= 99.99 .and. TOTVENC[1][2] > 9.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColPro,PadL(AllTrim(Transform(TOTVENC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTVENC[1][2] <= 999.99 .and. TOTVENC[1][2] > 99.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColPro,PadL(AllTrim(Transform(TOTVENC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTVENC[1][2] <= 9999.99 .and. TOTVENC[1][2] > 999.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColPro,PadL(AllTrim(Transform(TOTVENC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTVENC[1][2] <= 99999.99 .and. TOTVENC[1][2] > 9999.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColPro,PadL(AllTrim(Transform(TOTVENC[1][2],cPict1)),17," "), _oFont8)
				Endif  

				//=================> DESCONTOS
				If TOTDESC[1][2] <= 9.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColDes,PadL(AllTrim(Transform(TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTDESC[1][2] <= 99.99 .and. TOTDESC[1][2] > 9.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColDes,PadL(AllTrim(Transform(TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTDESC[1][2] <= 999.99 .and. TOTDESC[1][2] > 99.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColDes,PadL(AllTrim(Transform(TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTDESC[1][2] <= 9999.99 .and. TOTDESC[1][2] > 999.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColDes,PadL(AllTrim(Transform(TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif
				If TOTDESC[1][2] <= 99999.99 .and. TOTDESC[1][2] > 9999.99 .and. lMostraTot
					_oPrint:Say(_cont+1110, nColDes,PadL(AllTrim(Transform(TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif
				
				//-- Toni Aguiar - TOTVS STARSOFT em 01/12/2016
				//-- Documentado
				//=================> LIQUIDO
				/*If (TOTVENC[1][2]-TOTDESC[1][2]) >=0
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= 9.99  .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= 99.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 9.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= 999.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 99.99  .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= 9999.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 999.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
				Else
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= -9.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= -99.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 9.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= -999.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 99.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
					If (TOTVENC[1][2]-TOTDESC[1][2]) <= -9999.99 .and. (TOTVENC[1][2]-TOTDESC[1][2]) > 999.99 .and. lMostraTot
						_oPrint:Say(_cont+1200, 1800,TRANSFORM((TOTVENC[1][2]-TOTDESC[1][2]),cPict1), _oFont8)
					Endif
				Endif*/
                
                //-
                //- Toni Aguiar - TOTVS STARSOFT  em 01/12/2016
                //- Imprime o valor líquido do contracheque.
                If lMostraTot
					_oPrint:Say(_cont+1200, nColDes,PadL(AllTrim(Transform(TOTVENC[1][2]-TOTDESC[1][2],cPict1)),17," "), _oFont8)
				Endif                                                                                     
				
				_oPrint:Box(_cont+1260, 0130, _cont+1350, 2250)  // Box de demonstração do  Salário Base, FGTs, etc.
				_oPrint:Say(_cont+1260, 0211, "Salário-Base"		, _oFont8n)
				_oPrint:Say(_cont+1260, 0552, "Sal. Contr. INSS"	, _oFont8n)
				_oPrint:Say(_cont+1260, 0967, "Base Cálc. FGTS"		, _oFont8n)
				_oPrint:Say(_cont+1260, 1367, "FGTS do Mês"			, _oFont8n)
				_oPrint:Say(_cont+1260, 1650, "Base Cálc. IRRF"		, _oFont8n)
				_oPrint:Say(_cont+1260, 2092, "Faixa IRRF"			, _oFont8n)
				
				If !Empty( cAliasMov )
					nValSal := 0
					nValSal := fBuscaSal(dDataRef)
					If nValSal == 0
						nValSal := aFunc[_I][10]
					EndIf
				Else
					nValSal := aFunc[_I][10]
				EndIf
				
				_oPrint:Say(_cont+1300, 0150, Transform(nValSal,cPict2) , _oFont8)
				
				If Esc = 1  // Bases de Adiantamento
					If cBaseAux = "S" .And. aImpos[1][1] # 0
					   _oPrint:Say(_cont+1300, 1600, TRANSFORM(aImpos[1][1],cPict1) , _oFont8)
					Endif
				ElseIf Esc = 2 .Or. Esc = 4  // Bases de Folha e 13o. 2o.Parc.
					If cBaseAux = "S"
					   _oPrint:Say(_cont+1300, 0500,Transform(aImpos[1][2],cPict1) , _oFont8)
					   If aImpos[1][3] # 0
					      _oPrint:Say(_cont+1300, 0920, TRANSFORM(aImpos[1][3],cPict1) , _oFont8)   //800
					   Endif
					   If aImpos[1][4] # 0
					      _oPrint:Say(_cont+1300, 1300,TRANSFORM(aImpos[1][4],cPict2) , _oFont8)
					   Endif
					   If aImpos[1][1] # 0
						  _oPrint:Say(_cont+1300, 1600,TRANSFORM(aImpos[1][1],cPict1) , _oFont8)
					   Endif
					   _oPrint:Say(_cont+1300, 2000, Transform(aImpos[1][5],cPict1) , _oFont8)
					Endif
				ElseIf Esc = 3 // Bases de FGTS e FGTS Depositado da 1¦ Parcela
					If cBaseAux = "S"
					   If aImpos[1][3] # 0
						  _oPrint:Say(_cont+1300, 0920,TRANSFORM(aImpos[1][3],cPict1), _oFont8)
					   Endif
					   If aImpos[1][4] # 0
					      _oPrint:Say(_cont+1300, 1300, TRANSFORM(aImpos[1][4],cPict2) , _oFont8)
					   Endif
					Endif
				Endif
				
				_oPrint:Say(_cont+1400, 0200, "DECLARO TER RECEBIDO A IMPORTANCIA LIQUIDA DISCRIMINADA NESTE RECIBO "  , _oFont8)
				_oPrint:Say(_cont+1525, 0620, " ________/________/________  ", _oFont10)
				_oPrint:Say(_cont+1525, 1320, "_____________________________________________"   , _oFont10)
				_oPrint:Say(_cont+1575, 0520, "                  DATA                     "  , _oFont8)
				_oPrint:Say(_cont+1575, 1320, aFunc[_I][19]   , _oFont8)   //1470
				
			Endif

			_lmesmo	:= .F.
			
			If Z == 1 .And. nRecFol == 1 
			   _cont  := 1610  
			   _oPrint:Say(_cont+45, 0000, "...>>>."+Replicate(".",240)+".<<<..."   , _oFont10)
            Endif
		Next Z
		
		//-- Toni Aguiar - TOTVS STARSOFT em 01/12/2016
		//-- Controle de contracheques por página
		//-- Finalização da página
		If nRecFol=2			// Se for o último contrcheque impresso na página,
		   nRecFol:=0           // zera o controle para um novo cíclo e
	       _oPrint:EndPage()    // finaliza a página
	    Endif
	Next      
	
Next

_oPrint:Preview()     // Visualiza antes de imprimir

Return Nil



// Lancamentos
//*********************************************
Static Function llanca(_codmat,_codcc,_cFilial)

Local cNroHoras   := &("{ || If(SRC->RC_QTDSEM > 0, SRC->RC_QTDSEM, SRC->RC_HORAS) }")     // Horas no Mes
Local cNroHorad   := &("{ || If(SRD->RD_QTDSEM > 0, SRD->RD_QTDSEM, SRD->RD_HORAS) }")     // Horas no Acumulado
Private cPeriodo  := cMesAno 

nAteLim   := 0.00
nBaseFgts := 0.00
nFgts     := 0.00
nBaseIr   := 0.00
nBaseIrFe := 0.00
_TOTVENC  := 0
_TOTDESC  := 0
Esc       := mv_par02

dbSelectArea("RFQ")
RFQ->(dbSetOrder(1))    
If !RFQ->(dbSeek(xFilial("RFQ")+mv_par19+cPeriodo))
   Alert("Período não encontrado ou processo inválido...")
   Return
Endif
cPerAberto:=RFQ->RFQ_STATUS

dbSelectArea("SRA")
dbgotop()
dbSeek(_cFilial+_codmat)

If Esc == 1 .OR. Esc == 2  // Adto ou Folha
   
  If cPerAberto = "1"
   
     dbSelectArea("SRC")
     dbSetOrder(1)
     If dbSeek(_cFilial+_codmat)
      
        Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
	  
		   If (Esc == 1) .And. (Src->Rc_Pd == aCodFol[7,1])      // Desconto de Adto
		       fSomaPd("P",aCodFol[6,1],Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
			   _TOTVENC+=Src->Rc_Valor
           Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[12,1])
				   fSomaPd("D",aCodFol[9,1],Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
				   _TOTDESC+=SRC->RC_VALOR
           Elseif (Esc == 1) .And. (Src->Rc_Pd == aCodFol[8,1])
				   fSomaPd("P",aCodFol[8,1],Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
				   _TOTVENC+=Src->Rc_Valor
           Else
			   If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
					  If cPaisLoc == "PAR" .and. Eval(cNroHoras) == 30
					     LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataRef),4)), Ctod(StrZero(F_ULTDIA(dDataRef),2)+"/"+Strzero(Month(dDataRef),2)+"/"+right(str(Year(dDataRef)),2)),@nHoras)
					  Else
					     nHoras := Eval(cNroHoras)
					  Endif
					     fSomaPd("P",SRC->RC_PD,nHoras,SRC->RC_VALOR,SRC->RC_MAT)
					     _TOTVENC+=Src->Rc_Valor
					  Endif
			   Elseif SRV->RV_TIPOCOD == "2"
					  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
						  fSomaPd("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
						  _TOTDESC+=Src->Rc_Valor
					  Endif
			   Elseif SRV->RV_TIPOCOD == "3"
					  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
						  fSomaPd("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
					  Endif
			   Endif
		   Endif
           If ESC == 1
			  If SRC->RC_PD == aCodFol[10,1]
			     nBaseIr := SRC->RC_VALOR
			  Endif
           ElseIf SRC->RC_PD == aCodFol[13,1]
				  nAteLim += SRC->RC_VALOR
		   Elseif SRC->RC_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
				  nBaseFgts += SRC->RC_VALOR
		   Elseif SRC->RC_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
				  nFgts += SRC->RC_VALOR
		   Elseif SRC->RC_PD == aCodFol[15,1]
				  nBaseIr += SRC->RC_VALOR
		   Elseif SRC->RC_PD == aCodFol[16,1]
				  nBaseIrFe += SRC->RC_VALOR
		   Endif
		 
		   dbSelectArea("SRC")
		   dbSkip()
	  
	    Enddo
	
	  Endif
  
  Else  // Dados das Folhas dos Meses Anteriores Folha Fechado.

	 dbSelectArea("SRD")  
     //If dbSeek(_cFilial+_codmat+cAnoMesRef)
     If dbSeek(_cFilial+_codmat+cPeriodo)
      
        Do While !Eof() .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PERIODO == SRA->RA_FILIAL+SRA->RA_MAT+cPeriodo
	  
		   If (Esc == 1) .And. (Srd->Rd_Pd == aCodFol[7,1])      // Desconto de Adto
		       fSomaPd("P",aCodFol[6,1],Eval(cNroHorad),SRD->RD_VALOR,SRD->RD_MAT)
			   _TOTVENC+=Srd->Rd_Valor
           Elseif (Esc == 1) .And. (Srd->Rd_Pd == aCodFol[12,1])
				   fSomaPd("D",aCodFol[9,1],Eval(cNroHorad),SRD->RD_VALOR,SRD->RD_MAT)
				   _TOTDESC+=SRD->RD_VALOR
           Elseif (Esc == 1) .And. (Srd->Rd_Pd == aCodFol[8,1])
				   fSomaPd("P",aCodFol[8,1],Eval(cNroHorad),SRD->RD_VALOR,SRD->RD_MAT)
				   _TOTVENC+=Srd->Rd_Valor
           Else
			   If PosSrv( Srd->Rd_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
					  If cPaisLoc == "PAR" .and. Eval(cNroHorad) == 30
					     LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataRef),4)), Ctod(StrZero(F_ULTDIA(dDataRef),2)+"/"+Strzero(Month(dDataRef),2)+"/"+right(str(Year(dDataRef)),2)),@nHoras)
					  Else
					     nHoras := Eval(cNroHorad)
					  Endif
				      fSomaPd("P",SRD->RD_PD,nHoras,SRD->RD_VALOR,SRD->RD_MAT)
					  _TOTVENC+=Srd->Rd_Valor
			      Endif
			   Elseif SRV->RV_TIPOCOD == "2"
					  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
						  fSomaPd("D",SRD->RD_PD,Eval(cNroHorad),SRD->RD_VALOR,SRD->RD_MAT)
						  _TOTDESC+=Srd->Rd_Valor
					  Endif
			   Elseif SRV->RV_TIPOCOD == "3"
					  If (Esc # 1) .Or. (Esc == 1 .And. SRV->RV_ADIANTA == "S")
						  fSomaPd("B",SRD->RD_PD,Eval(cNroHorad),SRD->RD_VALOR,SRD->RD_MAT)
					  Endif
			   Endif
		   Endif
           If ESC == 1
			  If SRD->RD_PD == aCodFol[10,1]
			     nBaseIr := SRD->RD_VALOR
			  Endif
           ElseIf SRD->RD_PD == aCodFol[13,1]
				  nAteLim += SRD->RD_VALOR
		   Elseif SRD->RD_PD$ aCodFol[108,1]+'*'+aCodFol[17,1]
				  nBaseFgts += SRD->RD_VALOR
		   Elseif SRD->RD_PD$ aCodFol[109,1]+'*'+aCodFol[18,1]
				  nFgts += SRD->RD_VALOR
		   Elseif SRD->RD_PD == aCodFol[15,1]
				  nBaseIr += SRD->RD_VALOR
		   Elseif SRD->RD_PD == aCodFol[16,1]
				  nBaseIrFe += SRD->RD_VALOR
		   Endif
		 
		   dbSelectArea("SRD")
		   dbSkip()
	  
	    Enddo
	
	  Endif  
  
  Endif

Elseif Esc == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os codigos de pensao definidos no cadastro beneficiario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fBusCadBenef(@aCodBenef, "131",{aCodfol[172,1]})
	dbSelectArea("SRC")
	dbSetOrder(1)
	If dbSeek(_cFilial+_codmat)
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
			If SRC->RC_PD == aCodFol[22,1]
				fSomaPd("P",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
				_TOTVENC+=Src->Rc_Valor
			Elseif Ascan(aCodBenef, { |x| x[1] == SRC->RC_PD }) > 0
				fSomaPd("D",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
				_TOTDESC+=SRC->RC_VALOR
			Elseif SRC->RC_PD == aCodFol[108,1] .Or. SRC->RC_PD == aCodFol[109,1] .Or. SRC->RC_PD == aCodFol[173,1]
				fSomaPd("B",SRC->RC_PD,Eval(cNroHoras),SRC->RC_VALOR,SRC->RC_MAT)
			Endif
			
			If SRC->RC_PD == aCodFol[108,1]
				nBaseFgts := SRC->RC_VALOR
			Elseif SRC->RC_PD == aCodFol[109,1]
				nFgts     := SRC->RC_VALOR
			Endif
			dbSelectArea("SRC")
			dbSkip()
		Enddo
	Endif

Elseif Esc == 4

  If Substr(cPeriodo,1,4) == cAnoRef13     // 2 Parcela 13 Salario do Ano em Vigor. // Charles Lima - Alterado CPERIODO pois na v12 o mv_folmes foi descontinuado.  
 
	dbSelectArea("SRI")
	dbSetOrder(2)
	If dbSeek(_cFilial+_codcc+_codmat)
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRI->RI_FILIAL + SRI->RI_CC + SRI->RI_MAT
			If PosSrv( SRI->RI_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				fSomaPd("P",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR,SRI->RI_MAT)
				_TOTVENC = _TOTVENC + SRI->RI_VALOR
			Elseif SRV->RV_TIPOCOD == "2"
				fSomaPd("D",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR,SRI->RI_MAT)
				_TOTDESC = _TOTDESC + SRI->RI_VALOR
			Elseif SRV->RV_TIPOCOD == "3"
				fSomaPd("B",SRI->RI_PD,SRI->RI_HORAS,SRI->RI_VALOR,SRI->RI_MAT)
			Endif
			
			If SRI->RI_PD == aCodFol[19,1]
				nAteLim += SRI->RI_VALOR
			Elseif SRI->RI_PD$ aCodFol[108,1]
				nBaseFgts += SRI->RI_VALOR
			Elseif SRI->RI_PD$ aCodFol[109,1]
				nFgts += SRI->RI_VALOR
			Elseif SRI->RI_PD == aCodFol[27,1]
				nBaseIr += SRI->RI_VALOR
			Endif
			dbSkip()
		Enddo
	Endif
   
  Else  // 2 Parcela do 13 Salario nos Acumulados da Folha.
  
     cAnoMesRef :=cAnoRef13+"13"
  	 dbSelectArea("SRD")
     If dbSeek(_cFilial+_codmat+cAnoMesRef)
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRD->RD_FILIAL + SRD->RD_MAT
			If PosSrv( SRD->RD_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				fSomaPd("P",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR,SRD->RD_MAT)
				_TOTVENC = _TOTVENC + SRD->RD_VALOR
			Elseif SRV->RV_TIPOCOD == "2"
				fSomaPd("D",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR,SRD->RD_MAT)
				_TOTDESC = _TOTDESC + SRD->RD_VALOR
			Elseif SRV->RV_TIPOCOD == "3"
				fSomaPd("B",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR,SRD->RD_MAT)
			Endif
			
			If SRD->RD_PD == aCodFol[19,1]
				nAteLim += SRD->RD_VALOR
			Elseif SRD->RD_PD$ aCodFol[108,1]
				nBaseFgts += SRD->RD_VALOR
			Elseif SRD->RD_PD$ aCodFol[109,1]
				nFgts += SRD->RD_VALOR
			Elseif SRD->RD_PD == aCodFol[27,1]
				nBaseIr += SRD->RD_VALOR
			Endif
			dbSkip()
		Enddo
	Endif
  
  Endif

Elseif Esc == 5

	dbSelectArea("SR1")
	dbSetOrder(1)
	If dbSeek(_cFilial+_codmat)
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
			If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				fSomaPd("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,SR1->R1_MAT)
				_TOTVENC = _TOTVENC + SR1->R1_VALOR
			Elseif SRV->RV_TIPOCOD == "2"
				fSomaPd("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,SR1->R1_MAT)
				_TOTDESC = _TOTDESC + SR1->R1_VALOR
			Elseif SRV->RV_TIPOCOD == "3"
				fSomaPd("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR,SR1->R1_MAT)
			Endif
			dbskip()
		Enddo
	Endif

Endif

dbSelectArea("SRA")

aAdd(TOTVENC,{_n, _TOTVENC})
aAdd(TOTDESC,{_n, _TOTDESC})
aAdd(aImpos,{nBaseIr, nAteLim, nBaseFgts, nFgts, nBaseIrFe})


Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSomaPd   ³ Autor ³ Eduardo Clemente      ³ Data ³ 19.01.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar as Verbas no Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSomaPd(Tipo,Verba,Horas,Valor)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSomaPd(cTipo,cPd,nHoras,nValor,cMat)

Local Desc_paga
Desc_paga := DescPd(cPd,Sra->Ra_Filial)  // mostra como pagto

If cTipo # 'B'
	//--Array para Recibo Pre-Impresso
	nPos := Ascan(aLanca,{ |X| X[2] = cPd })
	If nPos == 0
		Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor,cMat,_n})
	Else
		aLanca[nPos,4] += nHoras
		aLanca[nPos,5] += nValor
	Endif
Endif

Return
    

//Função Transformada Data
///////////////////////////////////////////////////////////////////////////////////
//Static Function Transforma(dData) //Transforma as datas no formato DD/MM/AAAA  ////

//Return(StrZero(Day(dData),2) +"/"+ StrZero(Month(dData),2) +"/"+ Right(Str(Year(dData)),4))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fInicia   ºAutor  ³Eduardo Clemente    º Data ³  19/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa parametros para impressao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function  fInicia(cString,nTipoRel)

aDriver := LEDriver()

If LastKey() = 27 .Or. nLastKey = 27
	Return  .F.
Endif

SetDefault(aReturn,cString)

If LastKey() = 27 .OR. nLastKey = 27
	Return .F.
Endif

Return .T.
  

//Funcão Valida SX1
//*************************
Static Function fValidSX1()
//PutSX1( < cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSx1(cPerg,"01", "Data de Referencia     ?", "","","mv_ch1", "D",  8, 0, 0, "G", "naovazio","","","","mv_par01", "","", "", "","" ,"", "","","","", "", "","","", "", "", "")
PutSx1(cPerg,"02" , "Imprimir Recibos      ?", "","","mv_ch2", "N",  1, 0, 0, "C", "","","","","mv_par02","Adto.","","","","Folha","","","1a.Parc.","","","2a.Parc.","","","Val.Extras","","","")
PutSx1(cPerg,"03" , "De Filial             ?", "","","mv_ch3", "C",  2, 0, 0, "G", "","XM0","","","mv_par03", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"04" , "Ate Filial            ?", "","","mv_ch4", "C",  2, 0, 0, "G", "","XM0","","","mv_par04", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"05" , "De Centro de Custo    ?", "","","mv_ch5", "C",  9, 0, 0, "G", "","CTT","","","mv_par05", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"06" , "Ate Centro de Custo   ?", "","","mv_ch6", "C",  9, 0, 0, "G", "","CTT","","","mv_par06", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"07" , "De Matricula          ?", "","","mv_ch7", "C",  6, 0, 0, "G", "","SRA","","","mv_par07", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"08" , "Ate Matricula         ?", "","","mv_ch8", "C",  6, 0, 0, "G", "","SRA","","","mv_par08", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"09" , "De Nome               ?", "","","mv_ch9", "C", 30, 0, 0, "G", "","","","","mv_par09", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"10" , "Ate Nome              ?", "","","mv_chA", "C", 30, 0, 0, "G", "","","","","mv_par10", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"11" , "Mensagem 1            ?", "","","mv_chB", "C", 62, 0, 0, "G", "","","","","mv_par11", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"12" , "Mensagem 2            ?", "","","mv_chC", "C", 62, 0, 0, "G", "","","","","mv_par12", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"13" , "Mensagem 3            ?", "","","mv_chD", "C", 62, 0, 0, "G", "","","","","mv_par13", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"14" , "Mensagem 4            ?", "","","mv_chE", "C", 62, 0, 0, "G", "","","","","mv_par14", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"15" , "Mensagem 5            ?", "","","mv_chF", "C", 62, 0, 0, "G", "","","","","mv_par15", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"16" , "Situacoes a Imp.      ?", "","","mv_chG", "C",  5, 0, 0, "G", "fSituacao","","","","mv_par16", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"17" , "Categorias a Imp.     ?", "","","mv_chH", "C", 15, 0, 0, "G", "fCategoria","","","","mv_par17", "","", "","","","", "","","","", "","","","", "","","")
PutSx1(cPerg,"18" , "Imprime Bases         ?", "","","mv_chI", "N",  1, 0, 0, "C", "","","","","mv_par18", "Sim","Si","Yes","","Nao","No","No","","","","","","","","","","")
PutSx1(cPerg,"19" , "Processo              ?", "","","mv_chJ", "C",  5, 0, 0, "G", "", "RCJ", "","","mv_par19","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"20" , "Roteiro               ?", "","","mv_chK", "C",  3, 0, 0, "G", "", "", "","","mv_par20","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"21" , "Período               ?", "","","mv_chL", "C",  6, 0, 0, "G", "naovazio", "RCH", "","","mv_par21","","","","","","","","","","","","","","","","",{"Informe o período","a imprimir, ex: yyyymm"})
PutSx1(cPerg,"22" , "Imprime 2 vias        ?", "","","mv_chM", "N",  1, 0, 0, "C", "","","","","mv_par22", "Sim","Si","Yes","","Nao","No","No","","","","","","","","","","")

//PutSx1(cPerg,"19" , "Processo              ?", "","","mv_chJ", "C",  5, 0, 0, "G", "Gpr040Valid(mv_par19)", "RCJ", "","","mv_par19","","","","","","","","","","","","","","","","","")
//PutSx1(cPerg,"20" , "Roteiro               ?", "","","mv_chK", "C",  3, 0, 0, "G", "f030Roteiro() .and. Gpr040Roteiro()", "", "","","mv_par20","","","","","","","","","","","","","","","","","")
//PutSx1(cPerg,"21" , "Período               ?", "","","mv_chL", "C",  6, 0, 0, "G", "Gpr040Valid(mv_par19 + mv_par20 + mv_par21)", "RCH", "","","mv_par21","","","","","","","","","","","","","","","","",{"Informe o período","a imprimir, ex: yyyymm"})

Return
