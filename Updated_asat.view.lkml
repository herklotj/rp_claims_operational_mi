view: updated_asat {
  derived_table: {
    sql:
    SELECT first 1
    loaddttm

    FROM ice_dim_claim

       ;;
  }

  measure: loaddttm {
    type: date_time
    sql: ${TABLE}.loaddttm;;
  }

}
