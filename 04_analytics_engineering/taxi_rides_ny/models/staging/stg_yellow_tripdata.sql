with source as (
select * from {{source('raw_data', 'yellow_tripdata')}}
),

renamed as (
    select
            -- identifiers (standardized naming for consistency across yellow/green)
            cast(vendorid as integer) as vendor_id,
            cast(ratecodeid as integer) as rate_code_id,
            cast(pulocationid as integer) as pickup_location_id,
            cast(dolocationid as integer) as dropoff_location_id,

            -- timestamps (standardized naming)
            cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
            cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

            -- trip info
            cast(store_and_fwd_flag as string) as store_and_fwd_flag,
            cast(passenger_count as integer) as passenger_count,
            cast(trip_distance as numeric) as trip_distance,
                -- since staging should be one-to-one copies,
                -- might be a better idea to make this an intermediate table
            1 as trip_type, -- yellow taxis only have trip_type=1 (i.e street hailing not ordering)

            -- payment info
            cast(fare_amount as numeric) as fare_amount,
            cast(extra as numeric) as extra,
            cast(mta_tax as numeric) as mta_tax,
            cast(tip_amount as numeric) as tip_amount,
            cast(tolls_amount as numeric) as tolls_amount,
                -- a column for an intermediate yellow table too
            0 as ehail_fee, -- yellow taxis have no ehail fees
            cast(improvement_surcharge as numeric) as improvement_surcharge,
            cast(total_amount as numeric) as total_amount,
            cast(payment_type as integer) as payment_type

        from source
        -- Filter out records with null vendor_id (data quality requirement)
        where vendorid is not null

)

select * from renamed

-- Sample records for dev environment using deterministic date filter
{% if target.name == 'dev' %}
where pickup_datetime >= '2019-01-01' and pickup_datetime < '2019-02-01'
{% endif %}