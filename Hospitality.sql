-- Total Capacity by City and Room Category 

SELECT h.city, r.room_class, SUM(f.capacity) AS fact_aggregated_bookingstotal_capacity
FROM fact_aggregated_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id 
JOIN dim_hotels h ON f.property_id = h.property_id
GROUP BY h.city, r.room_class;

-- Average Rating by Room Class and Month

SELECT r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m') AS month, 
       AVG(f.ratings_given) AS avg_rating
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
WHERE f.booking_status = 'Checked Out'
GROUP BY r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m');

-- Average Rating by Property

SELECT h.property_name, AVG(f.ratings_given) AS avg_rating
FROM fact_bookings f
JOIN dim_hotels h ON f.property_id = h.property_id
WHERE f.booking_status = 'Checked Out'
GROUP BY h.property_name;

-- Successful Bookings by City and Month

SELECT h.city, DATE_FORMAT(f.check_in_date, '%Y-%m') AS month,
       SUM(f.successful_bookings) AS total_successful_bookings
FROM fact_aggregated_bookings f
JOIN dim_hotels h ON f.property_id = h.property_id
GROUP BY h.city, DATE_FORMAT(f.check_in_date, '%Y-%m');

-- Total Bookings by Property

SELECT h.property_name, COUNT(f.booking_id) AS total_bookings
FROM fact_bookings f
JOIN dim_hotels h ON f.property_id = h.property_id
GROUP BY h.property_name;

 -- Total Bookings by Room Class and Month
 
SELECT r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m') AS month,
       COUNT(f.booking_id) AS total_bookings
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
GROUP BY r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m');

-- Cancelled Bookings by Room Class and Month

SELECT r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m') AS month,
       COUNT(f.booking_id) AS cancelled_bookings
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
WHERE f.booking_status = 'Cancelled'
GROUP BY r.room_class, DATE_FORMAT(f.check_in_date, '%Y-%m');

--  Revenue by Room Category

SELECT 
    r.room_class, 
    CONCAT(ROUND(SUM(f.discount_applied) / 1000000, 2), ' M') AS total_revenue_in_million
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
WHERE f.booking_status = 'Checked Out'
GROUP BY r.room_class;

--  Total Bookings by Platforms

SELECT booking_platform, COUNT(booking_id) AS total_bookings
FROM fact_bookings
GROUP BY booking_platform;

-- Revenue Generated by Day

SELECT 
    check_in_date, 
    CONCAT(ROUND(SUM(discount_applied) / 1000, 2), ' K') AS daily_revenue_in_thousand
FROM fact_bookings
WHERE booking_status = 'Checked Out'
GROUP BY check_in_date;

-- Cancellation Rate (%) by Platform

SELECT 
    booking_platform,
    ROUND(SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percent
FROM fact_bookings
GROUP BY booking_platform;

 -- Average Stay Duration by Room Class
 
 SELECT 
    r.room_class,
    ROUND(AVG(f.stay_duration), 2) AS avg_stay_duration
FROM fact_bookings f
JOIN dim_rooms r ON f.room_category = r.room_id
WHERE f.booking_status = 'Checked Out'
GROUP BY r.room_class;

-- Revenue Lost Due to Cancellations (in Millions)

SELECT 
    CONCAT(ROUND(SUM(discount_applied) / 1000000, 2), 'M') AS revenue_lost_to_cancellations
FROM fact_bookings
WHERE booking_status = 'Cancelled';

-- Utilization Rate by Property (Successful Bookings ÷ Capacity)

SELECT 
    h.property_name,
    ROUND(SUM(f.successful_bookings) * 100.0 / SUM(f.capacity), 2) AS utilization_rate_percent
FROM fact_aggregated_bookings f
JOIN dim_hotels h ON f.property_id = h.property_id
GROUP BY h.property_name;

-- Average Booking Lead Time (in Days)

SELECT 
    ROUND(AVG(DATEDIFF(check_in_date, booking_date)), 2) AS avg_booking_lead_time_days
FROM fact_bookings
WHERE booking_status = 'Checked Out';