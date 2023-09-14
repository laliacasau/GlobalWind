CREATE TABLE `glwWorldBase` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` tinyint(3) unsigned NOT NULL,
  `baseWind` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci