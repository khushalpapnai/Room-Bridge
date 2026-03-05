USE roomy1;

SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

-- Cleanup previous load-test data (safe, scoped by email/title prefix)
DELETE rr
FROM room_review rr
JOIN room r ON rr.room_id = r.id
JOIN `user` u ON r.user_id = u.id
WHERE u.email LIKE 'loadtest_user%@roombridge.test' OR rr.user_id IN (
    SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test'
);

DELETE FROM chat_message
WHERE sender_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test')
   OR receiver_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test');

DELETE FROM session
WHERE user_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test');

DELETE FROM user_documents
WHERE user_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test');

DELETE ri
FROM room_image_urls ri
JOIN room r ON ri.room_id = r.id
WHERE r.title LIKE 'Load Test Room %';

DELETE FROM room
WHERE title LIKE 'Load Test Room %';

DELETE FROM profiles
WHERE user_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test');

DELETE FROM user_roles
WHERE user_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test');

DELETE FROM `user`
WHERE email LIKE 'loadtest_user%@roombridge.test';

-- 1) Insert 26 users with mixed verification states
INSERT INTO `user` (email, password, name, is_verified, verification_status, otp, otp_expiry)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 26
)
SELECT
    CONCAT('loadtest_user', LPAD(n, 2, '0'), '@roombridge.test') AS email,
    '$2a$10$etiJU.T9zGeReOCCNf45qe9C4/omAWhzeJFsPXTVACV1777xyZ9JO' AS password,
    CONCAT('Load User ', LPAD(n, 2, '0')) AS name,
    IF(MOD(n, 4) = 0, b'0', b'1') AS is_verified,
    CASE
        WHEN MOD(n, 7) = 0 THEN NULL
        WHEN MOD(n, 3) = 0 THEN 2
        WHEN MOD(n, 3) = 1 THEN 0
        ELSE 1
    END AS verification_status,
    IF(MOD(n, 5) = 0, LPAD(MOD(100000 + n * 123, 999999), 6, '0'), NULL) AS otp,
    IF(MOD(n, 5) = 0, DATE_ADD(NOW(), INTERVAL MOD(n, 12) - 6 HOUR), NULL) AS otp_expiry
FROM seq;

-- 2) Assign roles (all USER, most CREATOR, one ADMIN)
INSERT INTO user_roles (user_id, roles)
SELECT id, 'USER'
FROM `user`
WHERE email LIKE 'loadtest_user%@roombridge.test';

INSERT INTO user_roles (user_id, roles)
SELECT id, 'CREATOR'
FROM `user`
WHERE email LIKE 'loadtest_user%@roombridge.test'
  AND MOD(id, 2) = 0;

INSERT INTO user_roles (user_id, roles)
SELECT id, 'ADMIN'
FROM `user`
WHERE email = 'loadtest_user01@roombridge.test';

-- 3) Insert profile for each load user
INSERT INTO profiles (
    user_id, full_name, phone_number, address, bio, profile_image_url,
    verification_status, social_links, created_at
)
SELECT
    u.id,
    CONCAT('Profile ', u.name),
    CONCAT('+977-980', LPAD(MOD(u.id * 137, 10000000), 7, '0')),
    CONCAT('Ward ', MOD(u.id, 15) + 1, ', Kathmandu'),
    CASE
        WHEN MOD(u.id, 5) = 0 THEN 'Night-shift professional, prefers quiet roommates.'
        WHEN MOD(u.id, 5) = 1 THEN 'Student, likes shared kitchen and study area.'
        WHEN MOD(u.id, 5) = 2 THEN 'Remote worker, needs stable internet.'
        WHEN MOD(u.id, 5) = 3 THEN 'Pet-friendly and open to short-term stays.'
        ELSE 'Budget-focused, clean and cooperative.'
    END,
    CONCAT('/uploads/profile-image/loadtest_user_', u.id, '.jpg'),
    IF(MOD(u.id, 3) = 0, b'0', b'1'),
    CONCAT('{"linkedin":"https://linkedin.com/in/loadtest', u.id,
           '","instagram":"https://instagram.com/loadtest', u.id, '"}'),
    DATE_SUB(NOW(), INTERVAL MOD(u.id, 120) DAY)
FROM `user` u
WHERE u.email LIKE 'loadtest_user%@roombridge.test';

-- Temporary creator list
DROP TEMPORARY TABLE IF EXISTS tmp_creators;
CREATE TEMPORARY TABLE tmp_creators AS
SELECT
    u.id,
    ROW_NUMBER() OVER (ORDER BY u.id) AS seq
FROM `user` u
JOIN user_roles ur ON ur.user_id = u.id
WHERE u.email LIKE 'loadtest_user%@roombridge.test'
  AND ur.roles IN ('CREATOR', 'ADMIN')
GROUP BY u.id;

SET @creator_count = (SELECT COUNT(*) FROM tmp_creators);

-- 4) Insert 30 rooms covering multiple situations
INSERT INTO room (
    title, description, price, location, furnished, room_type, status, is_available,
    available_from, gender_preference, max_occupancy, created_at, user_id
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 30
)
SELECT
    CONCAT('Load Test Room ', LPAD(n, 2, '0')),
    CASE
        WHEN MOD(n, 6) = 0 THEN 'Premium listing near transit with strict quiet hours.'
        WHEN MOD(n, 6) = 1 THEN 'Affordable room, utilities excluded, negotiable deposit.'
        WHEN MOD(n, 6) = 2 THEN 'Family-friendly neighborhood with parking.'
        WHEN MOD(n, 6) = 3 THEN 'Walkable location, shared bathroom, great ventilation.'
        WHEN MOD(n, 6) = 4 THEN 'Short-term option for interns and students.'
        ELSE 'Spacious room with balcony and flexible move-in date.'
    END,
    ROUND(8500 + (n * 475) + (MOD(n, 4) * 120), 2),
    CONCAT(
      ELT((MOD(n, 8) + 1), 'Baneshwor', 'Koteshwor', 'Lalitpur', 'Bhaktapur', 'Kalanki', 'Maitidevi', 'Kirtipur', 'Thamel'),
      ', Kathmandu'
    ),
    IF(MOD(n, 2) = 0, b'1', b'0'),
    IF(MOD(n, 3) = 0, 'SHARED', 'PRIVATE'),
    CASE
      WHEN MOD(n, 10) = 0 THEN 'INACTIVE'
      WHEN MOD(n, 6) = 0 THEN 'RENTED'
      ELSE 'AVAILABLE'
    END,
    CASE
      WHEN MOD(n, 10) = 0 OR MOD(n, 6) = 0 THEN b'0'
      ELSE b'1'
    END,
    DATE_ADD(CURDATE(), INTERVAL MOD(n, 25) - 10 DAY),
    ELT((MOD(n, 3) + 1), 'ANY', 'MALE', 'FEMALE'),
    (MOD(n, 4) + 1),
    DATE_SUB(NOW(), INTERVAL MOD(n * 3, 180) DAY),
    (SELECT id FROM tmp_creators WHERE seq = (MOD(n - 1, @creator_count) + 1))
FROM seq;

-- Temporary room list
DROP TEMPORARY TABLE IF EXISTS tmp_rooms;
CREATE TEMPORARY TABLE tmp_rooms AS
SELECT
    r.id,
    ROW_NUMBER() OVER (ORDER BY r.id) AS seq
FROM room r
WHERE r.title LIKE 'Load Test Room %';

SET @room_count = (SELECT COUNT(*) FROM tmp_rooms);

-- 5) Insert room images (2 to 4 images per room)
INSERT INTO room_image_urls (room_id, image_urls)
WITH RECURSIVE img_seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM img_seq WHERE n < 4
)
SELECT
    r.id,
        CONCAT('/uploads/rooms/loadtest/room_', r.id, '_', img_seq.n, '.jpg')
FROM room r
JOIN img_seq
  ON img_seq.n <= CASE
      WHEN MOD(r.id, 3) = 0 THEN 4
      WHEN MOD(r.id, 2) = 0 THEN 3
      ELSE 2
  END
WHERE r.title LIKE 'Load Test Room %';

-- Temporary reviewer list (load users + existing users for mixed interactions)
DROP TEMPORARY TABLE IF EXISTS tmp_reviewers;
CREATE TEMPORARY TABLE tmp_reviewers AS
SELECT
    u.id,
    ROW_NUMBER() OVER (ORDER BY u.id) AS seq
FROM `user` u
WHERE u.email LIKE 'loadtest_user%@roombridge.test'
   OR u.id <= 2;

SET @reviewer_count = (SELECT COUNT(*) FROM tmp_reviewers);

-- 6) Insert 150 reviews with varied sentiment and ratings
INSERT INTO room_review (room_id, user_id, rating, review_comment, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 150
)
SELECT
    (SELECT id FROM tmp_rooms WHERE seq = (MOD(n - 1, @room_count) + 1)),
    (SELECT id FROM tmp_reviewers WHERE seq = (MOD(n + 2, @reviewer_count) + 1)),
    CASE
      WHEN MOD(n, 10) = 0 THEN 1
      WHEN MOD(n, 7) = 0 THEN 2
      WHEN MOD(n, 3) = 0 THEN 3
      WHEN MOD(n, 2) = 0 THEN 4
      ELSE 5
    END,
    CASE
      WHEN MOD(n, 10) = 0 THEN 'Major mismatch with listing details; noisy surroundings.'
      WHEN MOD(n, 7) = 0 THEN 'Okay stay but maintenance response was slow.'
      WHEN MOD(n, 5) = 0 THEN 'Decent value for price, could improve cleanliness.'
      WHEN MOD(n, 3) = 0 THEN 'Good room and helpful owner, internet speed is average.'
      ELSE 'Excellent experience: accurate listing, safe area, smooth communication.'
    END,
    DATE_SUB(NOW(), INTERVAL MOD(n * 7, 240) HOUR)
FROM seq;

-- 7) Insert 52 documents with mixed verification outcomes
INSERT INTO user_documents (user_id, document_name, document_path, uploaded_at, verification_status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 52
)
SELECT
    (SELECT id FROM tmp_reviewers WHERE seq = (MOD(n - 1, @reviewer_count) + 1)),
    CONCAT('document_', LPAD(n, 3, '0'), '.pdf'),
    CONCAT('uploads/documents/loadtest/document_', LPAD(n, 3, '0'), '.pdf'),
    DATE_SUB(NOW(), INTERVAL MOD(n * 5, 360) HOUR),
    ELT((MOD(n, 3) + 1), 'PENDING', 'APPROVED', 'REJECTED')
FROM seq;

-- 8) Insert 220 chat messages across users
DROP TEMPORARY TABLE IF EXISTS tmp_chat_users;
CREATE TEMPORARY TABLE tmp_chat_users AS
SELECT
    u.id,
    ROW_NUMBER() OVER (ORDER BY u.id) AS seq
FROM `user` u
WHERE u.email LIKE 'loadtest_user%@roombridge.test'
   OR u.id <= 2;

SET @chat_user_count = (SELECT COUNT(*) FROM tmp_chat_users);

DROP TEMPORARY TABLE IF EXISTS tmp_chat_senders;
CREATE TEMPORARY TABLE tmp_chat_senders AS
SELECT id, seq FROM tmp_chat_users;

DROP TEMPORARY TABLE IF EXISTS tmp_chat_receivers;
CREATE TEMPORARY TABLE tmp_chat_receivers AS
SELECT id, seq FROM tmp_chat_users;

INSERT INTO chat_message (content, timestamp, receiver_id, sender_id)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 220
)
SELECT
    CASE
      WHEN MOD(n, 9) = 0 THEN 'Is this room still available for immediate move-in?'
      WHEN MOD(n, 8) = 0 THEN 'Can you share utility costs and house rules?'
      WHEN MOD(n, 7) = 0 THEN 'I can visit tomorrow evening. Does 6 PM work?'
      WHEN MOD(n, 6) = 0 THEN 'Thanks, I have uploaded my documents for verification.'
      WHEN MOD(n, 5) = 0 THEN 'Could you reduce the deposit for a longer stay?'
      ELSE CONCAT('Load-test message #', n, ' regarding room details.')
    END,
    DATE_SUB(NOW(), INTERVAL MOD(n * 11, 500) MINUTE),
        r.id,
        s.id
FROM seq
JOIN tmp_chat_senders s
    ON s.seq = (MOD(seq.n - 1, @chat_user_count) + 1)
JOIN tmp_chat_receivers r
    ON r.seq = (MOD(seq.n + 5, @chat_user_count) + 1);

-- 9) Insert refresh sessions
INSERT INTO session (refresh_token, last_used_at, user_id)
SELECT
    CONCAT('rt_', REPLACE(UUID(), '-', ''), '_', u.id),
    DATE_SUB(NOW(), INTERVAL MOD(u.id * 13, 96) HOUR),
    u.id
FROM `user` u
WHERE u.email LIKE 'loadtest_user%@roombridge.test'
  AND MOD(u.id, 2) = 0;

COMMIT;

-- Summary
SELECT 'users' AS metric, COUNT(*) AS total
FROM `user`
WHERE email LIKE 'loadtest_user%@roombridge.test'
UNION ALL
SELECT 'profiles', COUNT(*) FROM profiles p JOIN `user` u ON p.user_id = u.id WHERE u.email LIKE 'loadtest_user%@roombridge.test'
UNION ALL
SELECT 'rooms', COUNT(*) FROM room WHERE title LIKE 'Load Test Room %'
UNION ALL
SELECT 'room_images', COUNT(*) FROM room_image_urls ri JOIN room r ON ri.room_id = r.id WHERE r.title LIKE 'Load Test Room %'
UNION ALL
SELECT 'reviews', COUNT(*) FROM room_review rr JOIN room r ON rr.room_id = r.id WHERE r.title LIKE 'Load Test Room %'
UNION ALL
SELECT 'documents', COUNT(*) FROM user_documents ud JOIN `user` u ON ud.user_id = u.id WHERE u.email LIKE 'loadtest_user%@roombridge.test'
UNION ALL
SELECT 'chat_messages', COUNT(*) FROM chat_message cm
WHERE cm.sender_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test')
   OR cm.receiver_id IN (SELECT id FROM `user` WHERE email LIKE 'loadtest_user%@roombridge.test')
UNION ALL
SELECT 'sessions', COUNT(*) FROM session s JOIN `user` u ON s.user_id = u.id WHERE u.email LIKE 'loadtest_user%@roombridge.test';
