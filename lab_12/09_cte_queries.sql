-- ========================================================================
-- Compute average score per course, then list students whose score is 
-- above their course average.
-- ========================================================================
WITH student_avg AS (
    SELECT
        sub.user_id,
        a.course_id,
        AVG(sub.score) AS student_avg_score
    FROM submissions sub
    JOIN assignments a
        ON sub.assignment_id = a.assignment_id
    GROUP BY sub.user_id, a.course_id
),
course_avg AS (
    SELECT
        a.course_id,
        AVG(sub.score) AS course_avg_score
    FROM submissions sub
    JOIN assignments a
        ON sub.assignment_id = a.assignment_id
    GROUP BY a.course_id
)

SELECT
    s.user_id,
    s.first_name || ' ' || s.last_name AS full_name,
    sa.course_id,
    sa.student_avg_score,
    ca.course_avg_score
FROM student_avg sa
JOIN course_avg ca
    ON sa.course_id = ca.course_id
JOIN users s
    ON s.user_id = sa.user_id
WHERE sa.student_avg_score > ca.course_avg_score;

-- ========================================================================
-- Computer total revenue per instructor
-- ========================================================================
WITH course_revenue AS (
    SELECT
        c.instructor_id,
        p.course_id,
        SUM(p.amount) AS total_revenue
    FROM payments p
    JOIN courses c
        ON p.course_id = c.course_id
    WHERE p.status = 'completed'
    GROUP BY c.instructor_id, p.course_id
)

SELECT
    i.user_id,
    i.first_name || ' ' || i.last_name AS full_name,
    SUM(cr.total_revenue) AS instructor_revenue
FROM users i
JOIN course_revenue cr
    ON i.user_id = cr.instructor_id
GROUP BY i.user_id, i.first_name, i.last_name
ORDER BY i.user_id;

