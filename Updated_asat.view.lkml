view: updated_asat {
  derived_table: {
    sql:
    SELECT
    max(loaddttm)

    FROM ice_dim_claim

       ;;
  }

  measure: loaddttm {
    type: date_time
    sql: ${TABLE}.loaddttm;;
  }

}
