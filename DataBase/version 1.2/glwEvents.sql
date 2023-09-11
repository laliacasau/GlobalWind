CREATE TABLE `glwEvents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `directorKey` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `windsetterUrl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `eventNum` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `server` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `systemMode` tinyint(3) unsigned NOT NULL,
  `waterDepth` tinyint(3) unsigned NOT NULL,
  `extra1` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `extra2` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sailMode` tinyint(3) unsigned NOT NULL,
  `directorName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eventName` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eventKey` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `wndDir` smallint(3) unsigned NOT NULL,
  `wndSpeed` tinyint(3) unsigned NOT NULL,
  `wndGusts` tinyint(3) unsigned NOT NULL,
  `wndShifts` tinyint(3) unsigned NOT NULL,
  `wndPeriod` smallint(5) unsigned NOT NULL,
  `wavHeight` tinyint(3) unsigned NOT NULL,
  `wavLength` tinyint(3) unsigned NOT NULL,
  `wavSpeed` tinyint(3) unsigned NOT NULL,
  `wavHeightVariance` tinyint(3) unsigned NOT NULL,
  `wavLengthVariance` tinyint(3) unsigned NOT NULL,
  `wavEffects` tinyint(3) unsigned NOT NULL,
  `crtDir` tinyint(3) unsigned NOT NULL,
  `crtSpeed` tinyint(3) unsigned NOT NULL,
  `wavesType` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `updBoatPos` tinyint(3) unsigned NOT NULL,
  `createTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `updTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `activeEvent` tinyint(3) unsigned NOT NULL,
  `setterSimName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `counter` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci