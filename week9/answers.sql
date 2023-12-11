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
  FOREIGN KEY user_id REFERENCES users(user_id),
  FOREIGN KEY post_id REFERENCES posts(post_id)
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
  INSERT INTO users (first_name, last_name, email) VALUES (p_first_name, p_last_name, p_email);
    INSERT INTO notifications (user_id, post_id) 
    SELECT user_id, NULL FROM users WHERE user_id != LAST_INSERT_ID();
END;

DELIMITER ;
