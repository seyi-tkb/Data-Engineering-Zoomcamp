with source as (
    select *
    from {{source('raw_data', 'fhv_tripdata')}}
),

null_removed as (
    select *
    from source
    where dispatching_base_num IS NOT NULL
),

renamed as (
    select 
        dispatching_base_num ,	
        pickup_datetime, 
        dropOff_datetime as dropoff_datetime,	
        PUlocationID as pickup_location_id, 	
        DOlocationID as dropoff_location_id, 	
        SR_Flag as shared_ride_flag, 	
        Affiliated_base_number as affiliated_base_number
    from null_removed
)

select *
from renamed