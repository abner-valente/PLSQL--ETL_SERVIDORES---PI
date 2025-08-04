
CREATE OR REPLACE PROCEDURE DB_BASE.IMPORTA_TB_SERVIDOR_ESTADUAL_PI(ENTRADA IN VARCHAR2,UF_IN IN VARCHAR2,COMPETENCIA_IN IN VARCHAR2)
IS
   READFILE UTL_FILE.FILE_TYPE;
   LINHA VARCHAR2(32767);
   VCAMPO VARCHAR2(32767);
   VRECORD VARCHAR2(32767);
   SEPARADOR CHAR(1);
   LAYOUT1 VARCHAR2(32767);
   V_REGISTRO VARCHAR2(32767);
   QTD INTEGER(10);
   QTD1 INTEGER(10);
   
   ERR_NUM NUMBER;
   ERR_MSG VARCHAR2(128);
   
   VSEQ NUMBER;
   VTIPO_DOC NUMBER;

    VID             VARCHAR2 (20);
    VCPFCNPJ        VARCHAR2 (20);    
    VACHOU          NUMBER;
    VPOS_SPACE      NUMBER(2);

    VSUJO           VARCHAR2(100);
    UFALLOW         VARCHAR2(200);
    
     V_MATRICULA VARCHAR2(500);
     V_NOME VARCHAR2(500);
     V_RENDA_BRUTA NUMBER;
     V_CARGO VARCHAR2(500);
     V_ORGAO VARCHAR2(500);
     V_COMPETENCIA  VARCHAR2(200);
     V_CPF_PARTE VARCHAR2(2000);
     V_CPFINFO VARCHAR2(2000);
     V_SITUACAO VARCHAR2(200);
     V_CIDADE VARCHAR(500);
     V_UF VARCHAR(200);
     V_VINCULO VARCHAR2(500);
     V_ANO VARCHAR2(200);
     V_MES VARCHAR2(200);
     
     V_TEM_INFO NUMBER;
     V_TEM_FONE NUMBER;
     
     V_EXISTE INTEGER;
     
     V_RENDA_BRUTA2 VARCHAR2(2000);
     
     V_DT_ID_ATUALIZACAO NUMBER;
     V_DATA VARCHAR2(200);


 BEGIN
    DBMS_OUTPUT.ENABLE;
    DBMS_OUTPUT.ENABLE (buffer_size => NULL);

   READFILE := UTL_FILE.FOPEN('REP',ENTRADA,'R');
   
   SEPARADOR := ';';
   QTD := 0;
   QTD1 := 0;
   VACHOU := 0;
   VSEQ := 0;
   UTL_FILE.GET_LINE (READFILE, LINHA);--pega cabeçalho

 LOOP
    
     V_MATRICULA :='';
     V_NOME :='';
     V_RENDA_BRUTA :=0;
     V_CARGO :='';
     V_ORGAO :='';
     V_COMPETENCIA  := COMPETENCIA_IN;
     V_CPF_PARTE :='';
     V_CPFINFO :='';
     V_SITUACAO :='';
     V_CIDADE :='';
     V_UF := UF_IN;
     V_ANO :='';
     V_MES :='';
     V_VINCULO := '';
     
     V_EXISTE := 0;
     
     V_RENDA_BRUTA2 := 0;
     
     QTD := QTD+1;
  
  IF INSTR(ENTRADA,'PI') > 0 THEN
   
    UTL_FILE.GET_LINE (READFILE, LINHA);
    LINHA := REPLACE(UPPER(LINHA),'"','');
    LINHA := REPLACE(UPPER(LINHA),'-','');
    LINHA := REPLACE(UPPER(LINHA),'.','');
    --LINHA := REPLACE(UPPER(LINHA),',','.');
    LINHA := REPLACE(UPPER(LINHA),'R$','');
    LINHA := DB_BASE.F_AJUSTA_CAMPO_NOVO3(LINHA, 8);
 
     V_MATRICULA := NULL;
     V_NOME := TRIM(PEGA_CAMPO(LINHA,1,';'));
     V_RENDA_BRUTA := TRIM(PEGA_CAMPO(LINHA,8,';'));
     V_CARGO := TRIM(PEGA_CAMPO(LINHA,3,';'));
     V_ORGAO := TRIM(PEGA_CAMPO(LINHA,4,';'));
     --V_COMPETENCIA  :='092020';
     V_CPF_PARTE := TRIM(PEGA_CAMPO(LINHA,2,';'));
     V_CPFINFO :='';
     V_SITUACAO := 'ATIVO';
     V_CIDADE := TRIM(PEGA_CAMPO(LINHA,7,';'));
     --V_UF := 'AM';
     V_ANO :='';
     V_MES :='';
     V_VINCULO := NULL;
     
     V_EXISTE :=0;
     V_TEM_INFO := 0;
     V_TEM_FONE := 0;
     
     SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') INTO V_DATA FROM DUAL;
     
     SELECT ID INTO V_DT_ID_ATUALIZACAO FROM DB_BASE.DM_DATA WHERE DATA = TO_DATE(V_DATA,'DD/MM/YYYY');
     
     FOR RCLI IN (SELECT 1 AS TEM 
                  FROM DB_BASE.TB_SERVIDOR_ESTADUAL_PI T 
                    WHERE RENDA = V_RENDA_BRUTA
                    AND T.COMPETENCIA = V_COMPETENCIA 
                    AND T.UF = V_UF 
                    AND T.ORGAO = V_ORGAO
                    AND T.CARGO = V_CARGO
                    AND T.NOME = V_NOME 
                    AND T.CPF_PARTE = V_CPF_PARTE
                    AND ROWNUM <= 1)
     LOOP
     V_EXISTE := RCLI.TEM;
     END LOOP;
     
     IF V_EXISTE = 1 THEN
     
       DELETE  FROM DB_BASE.TB_SERVIDOR_ESTADUAL_PI T 
                    WHERE RENDA = V_RENDA_BRUTA
                    AND T.COMPETENCIA = V_COMPETENCIA 
                    AND T.UF = V_UF 
                    AND T.ORGAO = V_ORGAO
                    AND T.CARGO = V_CARGO
                    AND T.NOME = V_NOME 
                    AND T.CPF_PARTE = V_CPF_PARTE;
        
        V_EXISTE := 0;
     
     END IF;
     
     IF V_EXISTE =0 THEN
         --VERIFICAR SE TEM NA INFO E NAO SEJA HOMONIMO
         FOR RCLIINFO IN ( 
                          SELECT COUNT(DISTINCT CPFCNPJ) AS QTDE 
                          FROM INFO_PESSOAL 
                          WHERE SUBSTR(CPFCNPJ,4,6) = DB_BASE.F_AJUSTA_CAMPO_NOVO3(V_CPF_PARTE,1) 
                          AND NOME = V_NOME
                          AND LENGTH(CPFCNPJ) = 11
                         )
         LOOP
         
         V_TEM_INFO := RCLIINFO.QTDE;
         
             IF V_TEM_INFO = 1 THEN
             
              FOR RINFO IN (
                           SELECT CPFCNPJ AS CPF 
                           FROM INFO_PESSOAL 
                           WHERE SUBSTR(CPFCNPJ,4,6) = DB_BASE.F_AJUSTA_CAMPO_NOVO3(V_CPF_PARTE,1) 
                           AND NOME = V_NOME
                           AND LENGTH(CPFCNPJ) = 11
                           AND ROWNUM <=1
                          )
              LOOP
              
              V_CPFINFO := RINFO.CPF;
              
              END LOOP;
             
             END IF;
         
         END LOOP;
                    
         IF V_CPFINFO IS NULL THEN
         
             --VERIFICAR SE TEM NA TELEFONES E NAO SEJA HOMONIMO
             FOR RCLIINFO IN ( 
                              SELECT COUNT(DISTINCT CPFCGC) AS QTDE 
                              FROM TELEFONES_NEW 
                              WHERE SUBSTR(CPFCGC,4,6) = DB_BASE.F_AJUSTA_CAMPO_NOVO3(CPFCGC,1) 
                              AND PROPRIETARIO = V_NOME
                              AND LENGTH(CPFCGC) = 11
                             )
             LOOP
             
             V_TEM_FONE := RCLIINFO.QTDE;
             
                 IF V_TEM_FONE = 1 THEN
                 
                  FOR RFONE IN (
                               SELECT  CPFCGC AS CPF 
                               FROM TELEFONES_NEW 
                               WHERE SUBSTR(CPFCGC,4,6) = DB_BASE.F_AJUSTA_CAMPO_NOVO3(CPFCGC,1) 
                               AND PROPRIETARIO = V_NOME 
                               AND LENGTH(CPFCGC) = 11
                               AND ROWNUM <= 1
                              )
                  LOOP
                  
                  V_CPFINFO := RFONE.CPF;
                  
                  END LOOP;
                 
                 END IF;
             
             END LOOP;
             
         END IF;   
     
       INSERT INTO DB_BASE.TB_SERVIDOR_ESTADUAL_PI (
                   MATRICULA, NOME, RENDA, 
                   CARGO, ORGAO, COMPETENCIA, 
                   CPF_PARTE, CPF_INFO, SITUACAO, 
                   CIDADE, UF, VINCULO, 
                   DATA_ID_ATUALIZACAO) 
          VALUES ( V_MATRICULA, V_NOME, V_RENDA_BRUTA, 
                   V_CARGO, V_ORGAO, V_COMPETENCIA, 
                   V_CPF_PARTE, V_CPFINFO, V_SITUACAO, 
                   V_CIDADE, V_UF, V_VINCULO, 
                   V_DT_ID_ATUALIZACAO);
                     
      QTD1 := QTD1 + 1;
     
     END IF;
      
     IF QTD1 = 500 THEN
      
         COMMIT;
         QTD1 := 1;
      
     END IF;
     
    
    end if;
   
   
   
  end loop;   
   

    

 


 COMMIT;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
    UTL_FILE.FCLOSE (READFILE); 
    DBMS_OUTPUT.PUT_LINE ('Parei no registro ' || QTD );
              COMMIT;
   
   WHEN OTHERS
  THEN
     UTL_FILE.FCLOSE (READFILE);
     DBMS_OUTPUT.PUT_LINE ('Parei no registro ' || QTD );
     ROLLBACK;
        ERR_MSG := SUBSTR(SQLERRM, 1 , 128);
        ERR_NUM := SQLCODE;     
        INSERT INTO DB_BASE.LOGERRPROC VALUES ( SYSDATE, 'DB_BASE.IMPORTA_TB_SERVIDOR_ESTADUAL'||';'||ENTRADA||';'||Linha||';'||QTD, ERR_MSG, ERR_NUM );
        COMMIT;
        RAISE_APPLICATION_ERROR (-20001,'Ocorreu um erro inserperado, por favor entrar em contato com o Suporte');


  END;
/
