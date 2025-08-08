CREATE OR REPLACE VIEW `driiiportfolio.merchandise_project.merchandise_insights_view` AS
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
    DATE_DIFF(ms.sale_date, mv.release_date, DAY) AS days_since_video_release,
    DATE_DIFF(ms.sale_date, td.tour_date, DAY) AS days_to_from_tour_date,
    CASE
        WHEN ms.sale_date BETWEEN mv.release_date AND DATE_ADD(mv.release_date, INTERVAL 30 DAY) THEN 1
        ELSE 0
    END AS sold_after_video_release,
    CASE
        WHEN ms.sale_date BETWEEN DATE_ADD(td.tour_date, INTERVAL -14 DAY) AND DATE_ADD(td.tour_date, INTERVAL 14 DAY) THEN 1
        ELSE 0
    END AS sold_around_tour_date
FROM
    `driiiportfolio.merchandise_project.merchandise_sales` AS ms
LEFT JOIN
    `driiiportfolio.merchandise_project.fan_engagement` AS fe ON ms.user_id = fe.user_id AND ms.artist_id = fe.artist_id
LEFT JOIN
    `driiiportfolio.merchandise_project.music_videos` AS mv ON ms.artist_id = mv.artist_id
LEFT JOIN
    `driiiportfolio.merchandise_project.tour_dates` AS td ON ms.artist_id = td.artist_id;
