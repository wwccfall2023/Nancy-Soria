-- Create your tables, views, functions, and procedures here!
CREATE SCHEMA destruction;
USE destruction;

CREATE TABLE players (
  player_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  email VARCHAR(50) NOT NULL
);

CREATE TABLE characters (
  character_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  player_id INT UNSIGNED,
  name VARCHAR(50) NOT NULL,
  level INT,
  FOREIGN KEY (player_id) REFERENCES players(player_id)
);

CREATE TABLE winners (
  character_id INT UNSIGNED PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  FOREIGN KEY (character_id) REFERENCES characters(character_id)
);

CREATE TABLE character_stats (
  character_id INT UNSIGNED PRIMARY KEY,
  health INT,
  armor INT,
  FOREIGN KEY (character_id) REFERENCES characters(character_id)
);

CREATE TABLE teams (
  team_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE team_members (
  team_member_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  team_id INT UNSIGNED,
  character_id INT UNSIGNED,
  FOREIGN KEY (team_id) REFERENCES teams(team_id),
  FOREIGN KEY (character_id) REFERENCES characters(character_id)
);

CREATE TABLE items (
  item_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  armor INT,
  damage INT
);

CREATE TABLE inventory (
  inventory_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED,
  item_id INT UNSIGNED,
  FOREIGN KEY (character_id) REFERENCES characters(character_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id) 
);

CREATE TABLE equipped (
  equipped_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED,
  item_id INT UNSIGNED,
  FOREIGN KEY (character_id) REFERENCES characters(character_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- Create Views
CREATE VIEW character_items AS 
SELECT 
  c.character_id,
  c.name AS character_name,
  i.name AS item_name,
  i.armor,
  i.damage
FROM characters c
INNER JOIN (
  SELECT character_id, item_id FROM inventory
  UNION
  SELECT character_id, item_id FROM equipped)
  AS ce ON c.character_id = ce.character_id
INNER JOIN items i ON ce.item_id = i.item_id;

CREATE VIEW team_items AS
SELECT 
  t.team_id,
  t.name AS team_name,
  i.name AS item_name,
  i.armor,
  i.damage
FROM teams t 
INNER JOIN team_members tm ON t.team_id = tm.team_id
INNER JOIN (
  SELECT character_id, item_id FROM inventory
  UNION 
  SELECT character_id, item_id FROM equipped)
  AS te ON tm.character_id = te.character_id
INNER JOIN items i ON te.item_id = i.item_id;

-- Create function
DELIMITER ;;

CREATE FUNCTION armor_total(p_character_id INT UNSIGNED) RETURNS INT
BEGIN
  DECLARE total_armor INT;

  SELECT COALESCE(SUM(armor), 0)
  INTO total_armor
  FROM character_stats
  WHERE character_id = p_character_id;

  SELECT COALESCE(SUM(items.armor), 0)
  INTO total_armor
  FROM equipped
  INNER JOIN items ON equipped.item_id = items.item_id
  WHERE equipped.character_id = p_character_id;

  RETURN total_armor;
END ;;

DELIMITER ;









