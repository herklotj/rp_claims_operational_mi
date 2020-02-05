view: ice_claims {
 derived_table: {
  sql:

  select
      to_timestamp(exp.acc_week) as acc_week
      ,date_part('week',exp.acc_week) as acc_week_number
      ,date_part('year',exp.acc_week) as acc_year
      ,earned_premium
      ,exposure
      ,in_force
      ,total_reported_exc_ws_inwk
      ,clm.*
  from

     (select
        polnum
        ,scheme
        ,acc_week
        ,sum(exposure) as exposure
        ,sum(in_force) as in_force
        ,sum(earned_premium) as earned_premium
      from
        v_prem_earned_wk
    group by polnum,scheme,acc_week
    )exp

  left join
    (select
                      polnum,
                      wk.start_date as acc_week,
                      SUM(case when tp_incurred > 0 then 1 else 0 end) AS tp_count,
                      SUM(case when ad_incurred > 0 then 1 else 0 end) AS ad_count,
                      SUM(case when pi_incurred > 0 then 1 else 0 end) AS pi_count,
                      SUM(case when ot_incurred > 0 then 1 else 0 end) AS ot_count,
                      SUM(case when ws_incurred > 0 then 1 else 0 end) AS ws_count,
                      SUM(case when total_incurred > 0 then 1 else 0 end) AS total_count,
                      SUM(case when (total_incurred - ws_incurred) > 0 then 1 else 0 end) AS total_count_exc_ws,
                      SUM(CASE WHEN notificationdate <= wk.end_date and ws_incurred > 0 THEN 1 else 0 END) AS ws_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and ot_incurred > 0 THEN 1 else 0 END) AS ot_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and pi_incurred > 0 THEN 1 else 0 END) AS pi_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and tp_incurred > 0 THEN 1 else 0 END) AS tp_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and ad_incurred > 0 THEN 1 else 0 END) AS ad_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and (total_incurred) > 0 THEN 1 else 0 END) AS total_count_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and (total_incurred - ws_incurred) > 0 THEN 1 else 0 END) AS total_count_exc_ws_inwk,
                      SUM(CASE WHEN notificationdate <= wk.end_date and (total_incurred_exc_rec- ws_incurred) > 0 THEN 1 else 0 END) AS total_reported_exc_ws_inwk
    from
      (
        select
          claimnum
          ,policy_number as polnum
          ,min(incidentdate) as incidentdate
          ,min(notificationdate) as notificationdate
          ,sum(total_incurred) as total_incurred
          ,sum(total_incurred_exc_rec) as total_incurred_exc_rec
          ,sum(case when peril='AD' then total_incurred else 0 end) as AD_Incurred
          ,sum(case when peril='TP' then total_incurred else 0 end) as TP_Incurred
          ,sum(case when peril='OT' then total_incurred else 0 end) as OT_Incurred
          ,sum(case when peril='PI' then total_incurred else 0 end) as PI_Incurred
          ,sum(case when peril='WS' then total_incurred else 0 end) as WS_Incurred
        from
            ice_aa_claim_financials cf
        left join
            ice_aa_pol2clm p2c
            on cf.claimnum = p2c.claim_number
        where versionenddate='2999-12-31'
        group by claimnum,policy_number
      ) c
    left join
      aauser.calendar_week wk
      ON c.incidentdate >= wk.start_date
      AND c.incidentdate <= wk.end_date
    group by  c.polnum,wk.start_date
    )clm
    on exp.polnum = clm.polnum and clm.acc_week = exp.acc_week
  WHERE exp.acc_week <= to_date(sysdate)
   ;;
}


dimension_group: accident_week {
  type: time
  timeframes: [
    week
  ]
  sql: ${TABLE}.acc_week ;;
}

dimension: accident_week_number {
  type: number
  sql: ${TABLE}.acc_week_number ;;
}

dimension: accident_year {
  type: number
  sql: ${TABLE}.acc_year ;;
}

measure: exposure {
  type: sum
  sql: exposure;;
}

measure: reported_clms_inwk {
  type: sum
  sql: total_reported_exc_ws_inwk;;
}

measure: fault_clms_inwk {
  type: sum
  sql: total_count_exc_ws_inwk;;
}

measure: reported_clms_inwk_freq {
  type: number
  sql: ${reported_clms_inwk} / nullif(${exposure},0);;
  value_format: "0.0%"
}
measure: fault_clms_inwk_freq {
  type: number
  sql: ${fault_clms_inwk} / nullif(${exposure},0);;
  value_format: "0.0%"
}

}
