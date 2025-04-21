CREATE TABLE IF NOT EXISTS diesel-media-457308-t3.reporting_db.rep_revenue_per_period AS
  WITH
    reporting_periods AS (
      SELECT
        reporting_period,
        reporting_date
      FROM
        diesel-media-457308-t3.reporting_db.reporting_periods
    )
  SELECT
    reporting_periods.reporting_period,
    reporting_periods.reporting_date,
    COALESCE(SUM(payment.payment_amount), 0) AS total_revenue
  FROM
    reporting_periods
    LEFT JOIN
    diesel-media-457308-t3.staging_db.stg_payment AS payment
    ON DATE(payment.payment_date) = reporting_periods.reporting_date
    LEFT JOIN
    diesel-media-457308-t3.staging_db.stg_rental AS rental
    ON payment.rental_id = rental.rental_id
    LEFT JOIN
    diesel-media-457308-t3.staging_db.stg_inventory AS inventory
    ON rental.inventory_id = inventory.inventory_id
    LEFT JOIN
    diesel-media-457308-t3.staging_db.stg_film AS film
    ON inventory.film_id = film.film_id
  WHERE
    film.film_title <> 'GOODFELLAS SALUTE' AND reporting_periods.reporting_date >= '2015-01-01' AND
    reporting_periods.reporting_period IN ('Day', 'Month', 'Year')
  GROUP BY 1, 2;

