view: updated_asat {
  derived_table: {
    sql:
    SELECT
    loaddttm

    FROM dbuser.ice_dim_claim

       ;;
  }

  measure: loaddttm {
    type: date_time
    sql: max(${TABLE}.loaddttm);;
  }

}
