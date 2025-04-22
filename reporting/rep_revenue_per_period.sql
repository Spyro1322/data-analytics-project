CREATE TABLE IF NOT EXISTS `diesel-media-457308-t3.reporting_db.rep_revenue_per_period` AS
  WITH
    reporting_periods AS (
      SELECT
        reporting_period,
        reporting_date
      FROM
        diesel-media-457308-t3.reporting_db.reporting_periods
      WHERE
        reporting_date >= '2015-01-01'
        AND reporting_period IN ('Day', 'Month', 'Year')
    ),
    revenue_data AS (
      SELECT
        payment.payment_amount,
        CASE
          WHEN rp.reporting_period = 'Day' THEN DATE(payment.payment_date)
          WHEN rp.reporting_period = 'Month' THEN DATE_TRUNC(payment.payment_date, MONTH)
          WHEN rp.reporting_period = 'Year' THEN DATE_TRUNC(payment.payment_date, YEAR)
        END AS truncated_payment_date,
        rp.reporting_period,
        rp.reporting_date,
        film.film_title
      FROM
        reporting_periods rp
      LEFT JOIN diesel-media-457308-t3.staging_db.stg_payment AS payment
        ON (
          CASE
            WHEN rp.reporting_period = 'Day' THEN DATE(payment.payment_date)
            WHEN rp.reporting_period = 'Month' THEN DATE_TRUNC(payment.payment_date, MONTH)
            WHEN rp.reporting_period = 'Year' THEN DATE_TRUNC(payment.payment_date, YEAR)
          END
        ) = rp.reporting_date
      LEFT JOIN diesel-media-457308-t3.staging_db.stg_rental AS rental
        ON payment.rental_id = rental.rental_id
      LEFT JOIN diesel-media-457308-t3.staging_db.stg_inventory AS inventory
        ON rental.inventory_id = inventory.inventory_id
      LEFT JOIN diesel-media-457308-t3.staging_db.stg_film AS film
        ON inventory.film_id = film.film_id
    )
  SELECT
    reporting_period,
    reporting_date,
    COALESCE(SUM(CASE WHEN film_title != 'GOODFELLAS SALUTE' THEN payment_amount ELSE 0 END), 0) AS total_revenue
  FROM
    revenue_data
  GROUP BY 1, 2;
