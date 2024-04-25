#include 'protheus.ch'


/*      Ponto de Entrada para realizar a c�pia do arquivo de envio CNAB para uma pasta no FTP
M�dulo: SIGAFIN
Uso:    AVB MINERA��O
Autor:  Charles Lima - Starsoft
Data:   02/03/2020 */


User Function F420CRP()

	Local _cArqOri  := ""
	Local _cArqDest := ""
	Local cNomeArq  := ""
	Local aNomesArq := {}
	Local lGeraFTP  := GETMV("MV_XFTPCNA") //Faz upload do arquivo CNAB para o FTP?
	Local _cIp      := GetMv("MV_XFTPCIP") //IP de conex�o FTP
	Local _nPort    := GetMv("MV_XFTPPOR") //Porta de conex�o FTP
	Local _cUser    := GetMv("MV_XFTPUSR") //Usu�rio de conex�o FTP
	Local _cSenha   := GetMv("MV_XFTPPSW") //Senha do usu�rio FTP
	Local _cDiCnab  := GETMV("MV_XCNABDI") //Diret�rio principal no Server Protheus com os arquivos .REM
	Local _cDicFTP  := GETMV("MV_XFTPDIR") //Diret�rio no FTP

	Private nStart  := 0

	If lGeraFTP
		_cDiCnab := "\system\cnab\"
		If ExistDir(_cDiCnab, Nil, .T.)
			ADir(_cDiCnab+"*.REM*", @aNomesArq)
			If Len(aNomesArq) > 0
				// Realiza o teste de conex�o FTP
				If !FTPCONNECT( _cIp , _nPort ,_cUser, _cSenha )
					MsgAlert( "Nao foi possivel se conectar ao FTP!!", "P.E. F420CRP" )		
					FwLogMsg("AtuDolar", /*cTransactionId*/, "AtuDolar", FunName(), "", "01","Nao foi possivel se conectar ao FTP!!", 0, (nStart - Seconds()), {})
					Return NIL	
				EndIf

				//Seleciona Diretorio no FTP
				If FTPDirChange(_cDicFTP)
					cNomeArq  := aNomesArq[Len(aNomesArq)]
					_cArqOri  := _cDiCnab+cNomeArq
					_cArqDest := _cDicFtp+cNomeArq

					//Realiza o Upload do arquivo da pasta de origem para o destino 
					If !FTPUPLOAD( _cArqOri, _cArqDest )
						MsgAlert( "Nao foi possivel realizar o upload do arquivo!!", "P.E. F420CRP" )	
						FwLogMsg("AtuDolar", /*cTransactionId*/, "AtuDolar", FunName(), "", "01","Nao foi possivel realizar o upload do arquivo!!" , 0, (nStart - Seconds()), {})
						Return NIL   	
					EndIf		
				Else
					MsgAlert( "Diretorio n�o selecionado", "P.E. F420CRP" )
				EndIf

				//Tenta desconectar do servidor ftp		
				FTPDISCONNECT()
			Else
				MsgAlert( "N�o h� arquivos .REM no diretorio: "+_cDiCnab, "P.E. F420CRP" )
			Endif
		Else
			MsgAlert( "Diretorio: "+_cDiCnab+" n�o existe", "P.E. F420CRP" )
		Endif
	Endif

Return NIL

