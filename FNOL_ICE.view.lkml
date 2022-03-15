view: fnol_ice {
  derived_table: {
    sql:
SELECT wk.start_date AS notification_week,
       b.notificationdate -DAY(b.notificationdate) +1 AS notification_month,
       CASE WHEN ws_incurred > 0 or incident_type_code = 'W' THEN 0.00 ELSE 1.00 END AS reported_clm,
       CASE WHEN (total_incurred - ws_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS non_nil_clm,
       CASE WHEN (total_incurred - ws_incurred) <= 0.00 AND ws_incurred = 0.00 THEN 1.00 ELSE 0.00 END AS nil_clm,
       CASE WHEN (tp_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS tp_non_nil_clm,
       CASE WHEN (ad_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS ad_non_nil_clm,
       CASE WHEN (pi_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS pi_non_nil_clm,
       CASE WHEN (ad_incurred) > 0.00 AND (tp_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS ad_tp_non_nil,
       CASE WHEN (ad_incurred) > 0.00 AND (tp_incurred) = 0.00 THEN 1.00 ELSE 0.00 END AS ad_non_nil_tp_nil,
       CASE WHEN (ad_incurred) = 0.00 AND (tp_incurred) > 0.00 THEN 1.00 ELSE 0.00 END AS tp_non_nil_ad_nil,
       policy_number,
       CASE WHEN substr (policy_number,6,1) = 1 THEN '103' WHEN substr (policy_number,6,1) = 2 THEN '173' ELSE '102' END AS scheme,
       b.claimnum,
       b.notificationdate,
       COALESCE(total_incurred,0) AS total_incurred,
       COALESCE(total_incurred_exc_rec,0) AS total_incurred_exc_rec,
       COALESCE(ad_incurred,0) AS ad_incurred,
       COALESCE(tp_incurred,0) AS tp_incurred,
       COALESCE(ot_incurred,0) AS ot_incurred,
       COALESCE(pi_incurred,0) AS pi_incurred,
       COALESCE(ws_incurred,0) AS ws_incurred,
       incident_type_code
FROM (SELECT claim_number AS claimnum,
             policy_number,
             to_date(notification_date) AS notificationdate,
             incident_type_code
      FROM ice_mv_claim_acc_snapshot
      WHERE claim_position_code != 'ERROR') b
  LEFT JOIN (SELECT claimnum,
                    MIN(to_date (notificationdate)) AS notificationdate,
                    SUM(total_incurred) AS total_incurred,
                    SUM(total_incurred_exc_rec) AS total_incurred_exc_rec,
                    SUM(CASE WHEN peril = 'AD' THEN total_incurred ELSE 0 END) AS AD_Incurred,
                    SUM(CASE WHEN peril = 'TP' THEN total_incurred ELSE 0 END) AS TP_Incurred,
                    SUM(CASE WHEN peril = 'OT' THEN total_incurred ELSE 0 END) AS OT_Incurred,
                    SUM(CASE WHEN peril = 'PI' THEN total_incurred ELSE 0 END) AS PI_Incurred,
                    SUM(CASE WHEN peril = 'WS' THEN total_incurred ELSE 0 END) AS WS_Incurred
             FROM ice_aa_claim_financials
             WHERE to_date(notificationdate) = transaction_date
             AND   versionenddate >= transaction_date
             GROUP BY claimnum) clm ON b.claimnum = clm.claimnum
  LEFT JOIN aauser.calendar_week wk
         ON b.notificationdate >= wk.start_date
        AND b.notificationdate <= wk.end_date
WHERE b.notificationdate >= '2017-01-01'
      ;;}

      dimension: notification_week  {
        type: date_week
        sql:notification_week ;;

      }

      dimension: notification_month  {
        type: date_month
        sql:notification_month ;;

      }

  dimension: scheme_number  {
    type: string
    sql:scheme ;;

  }

      measure: reported_claims {
        type: sum
        sql:  reported_clm ;;
      }

      measure: reported_claims_aapache {
        type: number
        sql: sum(case when notificationdate < '2019-09-30' then reported_clm else 0 end);;
      }

      measure: reported_claims_ice {
        type: number
        sql: sum(case when notificationdate >= '2019-09-30' then reported_clm else 0 end);;
      }

      measure: fault_claims  {
        type: sum
        sql: non_nil_clm ;;
      }

      measure: tp_only_claims {
        type:  sum
        sql:  tp_non_nil_ad_nil;;
      }

      measure: ad_only_claims {
        type:  sum
        sql:  ad_non_nil_tp_nil;;
      }

      measure: ad_and_tp_claims {
        type:  sum
        sql:  ad_tp_non_nil;;
      }

      measure: tp_only_proportion_ice {
        type: number
        sql: sum(case when notificationdate >= '2019-09-30' then tp_non_nil_ad_nil else 0 end)/sum(case when notificationdate >= '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }

      measure: tp_only_proportion_aapache {
        type: number
        sql: sum(case when notificationdate < '2019-09-30' then tp_non_nil_ad_nil else 0 end)/sum(case when notificationdate < '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }



      measure: ad_only_proportion_ice {
        type: number
        sql:  sum(case when notificationdate >= '2019-09-30' then ad_non_nil_tp_nil else 0 end)/sum(case when notificationdate >= '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }

      measure: ad_only_proportion_aapache {
        type: number
        sql:  sum(case when notificationdate < '2019-09-30' then ad_non_nil_tp_nil else 0 end)/sum(case when notificationdate < '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }


      measure: ad_and_tp_proportion_ice {
        type: number
        sql: sum(case when notificationdate >= '2019-09-30' then ad_tp_non_nil else 0 end)/sum(case when notificationdate >= '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }

      measure: ad_and_tp_proportion_aapache {
        type: number
        sql: sum(case when notificationdate < '2019-09-30' then ad_tp_non_nil else 0 end)/sum(case when notificationdate < '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }

      measure: fault_claim_proportion_aapache {
        type: number
        sql: sum(case when notificationdate < '2019-09-30' then non_nil_clm else 0 end) / sum(case when notificationdate < '2019-09-30' then reported_clm else null end) ;;
        value_format: "0%"
      }


      measure: fault_claim_proportion_ice {
        type: number
        sql: sum(case when notificationdate >= '2019-09-30' then non_nil_clm else 0 end) / sum(case when notificationdate >= '2019-09-30' then reported_clm else null end);;
        value_format: "0%"
  }

    measure: average_initial_incurred_ice {
      type: number
      sql: sum(case when notificationdate >= '2019-09-30' then (total_incurred - ws_incurred) else 0 end) / nullif(sum(case when notificationdate >= '2019-09-30' then non_nil_clm else 0 end),0);;
      value_format_name: "gbp"
  }

  measure: average_initial_incurred_aapache {
    type: number
    sql: sum(case when notificationdate < '2019-09-30' then (total_incurred - ws_incurred) else 0 end) / nullif(sum(case when notificationdate < '2019-09-30' then non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

  measure: average_initial_ad_ice {
    type: number
    sql: sum(case when notificationdate >= '2019-09-30' then ad_incurred else 0 end) / nullif(sum(case when notificationdate >= '2019-09-30' then ad_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

  measure: average_initial_ad_aapache {
    type: number
    sql: sum(case when notificationdate < '2019-09-30' then ad_incurred else 0 end) / nullif(sum(case when notificationdate < '2019-09-30' then ad_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

  measure: average_initial_tp_ice {
    type: number
    sql: sum(case when notificationdate >= '2019-09-30' then tp_incurred else 0 end) / nullif(sum(case when notificationdate >= '2019-09-30' then tp_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

  measure: average_initial_tp_aapache {
    type: number
    sql: sum(case when notificationdate < '2019-09-30' then tp_incurred else 0 end) / nullif(sum(case when notificationdate < '2019-09-30' then tp_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }
  measure: average_initial_pi_ice {
    type: number
    sql: sum(case when notificationdate >= '2019-09-30' then pi_incurred else 0 end) / nullif(sum(case when notificationdate >= '2019-09-30' then pi_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

  measure: average_initial_pi_aapache {
    type: number
    sql: sum(case when notificationdate < '2019-09-30' then pi_incurred else 0 end) / nullif(sum(case when notificationdate < '2019-09-30' then pi_non_nil_clm else 0 end),0);;
    value_format_name: "gbp"
  }

    }
