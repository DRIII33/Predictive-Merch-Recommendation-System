CREATE OR REPLACE VIEW `driiiportfolio.merchandise_project.merchandise_insights_view` AS
WITH
  SalesWithTourDates AS (
    SELECT
      ms.sale_id,
      ms.sale_date,
      ms.sale_price,
      ms.artist_id,
      ms.merchandise_id,
      ms.user_id,
      fe.engagement_type,
      fe.user_location,
      fe.user_demographics,
      mv.video_id,
      mv.release_date AS video_release_date,
      mv.merch_worn_by_artist,
      mv.merch_worn_by_key_player,
      mv.video_views,
      mv.video_likes,
      td.tour_id,
      td.tour_city,
      td.tour_date,
      td.is_headlining,
      DATE_DIFF(ms.sale_date, td.tour_date, DAY) AS days_to_from_tour_date_temp
    FROM
      `driiiportfolio.merchandise_project.merchandise_sales` AS ms
    LEFT JOIN
      `driiiportfolio.merchandise_project.fan_engagement` AS fe ON ms.user_id = fe.user_id
    LEFT JOIN
      `driiiportfolio.merchandise_project.music_videos` AS mv ON ms.artist_id = mv.artist_id
    CROSS JOIN
      `driiiportfolio.merchandise_project.tour_dates` AS td
    WHERE
      ms.artist_id = td.artist_id
  ),
  RankedSales AS (
    SELECT
      *,
      ROW_NUMBER() OVER(PARTITION BY sale_id ORDER BY ABS(days_to_from_tour_date_temp) ASC) AS rn
    FROM
      SalesWithTourDates
  )
SELECT
  sale_id,
  sale_date,
  sale_price,
  artist_id,
  merchandise_id,
  user_id,
  engagement_type,
  user_location,
  video_id,
  video_release_date,
  merch_worn_by_artist,
  merch_worn_by_key_player,
  video_views,
  video_likes,
  tour_id,
  tour_city,
  tour_date,
  is_headlining,
  days_to_from_tour_date_temp AS days_to_from_tour_date,
  CASE
    WHEN sale_date BETWEEN video_release_date AND DATE_ADD(video_release_date, INTERVAL 30 DAY) THEN 1
    ELSE 0
  END AS sold_after_video_release,
  CASE
    WHEN days_to_from_tour_date_temp BETWEEN -14 AND 14 THEN 1
    ELSE 0
  END AS sold_around_tour_date,
  COALESCE(user_demographics, 'Unknown') AS user_demographics
FROM
  RankedSales
WHERE
  rn = 1;
