connection: "av2"

# include all the views
include: "*.view"

datagroup: claims_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "12 hour"
}

persist_with: claims_datagroup

explore: claims {}
explore: fnol {}
explore: fnol_ice {}
explore: ice_claims {}
explore: nonfault_ad_claims {}
explore: updated_asat {}
