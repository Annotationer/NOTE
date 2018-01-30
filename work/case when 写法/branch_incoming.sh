#!/bin/sh

. ~/apphome/aic_export.sh
db2 connect to $GMPDB user $GMPUSR using $GMPPWD
db2 set schema=$GMPSMA



#��TBL_ACM_GLTPRP ���뵽 TBL_ACM_GLTHST
#db2 "insert into tbl_acm_glthst (select * from tbl_acm_gltprp)"
UPPER_DATE=`db2 -x select BUSINESS_DATE from TM_SYSTEM_STATUS`
if [ $1 = D ]
then
    LOWER_DATE=$UPPER_DATE
else
    #�µ�ǰһ�������
    [ `date -d "${UPPER_DATE} +2 days" "+%d"` != '01' ] && exit
    case $1 in
        "M")
            FIRST_DATE=`date -d "${UPPER_DATE}" "+%Y%m01"`
            LOWER_DATE=`date -d "${FIRST_DATE} -1 days" "+%Y%m%d"`
            ;;
        "S")        [ `date -d "${UPPER_DATE}" "+%m"` != '03' ] &&
            [ `date -d "${UPPER_DATE}" "+%m"` != '06' ] &&
            [ `date -d "${UPPER_DATE}" "+%m"` != '09' ] &&
            [ `date -d "${UPPER_DATE}" "+%m"` != '12' ] && exit

        FIRST_DATE=`date -d "${UPPER_DATE} -2 months" "+%Y%m01"`
        LOWER_DATE=`date -d "${FIRST_DATE} -1 days" "+%Y%m%d"`
        ;;
    "H")
        [ `date -d "${UPPER_DATE}" "+%m"` != '06' ] &&
            [ `date -d "${UPPER_DATE}" "+%m"` != '12' ] && exit

        FIRST_DATE=`date -d "${UPPER_DATE} -5 months" "+%Y%m01"`
        LOWER_DATE=`date -d "${FIRST_DATE} -1 days" "+%Y%m%d"`
        ;;
    "Y")
        [ `date -d "${UPPER_DATE}" "+%m"` != '12' ] && exit

        FIRST_DATE=`date -d "${UPPER_DATE} -11 months" "+%Y%m01"`
        LOWER_DATE=`date -d "${FIRST_DATE} -1 days" "+%Y%m%d"`
        ;;
    *)
        exit
        ;;
esac
fi

echo "��ʼʱ��:,${LOWER_DATE},��ֹʱ��:,${UPPER_DATE}" >> branch_incoming.$$.txt
echo "In script execution, wait... "
db2 "

SELECT 
---��ռ��
E.BRANCH_CODE AS ֧�к�,
E.BRANCH_NAME AS ֧������,
E.CONSUMPTION_FEE AS ��������������,
ROUND(CAST(E.CONSUMPTION_FEE AS DOUBLE)/E.TATOL,4) AS ��������������ռ��,
E.INTEREST AS ��Ϣ����,
ROUND(CAST(E.INTEREST AS DOUBLE)/E.TATOL,4) AS ��Ϣ����ռ��,
E.OVERDUE_FINE AS ΥԼ������,
ROUND(CAST(E.OVERDUE_FINE AS DOUBLE)/E.TATOL,4) AS ΥԼ������ռ��,
E.OVERRUN_FEE AS ���޷�����,
ROUND(CAST(E.OVERRUN_FEE AS DOUBLE)/E.TATOL,4) AS ���޷�����ռ��,
E.CASH_AND_TRANSFER_FEE AS �ֽ�ת�˽�����������,
ROUND(CAST(E.CASH_AND_TRANSFER_FEE AS DOUBLE)/E.TATOL,4) AS �ֽ�ת�˽�����������ռ��,
E.YEAR_FEE AS �������,
ROUND(CAST(E.YEAR_FEE AS DOUBLE)/E.TATOL,4) AS �������ռ��,
E.URGENT_EXPRESS_FEE AS �Ӽ�������,
ROUND(CAST(E.URGENT_EXPRESS_FEE AS DOUBLE)/E.TATOL,4) AS �Ӽ�������ռ��,
E.REPORT_LOSS_FEE AS ��ʧ����������,
ROUND(CAST(E.REPORT_LOSS_FEE AS DOUBLE)/E.TATOL,4) AS ��ʧ����������ռ��,
E.REPLACE_CARD_FEE AS ������������,
ROUND(CAST(E.REPLACE_CARD_FEE AS DOUBLE)/E.TATOL,4) AS ������������ռ��,
E.REPRINT_BILL AS ������˵�����,
ROUND(CAST(E.REPRINT_BILL AS DOUBLE)/E.TATOL,4) AS ������˵�����ռ��,
E.CARD_FEE AS ��Ƭ��_ת����,
ROUND(CAST(E.CARD_FEE AS DOUBLE)/E.TATOL,4) AS ����Ƭ��_ת����ռ��,
E.BILL_INSTALLMENT_FEE AS �˵���������������,
ROUND(CAST(E.BILL_INSTALLMENT_FEE AS DOUBLE)/E.TATOL,4) AS �˵���������������ռ��,
E.CASH_INSTALLMENT_OUT_LIMIT AS ������ֽ��������������,
ROUND(CAST(E.CASH_INSTALLMENT_OUT_LIMIT AS DOUBLE)/E.TATOL,4) AS ������ֽ��������������ռ��,
E.CASH_INSTALLMENT_IN_LIMIT AS ������ֽ��������������,
ROUND(CAST(E.CASH_INSTALLMENT_IN_LIMIT AS DOUBLE)/E.TATOL,4) AS ������ֽ��������������ռ��,
E.CONSUMPTION_INSTALLMENT_FEE AS ���ѷ�������������,
ROUND(CAST(E.CONSUMPTION_INSTALLMENT_FEE AS DOUBLE)/E.TATOL,4) AS ���ѷ�������������ռ��,
E.SMS_INCOME AS ������Ϣ����֪ͨ����,
ROUND(CAST(E.SMS_INCOME AS DOUBLE )/E.TATOL,4) AS ������Ϣ����֪ͨ����ռ��,
E.OTHER_INCOME AS ��������,
ROUND(CAST(E.OTHER_INCOME AS DOUBLE)/E.TATOL,4) AS ��������ռ��,
E.TATOL AS ������
FROM ( 
	SELECT 
		tm_branch.BRANCH_CODE,tm_branch.BRANCH_NAME,D.CONSUMPTION_FEE, 
			(
			D.NORMAL_INTEREST+ case when K.OUT_TO_IN is null then  0 else  K.OUT_TO_IN end  - case when L.IN_TO_OUT is null  then 0 else L.IN_TO_OUT end   + case when  v.big_age_payment is null then 0 else  v.big_age_payment  end 
			)  AS INTEREST , 
		(D.OVERDUE_FINE -case when q.POST_AMT is null then 0 else  q.POST_AMT end ) as OVERDUE_FINE, 
		 D.OVERRUN_FEE ,  D.CASH_AND_TRANSFER_FEE, 
		(D.YEAR_FEE - case when M.PAY_OTHER is null then 0 else  M.PAY_OTHER  end ) AS YEAR_FEE,
		 D.URGENT_EXPRESS_FEE, D.REPORT_LOSS_FEE, D.REPLACE_CARD_FEE, D.REPRINT_BILL,
		d.CARD_FEE, 
		  D.BILL_INSTALLMENT_FEE, D.CASH_INSTALLMENT_OUT_LIMIT, D.CASH_INSTALLMENT_IN_LIMIT, D.CONSUMPTION_INSTALLMENT_FEE, D.SMS_INCOME, D.OTHER_INCOME,
		
		---���ܺ�
		CASE WHEN (D.CONSUMPTION_FEE+
		(D.NORMAL_INTEREST+ case when K.OUT_TO_IN is null then  0 else  K.OUT_TO_IN end  - case when L.IN_TO_OUT is null  then 0 else L.IN_TO_OUT end   + case when  v.big_age_payment is null then 0 else  v.big_age_payment  end) 
		+(D.OVERDUE_FINE -case when q.POST_AMT is null then 0 else  q.POST_AMT end) 
		+ D.OVERRUN_FEE + D.CASH_AND_TRANSFER_FEE+
		(D.YEAR_FEE - case when M.PAY_OTHER is null then 0 else  M.PAY_OTHER  end)
		+D.URGENT_EXPRESS_FEE+D.REPORT_LOSS_FEE+D.REPLACE_CARD_FEE+D.REPRINT_BILL
		+d.CARD_FEE
		+D.BILL_INSTALLMENT_FEE+D.CASH_INSTALLMENT_OUT_LIMIT+D.CASH_INSTALLMENT_IN_LIMIT+D.CONSUMPTION_INSTALLMENT_FEE+D.SMS_INCOME+D.OTHER_INCOME) = 0 THEN 1 
		ELSE (
		(D.NORMAL_INTEREST+ case when K.OUT_TO_IN is null then  0 else  K.OUT_TO_IN end  - case when L.IN_TO_OUT is null  then 0 else L.IN_TO_OUT end   + case when  v.big_age_payment is null then 0 else  v.big_age_payment  end) 
		+(D.OVERDUE_FINE -case when q.POST_AMT is null then 0 else  q.POST_AMT end) 
		+ D.OVERRUN_FEE + D.CASH_AND_TRANSFER_FEE+
		(D.YEAR_FEE - case when M.PAY_OTHER is null then 0 else  M.PAY_OTHER  end)
		+D.URGENT_EXPRESS_FEE+D.REPORT_LOSS_FEE+D.REPLACE_CARD_FEE+D.REPRINT_BILL
		+d.CARD_FEE
		+D.BILL_INSTALLMENT_FEE+D.CASH_INSTALLMENT_OUT_LIMIT+D.CASH_INSTALLMENT_IN_LIMIT+D.CONSUMPTION_INSTALLMENT_FEE+D.SMS_INCOME+D.OTHER_INCOME) 
		END AS TATOL ---�ܼ�
		
		FROM  CPS.TM_BRANCH tm_branch left join 
		(
			---���������ȡ����---			
			SELECT 
			C.BRANCH_CODE AS  BRANCH_CODE,  --֧�к�,

			

			SUM(CASE WHEN O.TXN_CODE IN('G203') THEN O.TXN_AMT ELSE 0 END) AS  CONSUMPTION_FEE, ---��������������,

			SUM(CASE WHEN O.TXN_CODE  IN ('G115','G117','G119','G121','G159','T605','T607','T609') THEN 
			(SELECT SUM(G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.CPS_TXN_SEQ FROM GLP.TM_TXN_GL_HST F WHERE F.AGE_CD < '5') H ON CHAR(G.TXN_SEQ) = H.CPS_TXN_SEQ WHERE G.TXN_SEQ = O.TXN_SEQ)
			WHEN O.TXN_CODE IN ( 'T606','T608','T610') THEN 
			(SELECT SUM(G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.CPS_TXN_SEQ FROM GLP.TM_TXN_GL_HST F WHERE F.AGE_CD < '5') H ON CHAR(G.TXN_SEQ) = H.CPS_TXN_SEQ WHERE G.TXN_SEQ = O.TXN_SEQ)
			ELSE 0 END ) AS NORMAL_INTEREST,  ---������Ϣ����

			---SUM(CASE WHEN O.TXN_CODE IN (  'G101','G103','G105','G123','G153','G155','G157','G241','G243','G275','G126','T504','T526','T534','T604','T704','T710') THEN O.TXN_AMT WHEN O.TXN_CODE IN ( 'T503','T525','T533','T603','T703','T709') THEN -O.TXN_AMT ELSE 0 END)  AS INTEREST,  ---��Ϣ����, 

			SUM(CASE WHEN O.TXN_CODE IN( 'T510','G111') THEN O.TXN_AMT WHEN O.TXN_CODE = 'T509' THEN -O.TXN_AMT ELSE 0 END) AS OVERDUE_FINE,---ΥԼ������,

			SUM(CASE WHEN O.TXN_CODE = 'T508' THEN O.TXN_AMT WHEN O.TXN_CODE = 'T507' THEN -O.TXN_AMT ELSE 0 END) AS OVERRUN_FEE,---���޷�����,

			SUM(CASE WHEN O.TXN_CODE  IN ('G115','G117','G119','G121','G159','T605','T607','T609') THEN (SELECT SUM(G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.ACCT_NO FROM CPS.TM_ACCOUNT F WHERE F.BLOCK_CODE <> 'W') H ON G.ACCT_NO = H.ACCT_NO WHERE G.TXN_SEQ = O.TXN_SEQ) WHEN O.TXN_CODE IN ( 'T606','T608','T610') THEN (SELECT SUM(-G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.ACCT_NO FROM CPS.TM_ACCOUNT F WHERE F.BLOCK_CODE <> 'W') H ON G.ACCT_NO = H.ACCT_NO WHERE G.TXN_SEQ = O.TXN_SEQ) ELSE 0 END ) AS  CASH_AND_TRANSFER_FEE, ----�ֽ�ת�˽�����������

			SUM(CASE WHEN O.TXN_CODE IN( 'G107','T505') THEN (SELECT SUM(G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.ACCT_NO FROM CPS.TM_ACCOUNT F WHERE F.BLOCK_CODE <> 'W') H ON G.ACCT_NO = H.ACCT_NO WHERE G.TXN_SEQ = O.TXN_SEQ) WHEN O.TXN_CODE IN( 'G506','T506') THEN (SELECT SUM(-G.TXN_AMT) FROM CPS.TM_TXN_HST G LEFT JOIN (SELECT F.ACCT_NO FROM CPS.TM_ACCOUNT F WHERE F.BLOCK_CODE <> 'W') H ON G.ACCT_NO = H.ACCT_NO WHERE G.TXN_SEQ = O.TXN_SEQ) ELSE 0 END) AS YEAR_FEE,---�������,

			SUM(CASE WHEN O.TXN_CODE IN( 'G139','T537') THEN O.TXN_AMT WHEN O.TXN_CODE ='T538' THEN -O.TXN_AMT ELSE 0 END) AS URGENT_EXPRESS_FEE,---�Ӽ�������,

			SUM(CASE WHEN O.TXN_CODE IN( 'T857','T341','T517') THEN O.TXN_AMT WHEN O.TXN_CODE ='T518' THEN -O.TXN_AMT ELSE 0 END) AS REPORT_LOSS_FEE,---��ʧ����������,

			SUM(CASE WHEN O.TXN_CODE ='G145' THEN O.TXN_AMT ELSE 0 END) AS REPLACE_CARD_FEE,---������������,

			SUM(CASE WHEN O.TXN_CODE IN('T853','T513') THEN O.TXN_AMT WHEN O.TXN_CODE = 'T514' THEN -O.TXN_AMT ELSE 0 END) AS REPRINT_BILL,---������˵�����,

			SUM(CASE WHEN O.TXN_CODE ='G291' THEN O.TXN_AMT WHEN O.TXN_CODE ='G292' THEN O.TXN_AMT else 0 END) AS CARD_FEE,---��Ƭ��_ת����,

			SUM(CASE WHEN  O.TXN_CODE IN ('G143','G144','T514') THEN (SELECT SUM(D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN( O.REF_NBR) AND  D.LOAN_TYPE = 'B') WHEN  O.TXN_CODE IN ('T513') THEN (SELECT SUM(-D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR ) AND D.LOAN_TYPE = 'B') ELSE 0 END) AS BILL_INSTALLMENT_FEE,---�˵���������������,

			SUM(CASE WHEN  O.TXN_CODE IN ('G249','T711','G243') THEN (SELECT SUM(D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR) AND  D.LOAN_TYPE = 'J') WHEN  O.TXN_CODE IN ('T712','G258') THEN (SELECT SUM(-D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR ) AND D.LOAN_TYPE = 'J') ELSE 0 END) AS CASH_INSTALLMENT_OUT_LIMIT,---������ֽ��������������,

			SUM(CASE WHEN  O.TXN_CODE IN ('G113','G135','T705','T707') THEN (SELECT SUM(D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR) AND  D.LOAN_TYPE = 'C') WHEN  O.TXN_CODE IN ('T706','T708') THEN (SELECT SUM(-D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR ) AND D.LOAN_TYPE = 'C') ELSE 0 END) AS CASH_INSTALLMENT_IN_LIMIT,---������ֽ��������������,

			SUM(CASE WHEN  O.TXN_CODE IN ('G113','G135','T705','T707') THEN (SELECT SUM(D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR) AND  D.LOAN_TYPE = 'R') WHEN  O.TXN_CODE IN ('T706','T708') THEN (SELECT SUM(-D.LOAN_INIT_FEE1) FROM CPS.TM_LOAN D WHERE D.REF_NBR IN(  O.REF_NBR ) AND D.LOAN_TYPE = 'R') ELSE 0 END) AS CONSUMPTION_INSTALLMENT_FEE,---���ѷ�������������,

			SUM(CASE WHEN O.TXN_CODE ='G129' THEN O.TXN_AMT ELSE 0 END) AS SMS_INCOME,---������Ϣ����֪ͨ����

			0 AS OTHER_INCOME  ---�������룬�ֱ𲻳���ȡ0

			FROM CPS.TM_TXN_HST O LEFT JOIN (
			SELECT A.ACCT_NO,B.BRANCH_CODE FROM CPS.TM_ACCOUNT A LEFT JOIN CPS.TM_BRANCH B ON A.OWNING_BRANCH = B.BRANCH_CODE ) C ON O.ACCT_NO = C.ACCT_NO WHERE O.TXN_DATE >='${LOWER_DATE}' AND O.TXN_DATE <='${UPPER_DATE}' GROUP BY C.BRANCH_CODE
		) D  on tm_branch.branch_code = d.branch_code 
			
		--����ת��������+---
		left  JOIN  
		(
		SELECT C.BRANCH_CODE,SUM(case when I.OUT_TO_IN is null then 0 else i.out_to_in end ) AS OUT_TO_IN  FROM ( 
		SELECT H1.ACCT_NO,SUM(H1.POST_AMT) AS OUT_TO_IN FROM GLP.TM_TXN_GL_HST H1 WHERE H1.CPS_TXN_SEQ IN (
		SELECT H2.CPS_TXN_SEQ FROM GLP.TM_TXN_GL_HST H2 WHERE H2.TXN_CODE = 'G201' AND H2.AGE_GROUP in ('G','J') AND H2.BUCKET_TYPE = 'INTEREST' AND H2.POST_DATE >='${LOWER_DATE}' AND H2.POST_DATE <='${UPPER_DATE}' )  AND H1.TXN_CODE = 'G202' AND H1.AGE_GROUP in ('D','B') GROUP BY H1.ACCT_NO  ) I LEFT JOIN (
		SELECT A.ACCT_NO,B.BRANCH_CODE,B.BRANCH_NAME FROM CPS.TM_ACCOUNT A LEFT JOIN CPS.TM_BRANCH B ON A.OWNING_BRANCH = B.BRANCH_CODE ) C ON I.ACCT_NO = C.ACCT_NO GROUP BY C.BRANCH_CODE
		) K  ON tm_branch.BRANCH_CODE = K.BRANCH_CODE

		left JOIN 
		---����ת����----
		(
		SELECT C.BRANCH_CODE,SUM(case when J.IN_TO_OUT is null then 0 else J.IN_TO_OUT end) AS IN_TO_OUT  FROM ( 
		SELECT H3.ACCT_NO,SUM(H3.POST_AMT) AS IN_TO_OUT FROM GLP.TM_TXN_GL_HST H3 WHERE H3.CPS_TXN_SEQ IN (
		SELECT H4.CPS_TXN_SEQ FROM GLP.TM_TXN_GL_HST H4 WHERE H4.TXN_CODE = 'G201' AND H4.AGE_GROUP='D' AND H4.BUCKET_TYPE = 'INTEREST' AND H4.POST_DATE >='${LOWER_DATE}' AND H4.POST_DATE <='${UPPER_DATE}' )  AND H3.TXN_CODE = 'G202' AND H3.AGE_GROUP='G' GROUP BY H3.ACCT_NO  ) J LEFT JOIN (
		SELECT A.ACCT_NO,B.BRANCH_CODE,B.BRANCH_NAME FROM CPS.TM_ACCOUNT A LEFT JOIN CPS.TM_BRANCH B ON A.OWNING_BRANCH = B.BRANCH_CODE ) C ON J.ACCT_NO = C.ACCT_NO GROUP BY C.BRANCH_CODE
		) L ON tm_branch.BRANCH_CODE = L.BRANCH_CODE

		left JOIN 
		---����������--
		(
		SELECT C.BRANCH_CODE,SUM(case when TM_PAYMENT_HST.PAY_AMT is null then 0 else TM_PAYMENT_HST.PAY_AMT end) AS PAY_OTHER FROM CPS.TM_PAYMENT_HST TM_PAYMENT_HST  LEFT JOIN (
		SELECT A.ACCT_NO,B.BRANCH_CODE,B.BRANCH_NAME FROM CPS.TM_ACCOUNT A LEFT JOIN CPS.TM_BRANCH B ON A.OWNING_BRANCH = B.BRANCH_CODE ) C ON TM_PAYMENT_HST.ACCT_NO = C.ACCT_NO WHERE TM_PAYMENT_HST.BNP_TYPE ='CTDCARDFEE' AND TM_PAYMENT_HST.BATCH_DATE >='${LOWER_DATE}' AND TM_PAYMENT_HST.BATCH_DATE <='${UPPER_DATE}' GROUP BY C.BRANCH_CODE
		) M  ON tm_branch.BRANCH_CODE = M.BRANCH_CODE

		left JOIN 
		---����ΥԼ��---
		(
		SELECT  C.BRANCH_CODE,sum(case when TM_TXN_GL_HST.POST_AMT is null then 0 else TM_TXN_GL_HST.POST_AMT end ) as post_amt FROM GLP.TM_TXN_GL_HST TM_TXN_GL_HST  LEFT JOIN (
		SELECT A.ACCT_NO,B.BRANCH_CODE,B.BRANCH_NAME FROM CPS.TM_ACCOUNT A LEFT JOIN CPS.TM_BRANCH B ON A.OWNING_BRANCH = B.BRANCH_CODE ) C on TM_TXN_GL_HST.acct_no = c.acct_no WHERE TM_TXN_GL_HST.CPS_TXN_SEQ IN (
		SELECT TM_TXN_GL_HST2.CPS_TXN_SEQ FROM GLP.TM_TXN_GL_HST TM_TXN_GL_HST2 WHERE TM_TXN_GL_HST2.TXN_CODE = 'G290' AND TM_TXN_GL_HST2.BUCKET_TYPE = 'LATEPAYMENTCHARGE' AND TM_TXN_GL_HST2.POST_DATE >= '${LOWER_DATE}' AND TM_TXN_GL_HST2.POST_DATE <='${UPPER_DATE}') AND TM_TXN_GL_HST.TXN_CODE= 'G291' 
		GROUP BY C.BRANCH_CODE
		) q ON tm_branch.BRANCH_CODE = q.BRANCH_CODE

		---�����仹��
		left JOIN 
		(
		select branch.branch_code, sum(case when TM_TXN_GL_HST.POST_AMT is null then 0 else TM_TXN_GL_HST.POST_AMT end ) as big_age_payment from 
		 glp.TM_TXN_GL_HST TM_TXN_GL_HST  left join cps.TM_BRANCH branch on TM_TXN_GL_HST.OWNING_BRANCH = branch.BRANCH_CODE   where TM_TXN_GL_HST.TXN_CODE   in (
		select TM_PRM_OBJECT.PARAM_KEY from bmp.TM_PRM_OBJECT  TM_PRM_OBJECT  WHERE TM_PRM_OBJECT.param_class = 'com.allinfinance.cps.param.def.TxnCd' and ( TM_PRM_OBJECT.param_object like '%<logicMod>L30</logicMod>%' or TM_PRM_OBJECT.param_object like '%<logicMod>L32</logicMod>%')
		) and TM_TXN_GL_HST.AGE_CD > '5'  and TM_TXN_GL_HST.POST_DATE >= '${LOWER_DATE}' AND TM_TXN_GL_HST.POST_DATE <='${UPPER_DATE}' group by branch.branch_code
		) v on v.branch_code = tm_branch.branch_code
		
) E 
---�޳����������ݵĻ�����Ϣ
where E.TATOL is not null"  >> branch_incoming.$$.txt

sed '/^ *$\|record(s) selected\|-----/d' branch_incoming.$$.txt |
awk '{
        for(i=1; i<=NF; i++)
        {
            if($i~/^[-+0-9.e]+$/)
            {
                {
                    printf "%s,",$i;
                }
                Total[i] += $i;
            }
            else printf "%s,", $i;
        }
        printf "\n";
    }
	END{ printf(" ,ȫ�кϼ�,")
        for(i=3; i<=NF; i+=2)
        {
			if (i == NF) printf("%.3f", Total[NF]);
            else 
			{
				if (Total[NF] == 0) printf("0,0,");
				else printf("%.3f,%.3f,", Total[i], Total[i]/Total[NF]*100);
			}
        }
    }' > branch_incoming.$$.csv
db2 connect reset

echo "End of script execution"
