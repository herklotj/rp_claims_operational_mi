view: nonfault_ad_claims {
   derived_table: {
    sql:
    SELECT
        l.claimnum
        ,l.polnum
        ,l.incident_date
        ,l.notificationdate
        ,s.status_code
        ,l.ad_paid
        ,l.ad_fees_paid
        ,l.ad_incurred
        ,l.ad_fees_incurred
        ,l.total_incurred
        ,l.pi_paid
        ,l.pi_incurred
        ,round(l.ad_incurred_exc_rec - l.ad_incurred,2) -  round(l.ad_paid_exc_rec - l.ad_paid,2) as ad_recovery_reserve
    FROM v_ice_claims_latest_position l
    INNER JOIN  (SELECT claim_number
                FROM ice_dim_claim
                WHERE current_flag = 'Y'
                AND   incident_type_description != 'Windscreen/Glass'
                AND   closed_reason_description != 'Error'
                AND   (liability_decision = 'NONFAULT' OR (liability_decision = '' AND fault_ind = 'No'))) n ON l.claimnum = n.claim_number
    LEFT JOIN (SELECT *
              FROM v_all_claim_status
              WHERE to_date(end_date) = '2999-12-31') s ON s.claim_number = l.claimnum
    WHERE ROUND(ad_incurred - ad_fees_incurred,1) != 0
    AND   status_code != 'CLOSED'
       ;;
   }


   dimension: claim_number {
    label: "Claim Number"
    primary_key: yes
    type: string
    sql: ${TABLE}.claimnum ;;
   }

  dimension: ad_paid {
    label: "AD Paid"
    description: "AD Paid Including Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_paid ;;
   }

  dimension: ad_fees_paid {
    label: "AD Fees Paid"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_fees_paid ;;
  }

  dimension: ad_paid_exc_fees {
    label: "AD Paid Excluding Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_paid - ${TABLE}.ad_fees_paid ;;
  }

  dimension: ad_incurred {
    label: "AD Incurred"
    description: "AD Incurred Including Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_incurred ;;
  }

  dimension: ad_fees_incurred {
    label: "AD Fees Incurred"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_fees_incurred ;;
  }

  dimension: ad_incurred_exc_fees {
    label: "AD Incurred Excluding Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_incurred - ${TABLE}.ad_fees_incurred ;;
  }

  dimension: total_incurred {
    description: "Total Incurred"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.total_incurred ;;
  }

  dimension: ad_recovery_reserve {
    description: "AD Recovery Reserve"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_recovery_reserve ;;
  }

  dimension: accident_month {
    description: "Accident Month"
    allow_fill: no
    type: date
    sql:date_trunc('month',case when year(${TABLE}.incident_date) = year(sysdate) and month(sysdate) - month(${TABLE}.incident_date) <6 then ${TABLE}.incident_date
             when year(sysdate) - year(${TABLE}.incident_date) = 1 and month(sysdate) +12 - month(${TABLE}.incident_date) <6 then ${TABLE}.incident_date
             else date_trunc('year',${TABLE}.incident_date) end) ;;
  }

  measure: number {
    type: count
  }

  measure: positive {
    type: sum
    sql:  case when ${TABLE}.ad_incurred > 0 then 1 else 0 end;;
  }

  measure: positive_incurred {
    type: sum
    value_format_name: gbp
    sql:  case when ${TABLE}.ad_incurred > 0 then ${TABLE}.ad_incurred else 0 end;;
  }

  measure: negative {
    type: sum
    sql:  case when ${TABLE}.ad_incurred < 0 then 1 else 0 end;;
  }

  measure: negative_incurred {
    type: sum
    value_format_name: gbp
    sql:  case when ${TABLE}.ad_incurred < 0 then ${TABLE}.ad_incurred else 0 end;;
  }

  measure: incurred {
    type: sum
    value_format_name: gbp
    sql:  ${TABLE}.ad_incurred;;
  }

  measure: incurred_exc_fees {
    type: sum
    value_format_name: gbp
    sql:  ${TABLE}.ad_incurred -${TABLE}.ad_fees_incurred;;
  }

  measure: pi_incurred {
    type: sum
    value_format_name: gbp
    sql:  ${TABLE}.pi_incurred;;
  }

  measure: pi_paid {
    type: sum
    value_format_name: gbp
    sql:  ${TABLE}.pi_paid;;
  }

  measure: pi_count {
    type: sum
    sql:  case when ${TABLE}.pi_incurred > 0 then 1 else 0 end;;
  }

 }
