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
           ,case when (total_inc_exc_rec - ws_inc_exc_rec) > 0 then 1 else 0 end as reported_clm
           ,case when (total_incurred - ws_incurred) > 0 then 1 else 0 end as non_nil_clm
           ,case when (total_incurred - ws_incurred) <= 0 and ws_incurred = 0 then 1 else 0 end as nil_clm
           ,case when (tp_incurred) > 0 then 1 else 0 end as tp_non_nil_clm
           ,case when (ad_incurred) > 0 then 1 else 0 end as ad_non_nil_clm
           ,case when (ad_incurred) > 0 and (tp_incurred) > 0 then 1 else 0 end as ad_tp_non_nil
           ,case when (ad_incurred) > 0 and (tp_incurred) = 0 then 1 else 0 end as ad_non_nil_tp_nil
           ,case when (ad_incurred) = 0 and (tp_incurred) > 0 then 1 else 0 end as tp_non_nil_ad_nil
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

measure: non_nil_proportion {
  type:  number
  sql: ${fault_claims}/${reported_claims} ;;

}

measure: proportion_with_ad_element {
  type: number
  sql:sum(ad_non_nil_clm)/${reported_claims} ;;
}

measure: proportion_with_tp_element {
  type: number
  sql: sum(tp_non_nil_clms)/${reported_claims} ;;
}

measure: proportion_with_ad_tp_element {
  type: number
  sql: sum(ad_tp_non_nil) / ${reported_claims} ;;

}

measure: proportion_with_ad_only {
  type: number
  sql: sum(ad_non_nil_tp_nil)/${reported_claims} ;;
}

measure: tp_only_claims {
  type:  sum
  sql:  tp_non_nil_ad_nil;;

}

measure: proportion_with_tp_only {
  type: number
  sql: ${tp_only_claims}/${reported_claims}
  value_format: "0.0%"
  ;;
}


  }
