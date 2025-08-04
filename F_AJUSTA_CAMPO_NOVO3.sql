CREATE OR REPLACE FUNCTION DB_BASE.F_AJUSTA_CAMPO_NOVO3 (CAMPO IN VARCHAR2, TIPO IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR
IS

V_CAMPO VARCHAR2(32767);
V_REGISTRO VARCHAR2(32767);
X NUMBER;
BEGIN

    IF CAMPO IS NOT NULL THEN
        
        V_CAMPO := CAMPO;

        V_CAMPO := TRANSLATE (V_CAMPO,
                           'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿŠ',
                           'ACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy ');
         FOR X IN 0..31 LOOP
            V_CAMPO := REPLACE(V_CAMPO,CHR(X),''); 
            END LOOP;
                             
        V_CAMPO := UPPER(V_CAMPO);
        V_CAMPO := TRIM(V_CAMPO);

        CASE (TIPO IS NOT NULL)

        WHEN TIPO = '1' THEN -- NUMERO

            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^0-9]');    
         
            V_CAMPO := TRIM(V_CAMPO);

            V_REGISTRO := V_CAMPO;

        WHEN TIPO = '2' THEN -- LETRAS COM ESPACO

            V_CAMPO := REGEXP_REPLACE(V_CAMPO,'[^A-Za-z ]');
            
            V_CAMPO := TRIM(V_CAMPO);

            V_REGISTRO := V_CAMPO;
            
        WHEN TIPO = '3' THEN --EMAIL
            
            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^a-zA-Z0-9._@-]+');
                
            V_CAMPO := TRIM(V_CAMPO);

            V_REGISTRO := V_CAMPO;

        WHEN TIPO = '4' THEN --VALOR

            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^0-9,]');
            
            V_CAMPO := TRIM(V_CAMPO);
            
            V_REGISTRO := V_CAMPO;
            
        WHEN TIPO = '5' THEN --TEXTO COMUM

            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^A-Za-z0-9/(),. ]');
            
            V_CAMPO := TRIM(V_CAMPO);
            
            V_REGISTRO := V_CAMPO;

        WHEN TIPO = '6' THEN --LETRAS, NUMEROS E ESPACO

            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^A-Za-z0-9 ]');
            
            V_CAMPO := TRIM(V_CAMPO);
            
            V_REGISTRO := V_CAMPO;
            
        WHEN TIPO = '7' THEN --DATA

            V_CAMPO := REGEXP_REPLACE(V_CAMPO, '[^0-9/]');
            
            V_CAMPO := TRIM(V_CAMPO);
            
            V_REGISTRO := V_CAMPO;

        ELSE
         
            V_REGISTRO :=(V_CAMPO);

        END CASE;
    ELSE
    
        V_REGISTRO := CAMPO;
    
    END IF;   
    
    RETURN V_REGISTRO;

END;
/
