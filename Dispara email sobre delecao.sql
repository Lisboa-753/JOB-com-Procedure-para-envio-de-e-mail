CREATE OR REPLACE PROCEDURE      PRC_ENVIA_EMAIL_AVALIACOES_DUPLICADAS AS

	TEXTO CLOB;
	ENVIA NUMBER(10);
BEGIN
	BEGIN

		TEXTO := '<html lang="pt-br">
				  <body>
				  <p>As seguintes avaliações de fornecedores duplicadas foram excluídas.</p>
				  <table>
				  <tr>
                    <th>Nota de entrada</th>
					<th>Avaliação</th>
				  </tr>';

		ENVIA := 0;


		FOR I IN (		  
                        SELECT TMP.COD_ENTRADA,
                               (SELECT LISTAGG(TMPE.CD_AVALIACAO, ', ') 
                                  FROM (SELECT ISA1.CD_AVALIACAO
                                          FROM DBAMV.AVALIACAO ISA1
                                         WHERE TMP.COD_ENTRADA = ISA1.COD_ENTRADA       
                                         ORDER BY ISA1.CD_AVALIACAO
                                         OFFSET 1 ROWS) TMPE) AS CD_AVALIACAO
                        
                          FROM (SELECT ISA.COD_ENTRADA      
                                  FROM DBAMV.AVALIACAO ISA
                                 WHERE ISA.COD_ENTRADA IS NOT NULL 
                                 GROUP BY ISA.COD_ENTRADA         
                                HAVING COUNT(1) > 1) TMP
                         )
        LOOP
            IF I.CD_AVALIACAO IS NOT NULL THEN
                TEXTO := TEXTO||'<tr>
                                    <td>'||NVL(I.COD_ENTRADA,'')||'</td>
                                    <td>'||NVL(I.CD_AVALIACAO,'')||'</td>
                                </tr>';
                ENVIA := 1;
    
                FOR X IN (
                            SELECT REGEXP_SUBSTR(I.CD_AVALIACAO, '[^, ]+', 1, LEVEL) AS CD
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR(I.CD_AVALIACAO, '[^, ]+', 1, LEVEL) IS NOT NULL
                                        )
                LOOP 
                    DELETE FROM DBAMV.HISTORICO_AVALIACAO WHERE CD_AVALIACAO = X.CD;
                    DELETE FROM DBAMV.AVALIACAO           WHERE CD_AVALIACAO = X.CD;
                END LOOP;
            END IF;
        END LOOP;          
            
		IF ENVIA = 1 THEN
			DECLARE
				TYPE CARACTERES IS TABLE OF VARCHAR2(50);
				CARACTERES_ISO CARACTERES;
				CARACTERES_UTF CARACTERES;
			BEGIN   
				CARACTERES_ISO := CARACTERES('&Aacute;','&Eacute;','&Iacute;','&Oacute;','&Uacute;','&aacute;','&eacute;','&iacute;','&oacute;','&uacute;','&Acirc;','&Ecirc;','&Ocirc;',
											 '&acirc;','&ecirc;','&ocirc;','&Agrave;','&agrave;','&Uuml;','&uuml;','&Ccedil;','&ccedil;','&Atilde;','&Otilde;','&atilde;','&otilde;',
											 '&Ntilde;','&ntilde;');
				CARACTERES_UTF := CARACTERES('Á','É','Í','Ó','Ú','á','é','í','ó','ú','Â','Ê','Ô','â','ê','ô','À','à','Ü','ü','Ç','ç','Ã','Õ','ã','õ','Ñ','ñ');

				FOR ITEM IN CARACTERES_UTF.FIRST..CARACTERES_UTF.LAST
				LOOP
					TEXTO := REPLACE(TEXTO, CARACTERES_UTF(ITEM), CARACTERES_ISO(ITEM));
					--DBMS_OUTPUT.PUT_LINE(TEXTO);
				END LOOP;
			END;

        ENVIAR_EMAIL(
        pTIPO_CONTEUDO   => 'text/html',
        pASSUNTO         => 'Avaliacoes de fornecedores',
        pDEPARTAMENTO    => 'TI',
        pEMAIL_REMETENTE => 'sistema@empresa.com',
        pNOME_DESTINO    => 'sistema@empresa.com',
        pEMAIL_DESTINO   => 'equipe@empresa.com',
        pTITULO          => TEXTO_ASSUNTO,
        pCONTEUDO        => TEXTO
    );

		END IF;

	EXCEPTION WHEN OTHERS THEN
		--DBMS_OUTPUT.PUT_LINE(TEXTO);
		DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
	END;
END;

