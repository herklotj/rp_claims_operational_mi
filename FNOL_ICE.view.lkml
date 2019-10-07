view: fnol_ice {
  derived_table: {
    sql:
      select
            *
      from
        (
        SELECT
              wk.start_date as notification_week
               ,case when (total_incurred_exc_rec - ws_incurred) > 0 then 1.00 else 0.00 end as reported_clm
               ,case when (total_incurred - ws_incurred) > 0.00 then 1.00 else 0.00 end as non_nil_clm
               ,case when (total_incurred - ws_incurred) <= 0.00 and ws_incurred = 0.00 then 1.00 else 0.00 end as nil_clm
               ,case when (tp_incurred) > 0.00 then 1.00 else 0.00 end as tp_non_nil_clm
               ,case when (ad_incurred) > 0.00 then 1.00 else 0.00 end as ad_non_nil_clm
               ,case when (ad_incurred) > 0.00 and (tp_incurred) > 0.00 then 1.00 else 0.00 end as ad_tp_non_nil
               ,case when (ad_incurred) > 0.00 and (tp_incurred) = 0.00 then 1.00 else 0.00 end as ad_non_nil_tp_nil
               ,case when (ad_incurred) = 0.00 and (tp_incurred) > 0.00 then 1.00 else 0.00 end as tp_non_nil_ad_nil
               ,*

        FROM
            (
            select
                claimnum
                ,min(notificationdate) as notificationdate
                ,sum(total_incurred) as total_incurred
                ,sum(total_incurred_exc_rec) as total_incurred_exc_rec
                ,sum(case when peril='AD' then total_incurred else 0 end) as AD_Incurred
                ,sum(case when peril='TP' then total_incurred else 0 end) as TP_Incurred
                ,sum(case when peril='OT' then total_incurred else 0 end) as OT_Incurred
                ,sum(case when peril='PI' then total_incurred else 0 end) as PI_Incurred
                ,sum(case when peril='WS' then total_incurred else 0 end) as WS_Incurred
            from
                  ice_aa_claim_financials
            where to_date(notificationdate) = transaction_date  and versionenddate > transaction_date
            group by claimnum
            ) clm
        left join
            aauser.calendar_week wk
            ON clm.notificationdate >= wk.start_date
            AND clm.notificationdate <= wk.end_date
        where notificationdate >= '2017-01-01'
        )a

      ;;}

      dimension: notification_week  {
        type: date_week
        sql:notification_week ;;

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

    }
