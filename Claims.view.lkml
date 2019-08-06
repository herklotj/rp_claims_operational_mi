view: claims {
  derived_table: {
    sql:

select
    to_timestamp(exp.acc_week) as acc_week
    ,earned_premium
    ,exposure
    ,in_force
    ,total_reported_exc_ws_inwk
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
                    SUM(tp_count) AS tp_count,
                    SUM(ad_count) AS ad_count,
                    SUM(pi_count) AS pi_count,
                    SUM(ot_count) AS ot_count,
                    SUM(ws_count) AS ws_count,
                    SUM(total_count) AS total_count,
                    SUM(total_count_exc_ws) AS total_count_exc_ws,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN ws_count END) AS ws_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN ot_count END) AS ot_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN pi_count END) AS pi_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN tp_count END) AS tp_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN ad_count END) AS ad_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN total_count END) AS total_count_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN total_count_exc_ws END) AS total_count_exc_ws_inwk,
                    SUM(CASE WHEN notificationdate <= wk.end_date THEN reported_count_exc_ws END) AS total_reported_exc_ws_inwk
  from
    v_claims_latest_position c
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

measure: exposure {
    type: sum
    sql: exposure;;
    }

measure: reported_clms_inwk {
    type: sum
    sql: total_reported_exc_ws_inwk;;
  }

  measure: reported_clms_inwk_freq {
    type: number
    sql: ${reported_clms_inwk} / nullif(${exposure},0);;
    value_format: "0.0%"
  }
}
