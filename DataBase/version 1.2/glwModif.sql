CREATE TABLE `glwModif` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `idEvents` int(11) unsigned NOT NULL,
  `data` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `timeCreation` timestamp NOT NULL DEFAULT current_timestamp(),
  `wind` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=705 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci