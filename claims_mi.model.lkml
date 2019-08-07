connection: "echo_actian"

# include all the views
include: "*.view"

datagroup: claims_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "24 hour"
}

persist_with: claims_datagroup

explore: claims {}
explore: fnol {}
