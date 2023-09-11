CREATE TABLE `glwVariations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idEvents` int(10) unsigned NOT NULL,
  `type` tinyint(4) NOT NULL,
  `coord1X` int(10) unsigned NOT NULL,
  `coord1Y` int(10) unsigned NOT NULL,
  `coord2X` int(10) unsigned NOT NULL,
  `coord2Y` int(10) unsigned NOT NULL,
  `radius` smallint(5) unsigned NOT NULL,
  `margin` tinyint(3) unsigned NOT NULL,
  `overlap` tinyint(3) unsigned NOT NULL,
  `itemData` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `windData` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `wind2Boat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1342 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci