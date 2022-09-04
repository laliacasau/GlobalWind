CREATE TABLE `glwEventsMap` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idEvents` int(10) unsigned NOT NULL,
  `idVars` int(10) unsigned NOT NULL,
  `mapSimX` int(10) unsigned NOT NULL,
  `mapSimY` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `simValues` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `overlap` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100828 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci