
-- Queries for T700 Results Excel Workbook: Validation Tab

-- 2410 Module Requisitions
SELECT t2.Noun, t1.* FROM (
SELECT 
    WUC,
    YEAR(removal_dt) AS Year,
    MONTH(removal_dt) AS Month,
    COUNT(*) AS Count
FROM
    army_aviation.t700_tow
WHERE
    removal_uic NOT IN ('W0MUAA' , 'EZ9120')
        AND removal_dt IS NOT NULL
        and removal_fcode not in ('803','804','799')
        AND NHA_PN IN ('5130T00G01', '6071T24G01')
        AND WUC IN ('04a01', '04a02a', '04a02b', '04a02c', '04a03', '04a04', '04a06a', '04a05a')
        AND YEAR(removal_dt) >= '2013'
       and tow!= 0
GROUP BY WUC , YEAR(removal_dt) , MONTH(removal_dt)
    ) t1
LEFT JOIN (select distinct(Noun), wuc from army_aviation.lcf_16 where wuc in ('04a01', '04a02a', '04a02b', '04a02c', '04a03', '04a04', '04a06a', '04a05a') and model like '%701d%') t2
ON t1.WUC = t2.WUC
;
-- See Distinct Module Name, WUC Combinations
select distinct(noun), wuc from lcf_16 where wuc in ('04a01', '04a02a', '04a02b', '04a02c', '04a03', '04a04') and model like '%701d%';


-- 2410 701D/C Requisitions - doesn't quite match up with historical
SELECT YEAR(engine_removals.removal_dt),MONTH(engine_removals.removal_dt),COUNT(*)
FROM
    (SELECT 
        wuc,pn,sn,nha_pn,nha_sn,tow,install_dt,install_uic,removal_dt,removal_fcode,removal_UIC,consq_uic, CONSQ_IACT_CD,CONSQ_COPY,consq_dt,
        IF(removal_fcode IS NULL
            OR removal_fcode in ('803','804','799')
            OR removal_UIC LIKE '%ez9120%'
            OR REMOVAL_UIC LIKE '%w0muaa%', 0, 1) causal,
        IF(consq_uic LIKE '%ez9120%'
            OR consq_uic LIKE '%w0muaa%', 1, 0) depot_consq
    FROM army_aviation.t700_tow
    WHERE nha_pn IN ('AH-64D' , 'AH-64E', 'EH-60A', 'EH-60L', 'HH-60L', 'HH-60M', 'UH-60A', 'UH-60L', 'UH-60M', 'UH-60V')
        	AND pn IN ('5130T00G01')  #'5130T00G01' '6071T24G01'
        	AND tow != 0
            AND removal_dt >= '2013-10-01') engine_removals
WHERE
    causal = 1 # Cant have been removed at depot, or have one of the exluded FCODES
    AND (depot_consq = 1 or consq_uic is null) # Must have been sent to the depot, or still have the potential to get sent to the depot
GROUP BY YEAR(engine_removals.removal_dt) , MONTH(engine_removals.removal_dt);