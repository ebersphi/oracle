 
--info: list all deprecated/desupported settings, hidden/undocumented settings, non default settings  
 
SET LINESIZE 250
SET PAGESIZE 9999
COLUMN name            FORMAT A50
COLUMN value           FORMAT A50
COLUMN isdefault       FORMAT A10
COLUMN isdeprecated    FORMAT A10

SELECT
  CURRENT_TIMESTAMP                         AS now_ts,
  ( SELECT name FROM v$database )           AS db_name,
  SYS_CONTEXT('USERENV','SESSION_USER')     AS current_user,
  SYS_CONTEXT('USERENV','SERVER_HOST')      AS server_host
FROM dual;


PROMPT === 1. Parameters explicitly set and deprecated/desupported ===
SELECT name,       value,       isdefault,       isdeprecated
FROM   v$parameter
WHERE  isdeprecated = 'TRUE'  AND  isdefault = 'FALSE'
ORDER BY name;
 from v$obsolete_parameter
 ;
PROMPT
PROMPT === 2. Parameters starting with underscore (hidden/undocumented) that are non-default ===
SELECT a.ksppinm name, c.ksppstvl value, b.KSPPSTDF "Default_Value",
       decode(bitand(a.ksppiflg/256,1),1,'TRUE','FALSE') IS_SESSION_MODIFIABLE,
       decode(bitand(a.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') IS_SYSTEM_MODIFIABLE
FROM   x$ksppi a,
       x$ksppcv b,
       x$ksppsv c
WHERE  a.indx = b.indx
AND    a.indx = c.indx
AND    a.ksppinm LIKE '/_%' escape '/'
AND    b.KSPPSTDF= 'FALSE'
;
/* does not return __% parameters
SELECT name,       value,       isdefault
FROM   v$parameter
WHERE  name LIKE '\_%' ESCAPE '\'  AND  isdefault = 'FALSE'
ORDER BY name;
*/
PROMPT
PROMPT === 3. All parameters explicitly set (non-default) in the sp_file ===
SELECT name,       value,       isdefault,       isdeprecated
FROM   v$parameter
WHERE  isdefault = 'FALSE'
ORDER BY name;
