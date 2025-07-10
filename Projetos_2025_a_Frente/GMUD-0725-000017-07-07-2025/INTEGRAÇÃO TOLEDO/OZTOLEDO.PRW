    //Bibliotecas
#Include "Protheus.ch"
 
//Constantes
#Define MAX_BUFFER     22     //Máximo de caracter por linha (buffer)
#Define MSECONDS_WAIT  5000   //Tempo de espera
 
/*/{Protheus.doc} zTstBalan
Integração Balança TOLEDO
@ Julio Martins
@ CRMServices
@ Maio / 2025
@ Release 1.0
/*/
 
User Function OZBalanca()
    Local nPesoRet := 0
     
    nPesoRet := u_OZLeBalanca("TOLEDO")
     
    MSGAlert("Peso Lido: "+cValToChar(nPesoRet))
Return nPesoRet
 

 
User Function OZLeBalanca(cMarca)
    Local nPesoRet
    Local cPorta    := ""
    Local cVelocid  := ""
    Local cParidade := ""
    Local cBits     := ""
    Local cStopBits := ""
    Local cFluxo    := ""
    Local nTempo    := ""
    Local cConfig   := ""
    Local lRet      := .T.
    Local nH        := 0
    Local cBuffer   := ""
    Local nPosFim   := 0
    Local nPosIni   := 0
    Local nX        := 0
    Local cPesoLido := ""
    Default cMarca  := ""
     
    //Se houver marca
    If ! Empty(cMarca)
        cMarca := Upper(Alltrim(cMarca))
         
        //Pegando a porta padrão da balança
        cPorta    := SuperGetMV("MV_X_PORTA",.F.,"COM1")
         
        //Modelo Confiança
        If (cMarca=="CONFIANCA")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F., "1")      //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo
             
        //Jundiaí
        ElseIf (cMarca == "JUNDIAI")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F., "0")      //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo
             
        //Toledo
        ElseIf (cMarca == "TOLEDO")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
         
        //Líder
        ElseIf (cMarca == "LIDER")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
         
        //Qualquer balança que utilize porta serial
        Else
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"9600")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"n")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
        EndIf
         
        //Se a marca da balança for LIDER
        If cMarca == "LIDER"
            //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
            cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
                 
            //Guarda resultado se houve abertura da porta
            lRet := MSOpenPort(@nH,cConfig)
             
            //Se não conseguir abrir a porta, mostra mensagem e finaliza
            If !lRet
                MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                        "<br><b>Porta:</b> "        +cPorta+;
                        "<br><b>Velocidade:</b> "    +cVelocid+;
                        "<br><b>Paridade:</b> "        +cParidade+;
                        "<br><b>Bits:</b> "            +cBits+;
                        "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
                             
            Else
                //Realiza a leitura
                For nX := 1 To 50
                    //Obtendo o tempo de espera antes de iniciar a leitura da balança    
                    Sleep(nTempo)
                    MSRead(nH,@cBuffer)
                     
                    //Se a linha retornada for igual ao tamanho limite, encerra o laço
                    If Len(AllTrim(cBuffer)) == MAX_BUFFER
                        Exit
                    EndIf
                Next nX    
                 
                //Verifica onde começa o "E" e diminui 1 caracter
                nPosFim := At("E", cBuffer) - 1
                 
                //Obtendo apenas o peso da balança
                cPesoLido := StrTran(AllTrim(SubStr(cBuffer,2,nPosFim)),".","")
            EndIf
             
            //Encerra a conexão com a porta
            MSClosePort(nH,cConfig)
         
        //Se for a Toledo
        ElseIf cMarca == "TOLEDO"
            //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
            cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
             
            //Guarda resultado se houve abertura da porta
            lRet := MSOpenPort(@nH,cConfig)
            lOk  := .T.
             
            //Se não conseguir abrir a porta, tenta mais uma vez, remapeando
            If ! lRet
                //Força o fechamento e abertura da porta novamente
                WaitRun("NET USE "+cPorta+": /DELETE")
                WaitRun("NET USE "+cPorta+" ")
                 
                lOk := MSOpenPort(@nH,cConfig)
                 
                If !lOk
                    MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                            "<br><b>Porta:</b> "        +cPorta+;
                            "<br><b>Velocidade:</b> "    +cVelocid+;
                            "<br><b>Paridade:</b> "        +cParidade+;
                            "<br><b>Bits:</b> "            +cBits+;
                            "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
                EndIf
            EndIf
             
            If lOk
                //Inicializa balança
                MsWrite(nH,CHR(5))
                nTaman := 16
                 
                //Realiza a leitura
                For nX := 1 To 50
                    //Obtendo o tempo de espera antes de iniciar a leitura da balança e realiza a leitura    
                    Sleep(nTempo)
                    MSRead(nH,@cBuffer)
                     
                    //Obtendo os caracteres inciais
                    cBuffer := AllTrim(SubStr(AllTrim(cBuffer),1,nTaman))
                     
                    //Se a linha retornada for igual ao tamanho limite
                    If Len(AllTrim(cBuffer)) >= nTaman
                        Exit
                    EndIf
                Next nX    
                 
                 
                //Verifica onde começa o "q" e soma 2 espaços
                nPosIni := At("q",cBuffer)+2
     
                //Obtendo apenas o peso da balança
                cPesoLido := SubStr(cBuffer,nPosIni,nPosIni+3)
            EndIf
             
            //Encerra a conexão com a porta
            MSClosePort(nH,cConfig)
        EndIf    
         
        //Converte o peso obtido para inteiro e o atribui a variavel de retorno
        nPesoRet := Val(cPesoLido)
         
    //Outras balanças
    Else
        //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
        cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
     
        //Guarda resultado se houve abertura da porta
        lRet := msOpenPort(@nH,cConfig)
     
        //Se não conseguir abrir a porta, mostra mensagem e finaliza
        If(!lRet)
            //Se for barra, tentar na confiança, depois na jundiai
            MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                    "<br><b>Porta:</b> "        +cBPorta+;
                    "<br><b>Velocidade:</b> "    +cBVeloc+;
                    "<br><b>Paridade:</b> "        +cBParid+;
                    "<br><b>Bits:</b> "            +cBBits+;
                    "<br><b>Stop Bits:</b> "    +cBStop,"Atenção")
            cLido := 0
        EndIf
     
        //Se estiver OK
        If lRet
            If (cMarca == "JUNDIAI" .Or. cMarca == "CONFIANCA")
                //Mandando mensagem para a porta COM
                msWrite(nH,Chr(5))
                Sleep(nTempo)
     
                //Pegando o tempo final
                cSegNor:=Time()
                cSegAcr:=SubStr(Time(),1,5)+":"+cValToChar(Val(SubStr(Time(),7,2)) + nTempo)
     
                If (cMarca == "JUNDIAI")
                    //Enquanto os tempos forem diferentes
                    While(cSegNor != cSegAcr)
                        //Lendo os dados
                        msRead(nH,@cBuffer)
     
                        //Se não estiver em branco
                        if(!Empty(cBuffer))
                            cLido := Alltrim(cBuffer)
                        EndIf
     
                        //Atualizando o tempo
                        cSegNor:=SubStr(cSegNor,1,5)+":"+cValToChar(Val(SubStr(cSegNor,7,2)) + 1)
                    EndDo
                     
                //Senão, se for confiança, enquanto o tamanho for menor, ler o conteúdo
                ElseIf (cMarca == "CONFIANCA")
                    cLido := ''
                    nCont := 1
                     
                    //Enquanto os tempos forem diferentes
                    While(Len(cLido) < 16)
                        //Lendo os dados
                        msRead(nH,@cBuffer)
                        Sleep(200)
     
                        //Somando o valor lido com o buffer
                        cLido += cBuffer
     
                        //Aumentando o contador
                        nCont++
                        If nCont >= 30
                            If MsgYesNo('Houve <b>30 tentativas</b> de ler o peso, deseja parar?','Atenção')
                                cLido:=Space(17)
                                Exit
                            Else
                                nCont := 1
                            EndIf
                        EndIf
     
                    EndDo
                EndIf
     
                cLido   := Upper(cLido)
                nPosFim := (At('K',cLido) - 1)
 
                //Pegando a Posição Inicial
                For nAux:=1 To Len(cLido)
                    //Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
                    If(SubStr(cLido,nAux,1) $ '0123456789.')
                        nPosIni:=nAux
                        Exit
                    EndIf
                Next
                 
                nPesoRet := Val(cLido)
            EndIf
        EndIf
         
        msClosePort(nH,cConfig)
    EndIf
     
Return nPesoRet
