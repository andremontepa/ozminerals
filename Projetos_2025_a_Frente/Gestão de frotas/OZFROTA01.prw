#include"Protheus.ch"
#include"tbiconn.ch"

// TPA  - Etapas
// TPF  - Manutenção Padrão
// TPH  - Etapas de Manutenção?

User Function zImpEtapa()
    Local aArea    := GetArea()
    Public cArqOri := ""
  
    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )
      
    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)
          
        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| fImpetapa() }, "Importando...")
        Else
            MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
        EndIf
    EndIf
      
    RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 | Layout csv : produto / localm / custo                                         |
 *-------------------------------------------------------------------------------*/
  Static Function fImpetapa()
    Local aArea      := GetArea()
    Local cArqLog    := "fImpetapa_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0

    Local cEtapa     := ""   // Código da Etapa
    Local cDescr     := ""   // Descrição da Etapa
    Local cAreae     := ""   // Área
    Local cOpcao     := 0    // Opção da Etapa
    Local cTempo     := ""   // Tempo Médio
       
    Local oArquivo
    Local aLinhas
    Local aLinha     := {}
    Local aItem := {}
    Public lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Public lMsErroAuto := .f. //necessario a criacao
    Public cDirLog    := GetTempPath() + "importacao\"
    Public cLog       := ""
      
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
If (oArquivo:Open())
    //Se não for fim do arquivo
    If ! (oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            //Enquanto tiver linhas
        While (oArquivo:HasLine())
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")
                if substring(cLinAtu,1,1)=";"
                exit 
                endif

                //Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
    If ! "etapa" $ Lower(cLinAtu) .and. substring(cLinAtu,1,1)<>";"
  
                    //Zera as variaveis
                    aItem := {}

                        cEtapa     := aLinha[1]  // Código da Etapa
                        cDescr     := aLinha[2]  // Descrição da Etapa
                        cAreae     := aLinha[3]  // Área - Pesquisar STD Área de Manutenção
                        cTempo     := aLinha[4]  // Tempo Médio
                        cOpcao     := aLinha[5]  // Opção da Etapa
       DbSelectArea("STD")
	   DbSetOrder(1)
       If (Dbseek(xFilial("STD")+cAreae))         
              
                DbSelectArea("TPA")
			    DbSetOrder(1)
                If !(Dbseek(xFilial("TPA")+cEtapa)) // Verifica se a Etapa já existe na Filial
  		        	RecLock("TPA", .T.)
		        	TPA->TPA_FILIAL  := cFilAnt
		        	TPA->TPA_ETAPA   := cEtapa
		        	TPA->TPA_DESCRI  := cDescr
                    TPA->TPA_CDAREA  := cAreae
		        	TPA->TPA_TEMPOM  := cTempo   
		        	TPA->TPA_OPCOES  := cOpcao  
                    TPA->TPA_BLOQPT  := "2"
                else
                    RecLock("TPA", .F.)
		        	TPA->TPA_DESCRI  := cDescr
                    TPA->TPA_CDAREA  := cAreae
		        	TPA->TPA_TEMPOM  := cTempo   
		        	TPA->TPA_OPCOES  := cOpcao 
                    TPA->TPA_BLOQPT  := "2"
                Endif
			        TPA->( MsUnlock() )
      else
      msgalert("Item não Importado Área ->> "+cAreae+" não cadastrada!!")
      Endif
      Endif  
      EndDo
    
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                MemoWrite(cDirLog + cArqLog, cLog)
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
    Else
    MsgStop("Arquivo não tem conteúdo!", "Atenção")
    EndIf
    //Fecha o arquivo
    oArquivo:Close()
Else
MsgStop("Arquivo não pode ser aberto!", "Atenção")
EndIf
  
RestArea(aArea)
Return

