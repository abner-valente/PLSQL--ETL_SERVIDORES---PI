CREATE OR REPLACE FUNCTION DB_BASE.F_PEGA_CAMPO(TEXTO IN VARCHAR2,NCAMPO IN NUMERIC, SEPARADOR IN VARCHAR2 ) 

RETURN VARCHAR2
IS

--   SEPARADOR CHAR(1);
   PEDACO NUMERIC(10);
   VCAMPO VARCHAR2(32767);
   VPOSICAO NUMERIC(10);
    
BEGIN

   /* Le a linha do arquivo Texto e separa apenas o Telefone para ler o registro */

--   SEPARADOR := ';';
   PEDACO := 0;
   VCAMPO := '';
   
 
   FOR VPOSICAO IN 1..LENGTH(TEXTO) LOOP 
       
                 IF SUBSTR(TEXTO,VPOSICAO,1) <> SEPARADOR THEN
             
                   VCAMPO := VCAMPO || SUBSTR(TEXTO,VPOSICAO,1);
                 
                 ELSE
                 
                   PEDACO := PEDACO + 1;
                 
                   IF PEDACO = NCAMPO THEN
                         
                         EXIT;               
                   
                   END IF;
                   
                   VCAMPO := '';
                   
                 END IF; 
       
    END LOOP;
   
   VCAMPO := REPLACE(VCAMPO, CHR(10), '');
   VCAMPO := REPLACE(VCAMPO, CHR(13), '');  
   
   RETURN TRIM(VCAMPO);
   
END;
/
