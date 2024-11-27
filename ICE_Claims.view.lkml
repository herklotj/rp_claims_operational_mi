view: ice_claims {
  derived_table: {
    sql:
    SELECT to_timestamp(exp.acc_week) AS acc_week,
           date_part('week',exp.acc_week) AS acc_week_number,
          date_part('month',exp.acc_week) AS acc_month_number,
           date_part('year',exp.acc_week) AS acc_year,
           earned_premium,
           exposure,
           in_force,
           clm.*
    FROM (SELECT polnum,
                 scheme,
                 acc_week,
                 SUM(exposure) AS exposure,
                 SUM(inforce) AS in_force,
                 SUM(earned_premium) AS earned_premium
          FROM v_ice_prem_earned_wk
          GROUP BY polnum,
                   scheme,
                   acc_week) EXP
      LEFT JOIN (SELECT b.polnum,
                        wk.start_date AS acc_week,
                        SUM(CASE WHEN tp_incurred > 0 THEN 1 ELSE 0 END) AS tp_count,
                        SUM(CASE WHEN ad_incurred > 0 THEN 1 ELSE 0 END) AS ad_count,
                        SUM(CASE WHEN pi_incurred > 0 THEN 1 ELSE 0 END) AS pi_count,
                        SUM(CASE WHEN ot_incurred > 0 THEN 1 ELSE 0 END) AS ot_count,
                        SUM(CASE WHEN ws_incurred > 0 THEN 1 ELSE 0 END) AS ws_count,
                        SUM(CASE WHEN total_incurred > 0 THEN 1 ELSE 0 END) AS total_count,
                        SUM(CASE WHEN (total_incurred - ws_incurred) > 0 THEN 1 ELSE 0 END) AS total_count_exc_ws,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND ws_incurred > 0 THEN 1 ELSE 0 END) AS ws_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND ot_incurred > 0 THEN 1 ELSE 0 END) AS ot_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND pi_incurred > 0 THEN 1 ELSE 0 END) AS pi_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND tp_incurred > 0 THEN 1 ELSE 0 END) AS tp_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND ad_incurred > 0 THEN 1 ELSE 0 END) AS ad_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND (total_incurred) > 0 THEN 1 ELSE 0 END) AS total_count_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND (total_incurred - ws_incurred) > 0 THEN 1 ELSE 0 END) AS total_count_exc_ws_inwk,
                        SUM(CASE WHEN notificationdate <= wk.end_date AND incident_type_code != 'W' THEN 1 ELSE 0 END) AS total_reported_exc_ws_inwk
                 FROM (SELECT claim_number AS claimnum,
                              policy_number AS polnum,
                              to_date(notification_date) AS notificationdate,
                              to_date(incident_date) AS incidentdate,
                              incident_type_code
                       FROM dbuser.ice_mv_claim_acc_snapshot
                       WHERE claim_position_code != 'ERROR') b
                   LEFT JOIN (SELECT claimnum,
                                     SUM(total_incurred) AS total_incurred,
                                     SUM(total_incurred_exc_rec) AS total_incurred_exc_rec,
                                     SUM(CASE WHEN peril = 'AD' THEN total_incurred ELSE 0 END) AS AD_Incurred,
                                     SUM(CASE WHEN peril = 'TP' THEN total_incurred ELSE 0 END) AS TP_Incurred,
                                     SUM(CASE WHEN peril = 'OT' THEN total_incurred ELSE 0 END) AS OT_Incurred,
                                     SUM(CASE WHEN peril = 'PI' THEN total_incurred ELSE 0 END) AS PI_Incurred,
                                     SUM(CASE WHEN peril = 'WS' THEN total_incurred ELSE 0 END) AS WS_Incurred
                              FROM dbuser.ice_aa_claim_financials
                              WHERE versionenddate = '2999-12-31'
                              GROUP BY claimnum) c ON b.claimnum = c.claimnum
                   LEFT JOIN aauser.calendar_week wk
                          ON b.incidentdate >= wk.start_date
                         AND b.incidentdate <= wk.end_date
                 GROUP BY b.polnum,
                          wk.start_date) clm
             ON exp.polnum = clm.polnum
            AND clm.acc_week = exp.acc_week




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

  dimension_group: accident_month {
    type: time
    timeframes: [
      month
    ]
    sql: ${TABLE}.acc_week ;;
  }

  dimension: accident_week_number {
    type: number
    sql: ${TABLE}.acc_week_number ;;
  }

  dimension: accident_month_number {
    type: number
    sql: ${TABLE}.acc_month_number ;;
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

  measure: reported_clms_inwk_freq_index {
    type: number
    sql: (${reported_clms_inwk} / nullif(${exposure},0))/0.041;;
    value_format_name: decimal_2
  }

  measure: fault_clms_inwk_freq {
    type: number
    sql: ${fault_clms_inwk} / nullif(${exposure},0);;
    value_format: "0.0%"
  }

  measure: smart_journeys_per_day {
    type: number
    sql:sum(journeys*1.000) / sum(device_exposure_days*1.000);;
    value_format_name: decimal_1
  }

  measure: smart_journeys_per_day_index {
    type: number
    sql:(sum(journeys*1.000) / sum(device_exposure_days*1.000))/2.774;;
    value_format_name: decimal_2
  }

  measure: smart_distance_per_day {
    type: number
    sql:sum(gps_distance*1.000/1000) / sum(device_exposure_days*1.000);;
    value_format_name: decimal_1
  }

  measure: smart_distance_per_day_index {
    type: number
    sql:(sum(gps_distance*1.000/1000) / sum(device_exposure_days*1.000)) /26.5;;
    value_format_name: decimal_2
  }


}
