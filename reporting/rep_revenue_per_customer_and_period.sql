CREATE TABLE IF NOT EXISTS diesel-media-457308-t3.reporting_db.rep_revenue_per_customer_and_period AS
  WITH
    reporting_periods AS (
      SELECT
        reporting_period,
        reporting_date
      FROM
        diesel-media-457308-t3.reporting_db.reporting_periods
    )
  SELECT
    c.customer_id,
    reporting_periods.reporting_period,
    reporting_periods.reporting_date,
    COALESCE(SUM(p.payment_amount), 0) AS total_revenue
  FROM
    reporting_periods
    LEFT JOIN diesel-media-457308-t3.staging_db.stg_payment AS p ON DATE(p.payment_date) = reporting_periods.reporting_date
    LEFT JOIN diesel-media-457308-t3.staging_db.stg_rental AS r ON p.rental_id = r.rental_id
    LEFT JOIN diesel-media-457308-t3.staging_db.stg_customer AS c ON r.customer_id = c.customer_id
    LEFT JOIN diesel-media-457308-t3.staging_db.stg_inventory AS i ON r.inventory_id = i.inventory_id
    LEFT JOIN diesel-media-457308-t3.staging_db.stg_film AS f ON i.film_id = f.film_id
  WHERE
    f.film_title <> 'GOODFELLAS SALUTE'
    AND reporting_periods.reporting_period IN ('Day', 'Month', 'Year')
  GROUP BY 1,2,3
  HAVING
    SUM(p.payment_amount) > 0
  ORDER BY
    c.customer_id,
    reporting_periods.reporting_date;