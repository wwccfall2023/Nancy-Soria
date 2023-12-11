-- Create your tables, views, functions and procedures here!
CREATE SCHEMA social;
USE social;

-- Create Users Table
CREATE TABLE users (
  user_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  created_on DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create Sessions Table
CREATE TABLE sessions (
  session_id INT PRIMARY KEY,
  user_id INT,
  created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create Friends Table 
CREATE TABLE friends (
  user_friend_id INT PRIMARY KEY,
  user_id INT,
  friend_id INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (friend_id) REFERENCES users(user_id)
);

-- Create Posts Table 
CREATE TABLE posts (
  post_id INT PRIMARY KEY,
  user_id INT,
  created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  content TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create Notifications Table 
CREATE TABLE notifications (
  notification_id INT PRIMARY KEY,
  user_id INT,
  post_id INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

-- Create View 
CREATE VIEW notification_posts AS
SELECT 
  n.user_id,
  u.first_name,
  u.last_name,
  p.post_id,
  p.content
FROM 
  notifications n 
INNER JOIN users u ON n.user_id = u.user_id
LEFT JOIN posts p ON n.post_id = p.post_id;

-- Create Stored Program 
-- Add a User 
DELIMITER ;;
CREATE PROCEDURE add_user (
  IN p_first_name VARCHAR(50),
  IN p_last_name VARCHAR(50),
  IN p_email VARCHAR(100)
)
BEGIN
  START TRANSACTION;
  INSERT INTO users (first_name, last_name, email) VALUES (p_first_name, p_last_name, p_email);
  SET @new_user_id := LAST_INSERT_ID();
    
  INSERT INTO notifications (user_id, post_id) 
  SELECT user_id, NULL 
  FROM users
  WHERE user_id != @new_user_id;
  INSERT INTO notifications (user_id, post_id) 
  VALUES (@new_user_id, NULL);
    
  INSERT INTO posts (user_id, content) 
  VALUES (@new_user_id, CONCAT(p_first_name, ' ', p_last_name, ' just joined!'));
  COMMIT;
END;
;;
DELIMITER ;


-- Remove old sessions 
DELIMITER ;;
CREATE PROCEDURE remove_old_sessions()
BEGIN 
   DELETE FROM sessions WHERE updated_on < NOW() - INTERVAL 2 HOUR;
END;
;;
DELIMITER ;

-- Event to trigger procedure 
SET GLOBAL event_scheduler = ON;

-- Create an event to run the remove_old_sessions stored procedure every 10 seconds
CREATE EVENT remove_old_sessions_event
ON SCHEDULE EVERY 10 SECOND
DO
BEGIN
    CALL remove_old_sessions();
END;
;;
DELIMITER ;

-- Add posts
CREATE PROCEDURE add_post(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    INSERT INTO posts (user_id, content) VALUES (p_user_id, p_content);
    
    -- Create notifications for all friends of the user
    INSERT INTO notifications (user_id, post_id)
    SELECT f.friend_id, LAST_INSERT_ID()
    FROM friends f
    WHERE f.user_id = p_user_id;
END;
;;
DELIMITER ;
