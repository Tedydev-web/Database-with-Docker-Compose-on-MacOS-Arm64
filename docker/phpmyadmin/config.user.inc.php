<?php
/* Cấu hình tùy chỉnh cho PHPMyAdmin */

// Tăng giới hạn bộ nhớ và thời gian thực thi
$cfg['MemoryLimit'] = '256M';
$cfg['ExecTimeLimit'] = 300;
$cfg['MaxRows'] = 100;
$cfg['SendErrorReports'] = 'never';

// Cấu hình bảo mật
$cfg['AllowArbitraryServer'] = false;
$cfg['LoginCookieValidity'] = 1800;
$cfg['ForceSSL'] = true;
$cfg['CheckConfigurationPermissions'] = false;

// Cấu hình hiển thị
$cfg['MaxNavigationItems'] = 100;
$cfg['NavigationTreeEnableGrouping'] = true;
$cfg['ShowDatabasesNavigationAsTree'] = true;
$cfg['NavigationTreeDisplayItemFilterMinimum'] = 30;
$cfg['NavigationDisplayServers'] = false;
$cfg['NavigationTreeEnableExpansion'] = true;

// Cấu hình xuất/nhập
$cfg['Export']['compression'] = 'gzip';
$cfg['Import']['charset'] = 'utf-8';
$cfg['QueryHistoryMax'] = 100;

// Cấu hình giao diện
$cfg['DefaultLang'] = 'vi';
$cfg['DefaultConnectionCollation'] = 'utf8mb4_unicode_ci'; 