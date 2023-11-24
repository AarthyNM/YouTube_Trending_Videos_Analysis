-- Overall distribution of duration of trending videos by each country
SELECT video_id,
               title,
               country,
               Count(trending_date) AS no_of_days_trended
        FROM   yt_trending_videos
        GROUP  BY video_id,
                  title,
                  country ;
                  
-- Overall distribution of duration of trending videos by each category    

SELECT video_id,
               title,
               snippettitle,
               Count(trending_date) AS no_of_days_trended
        FROM   yt_trending_videos a
               INNER JOIN yt_category_map b
                       ON a.category_id = b.id
        GROUP  BY video_id,
                  title,
                  snippettitle
        ORDER  BY 4 DESC    ;
 
 -- Average trending period By category
 
 SELECT snippettitle            AS category_title,
       Avg(no_of_days_trended) AS avg_trending_days
FROM   (SELECT video_id,
               title,
               snippettitle,
               Count(trending_date) AS no_of_days_trended
        FROM   yt_trending_videos a
               INNER JOIN yt_category_map b
                       ON a.category_id = b.id
        GROUP  BY video_id,
                  title,
                  snippettitle) a
GROUP  BY snippettitle
ORDER  BY avg_trending_days DESC ;

--  Number of distinct videos trending from each category on day of the week 

SELECT snippettitle,
 Count(DISTINCT video_id) AS no_of_videos ,
 DAYNAME(trending_date) as Days_of_Week
FROM   yt_trending_videos a
       INNER JOIN yt_category_map b
               ON a.category_id = b.id
GROUP  BY 1,3     ;

-- Rank the videos based on views, likes within each country

SELECT video_id,
               title,
               country,
               views,
               likes,
               Rank()
                 OVER (
                   partition BY country
                   ORDER BY views DESC) AS rank_views,
               Rank()
                 OVER (
                   partition BY country
                   ORDER BY likes DESC) AS rank_likes
        FROM   yt_trending_videos;
        
 -- Top 5 countries that  has the highest number of videos with rank for views and rank of likes both in top 20  
 
SELECT country,
       Count(video_id) AS no_of_videos
FROM   (SELECT video_id,
               title,
               country,
               views,
               likes,
               Rank()
                 OVER (
                   partition BY country
                   ORDER BY views DESC) AS rank_views,
               Rank()
                 OVER (
                   partition BY country
                   ORDER BY likes DESC) AS rank_likes
        FROM   yt_trending_videos) a
WHERE  rank_views <= 20
       AND rank_likes <= 20
GROUP  BY country
ORDER  BY no_of_videos DESC ;

-- Rating Framework based on views 
SELECT c.*,
               Round(( ( views - min_views ) * 100 ) / ( max_views - min_views )
               , 0) AS
                      rating
        FROM   (SELECT DISTINCT video_id,
                                title,
                                snippettitle                  AS category_title,
                                views,
                                Max(views)
                                  OVER (
                                    partition BY category_id) AS max_views,
                                Min(views)
                                  OVER (
                                    partition BY category_id) AS min_views
                FROM   yt_trending_videos a
                       INNER JOIN yt_category_map b
                               ON a.category_id = b.id) c;
-- Highest avaerage rating based on Views:

SELECT category_title,
       Avg(rating) AS avg_rating
FROM   (SELECT c.*,
               Round(( ( views - min_views ) * 100 ) / ( max_views - min_views )
               , 0) AS
                      rating
        FROM   (SELECT DISTINCT video_id,
                                title,
                                snippettitle                  AS category_title,
                                views,
                                Max(views)
                                  OVER (
                                    partition BY category_id) AS max_views,
                                Min(views)
                                  OVER (
                                    partition BY category_id) AS min_views
                FROM   yt_trending_videos a
                       INNER JOIN yt_category_map b
                               ON a.category_id = b.id) c) d
GROUP  BY category_title ;

-- Rating Framework based on likes 
        
     SELECT c.*,
               Round(( ( likes - min_likes ) * 100 ) / ( max_likes - min_likes )
               , 0) AS
                      rating
        FROM   (SELECT DISTINCT video_id,
                                title,
                                snippettitle                  AS category_title,
                                likes,
                                Max(likes)
                                  OVER (
                                    partition BY category_id) AS max_likes,
                                Min(likes)
                                  OVER (
                                    partition BY category_id) AS min_likes
                FROM   yt_trending_videos a
                       INNER JOIN yt_category_map b
                               ON a.category_id = b.id) c;
                               
     -- Highest avaerage rating based on likes
     
     SELECT category_title,
       Avg(rating) AS avg_rating
FROM   (SELECT c.*,
               Round(( ( likes - min_likes ) * 100 ) / ( max_likes - min_likes )
               , 0) AS
                      rating
        FROM   (SELECT DISTINCT video_id,
                                title,
                                snippettitle                  AS category_title,
                                likes,
                                Max(likes)
                                  OVER (
                                    partition BY category_id) AS max_likes,
                                Min(likes)
                                  OVER (
                                    partition BY category_id) AS min_likes
                FROM   yt_trending_videos a
                       INNER JOIN yt_category_map b
                               ON a.category_id = b.id) c) d
GROUP  BY category_title
ORDER  BY avg_rating DESC ;
 
 
        
        

 