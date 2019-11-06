view: nonfault_ad_claims {
   derived_table: {
    sql:
    SELECT
        l.claimnum
        ,l.polnum
        ,l.incidentdate
        ,l.notificationdate
        ,s.status_code
        ,l.ad_paid
        ,l.ad_fees_paid
        ,l.ad_incurred
        ,l.ad_fees_incurred
        ,l.total_incurred
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
     primary_key: yes
     type: string
     sql: ${TABLE}.claimnum ;;
   }

   dimension: ad_paid {
     description: "AD Paid including fees"
     type: number
     value_format_name: gbp
     sql: ${TABLE}.ad_paid ;;
   }

  dimension: ad_fees_paid {
    description: "AD Paid Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_fees_paid ;;
  }

  dimension: ad_incurred {
    description: "AD Incurred including fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_incurred ;;
  }

  dimension: ad_fees_incurred {
    description: "AD Incurred Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.ad_fees_incurred ;;
  }

  dimension: total_incurred {
    description: "Total Incurred Fees"
    type: number
    value_format_name: gbp
    sql: ${TABLE}.total_incurred ;;
  }

 }
