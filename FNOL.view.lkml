view: fnol {
 derived_table: {
  sql:
  select
        *
  from
    (
    SELECT
          wk.start_date as notification_week
           ,ROW_NUMBER() OVER (PARTITION BY claimnum ORDER BY claimnum,effectivedate) AS trncount
           ,case when (total_inc_exc_rec - ws_inc_exc_rec) > 0 then 1.00 else 0.00 end as reported_clm
           ,case when (total_incurred - ws_incurred) > 0.00 then 1.00 else 0.00 end as non_nil_clm
           ,case when (total_incurred - ws_incurred) <= 0.00 and ws_incurred = 0.00 then 1.00 else 0.00 end as nil_clm
           ,case when (tp_incurred) > 0.00 then 1.00 else 0.00 end as tp_non_nil_clm
           ,case when (ad_incurred) > 0.00 then 1.00 else 0.00 end as ad_non_nil_clm
           ,case when (ad_incurred) > 0.00 and (tp_incurred) > 0.00 then 1.00 else 0.00 end as ad_tp_non_nil
           ,case when (ad_incurred) > 0.00 and (tp_incurred) = 0.00 then 1.00 else 0.00 end as ad_non_nil_tp_nil
           ,case when (ad_incurred) = 0.00 and (tp_incurred) > 0.00 then 1.00 else 0.00 end as tp_non_nil_ad_nil
           ,*

    FROM
        aapricing.v_claims_transactions clm
    left join
        aauser.calendar_week wk
        ON clm.notificationdate >= wk.start_date
        AND clm.notificationdate <= wk.end_date
    where notificationdate >= '2017-01-01'
    )a
where trncount = 1
  ;;}

dimension: notification_week  {
  type: date_week
  sql:notification_week ;;

}

measure: reported_claims {
  type: sum
  sql:  reported_clm ;;
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

measure: tp_only_proportion {
  type: number
  sql: ${tp_only_claims}/${reported_claims} ;;
  value_format: "0%"
}

measure: ad_only_proportion {
  type: number
  sql: ${ad_only_claims}/${reported_claims} ;;
  value_format: "0%"
}

measure: ad_and_tp_proportion {
  type: number
  sql: ${ad_and_tp_claims}/${reported_claims} ;;
  value_format: "0%"
  }

measure: fault_claim_proportion {
  type: number
  sql: ${fault_claims}/${reported_claims} ;;
  value_format: "0%"
  }

  }
