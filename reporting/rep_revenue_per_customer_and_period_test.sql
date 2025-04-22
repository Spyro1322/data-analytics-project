CREATE TABLE IF NOT EXISTS `diesel-media-457308-t3.reporting_db.rep_revenue_per_customer_and_period_test` AS
WITH
  reporting_periods AS (
    SELECT
      reporting_period,
      reporting_date
    FROM
      `diesel-media-457308-t3.reporting_db.reporting_periods`
    WHERE
      reporting_date >= '2015-01-01'
      AND reporting_period IN ('Day', 'Month', 'Year')
  ),
  revenue_data AS (
    SELECT
      c.customer_id,
      CASE
        WHEN rp.reporting_period = 'Day' THEN DATE(p.payment_date)
        WHEN rp.reporting_period = 'Month' THEN DATE_TRUNC(p.payment_date, MONTH)
        WHEN rp.reporting_period = 'Year' THEN DATE_TRUNC(p.payment_date, YEAR)
      END AS truncated_payment_date,
      rp.reporting_period,
      rp.reporting_date,
      f.film_title,
      p.payment_amount
    FROM
      reporting_periods rp
    LEFT JOIN `diesel-media-457308-t3.staging_db.stg_payment` AS p
      ON (
        CASE
          WHEN rp.reporting_period = 'Day' THEN DATE(p.payment_date)
          WHEN rp.reporting_period = 'Month' THEN DATE_TRUNC(p.payment_date, MONTH)
          WHEN rp.reporting_period = 'Year' THEN DATE_TRUNC(p.payment_date, YEAR)
        END
      ) = rp.reporting_date
    LEFT JOIN `diesel-media-457308-t3.staging_db.stg_rental` AS r
      ON p.rental_id = r.rental_id
    LEFT JOIN `diesel-media-457308-t3.staging_db.stg_customer` AS c
      ON r.customer_id = c.customer_id
    LEFT JOIN `diesel-media-457308-t3.staging_db.stg_inventory` AS i
      ON r.inventory_id = i.inventory_id
    LEFT JOIN `diesel-media-457308-t3.staging_db.stg_film` AS f
      ON i.film_id = f.film_id
  )
SELECT
  customer_id,
  reporting_period,
  reporting_date,
  COALESCE(SUM(CASE WHEN film_title != 'GOODFELLAS SALUTE' THEN payment_amount ELSE 0 END), 0) AS total_revenue
FROM
  revenue_data
GROUP BY
  customer_id,
  reporting_period,
  reporting_date
HAVING
  total_revenue > 0
ORDER BY
  customer_id,
  reporting_date;
