-- Query 1: Basic table and row counts
SELECT
    (SELECT count(DISTINCT artist_id) FROM `driiiportfolio.merchandise_project.music_videos`) AS unique_artists_in_videos,
    (SELECT count(DISTINCT artist_id) FROM `driiiportfolio.merchandise_project.tour_dates`) AS unique_artists_in_tours,
    (SELECT count(DISTINCT user_id) FROM `driiiportfolio.merchandise_project.fan_engagement`) AS total_users,
    (SELECT count(DISTINCT sale_id) FROM `driiiportfolio.merchandise_project.merchandise_sales`) AS total_sales,
    (SELECT count(DISTINCT video_id) FROM `driiiportfolio.merchandise_project.music_videos`) AS total_videos,
    (SELECT count(DISTINCT tour_id) FROM `driiiportfolio.merchandise_project.tour_dates`) AS total_tours;

-- Query 2: Merchandise sales distribution by artist
SELECT
    artist_id,
    count(sale_id) AS total_sales,
    SUM(sale_price) AS total_revenue
FROM `driiiportfolio.merchandise_project.merchandise_sales`
GROUP BY artist_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 3: Sales after a music video release
SELECT
    mv.artist_id,
    mv.video_id,
    mv.release_date,
    count(ms.sale_id) AS sales_within_30_days_of_release
FROM `driiiportfolio.merchandise_project.music_videos` AS mv
LEFT JOIN `driiiportfolio.merchandise_project.merchandise_sales` AS ms
    ON mv.artist_id = ms.artist_id
    AND ms.sale_date BETWEEN mv.release_date AND DATE_ADD(mv.release_date, INTERVAL 30 DAY)
GROUP BY mv.artist_id, mv.video_id, mv.release_date
ORDER BY sales_within_30_days_of_release DESC
LIMIT 10;

-- Query 4: Sales around tour dates
SELECT
    td.artist_id,
    td.tour_city,
    td.tour_date,
    count(ms.sale_id) AS sales_around_tour
FROM `driiiportfolio.merchandise_project.tour_dates` AS td
LEFT JOIN `driiiportfolio.merchandise_project.merchandise_sales` AS ms
    ON td.artist_id = ms.artist_id
    AND ms.sale_date BETWEEN DATE_ADD(td.tour_date, INTERVAL -14 DAY) AND DATE_ADD(td.tour_date, INTERVAL 14 DAY)
GROUP BY td.artist_id, td.tour_city, td.tour_date
ORDER BY sales_around_tour DESC
LIMIT 10;

-- Query 5: Fan engagement distribution by location
SELECT
    user_location,
    count(engagement_type) AS total_engagements
FROM `driiiportfolio.merchandise_project.fan_engagement`
GROUP BY user_location
ORDER BY total_engagements DESC;

-- Query 6: Join all tables to see a combined view
SELECT
    ms.sale_id,
    ms.sale_date,
    ms.sale_price,
    ms.artist_id,
    fe.user_location,
    fe.user_demographics,
    mv.video_id,
    mv.release_date,
    mv.merch_worn_by_artist,
    mv.merch_worn_by_key_player
FROM `driiiportfolio.merchandise_project.merchandise_sales` AS ms
LEFT JOIN `driiiportfolio.merchandise_project.fan_engagement` AS fe
    ON ms.user_id = fe.user_id AND ms.artist_id = fe.artist_id
LEFT JOIN `driiiportfolio.merchandise_project.music_videos` AS mv
    ON ms.artist_id = mv.artist_id
WHERE ms.sale_date BETWEEN mv.release_date AND DATE_ADD(mv.release_date, INTERVAL 30 DAY)
LIMIT 100;
