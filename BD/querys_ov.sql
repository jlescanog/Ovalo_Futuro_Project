
ALTER TABLE usuarios ADD COLUMN email_temp VARCHAR(100) NOT NULL;

UPDATE usuarios SET email_temp = email;

ALTER TABLE usuarios DROP COLUMN email;

ALTER TABLE usuarios RENAME COLUMN email_temp TO email;

SELECT
	rol,
	COUNT(nombres)
FROM usuarios
GROUP BY rol
;
