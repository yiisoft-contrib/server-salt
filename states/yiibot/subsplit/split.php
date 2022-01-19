<?php

$lockFile = __DIR__ . '/sync.lock';
if (!is_file($lockFile)) {
	file_put_contents($lockFile, '0');
}
$fp = fopen($lockFile, 'r+');
if (!flock($fp, LOCK_EX | LOCK_NB)) {
	die("Unable to obtain lock for sync.lock.");
}

if (isset($argv[1]) && strpos($argv[1], '--tag=') === 0) {
	$tag = substr($argv[1], 6);
	echo "Synchronizing tag '$tag'? [y/n] ";
	if (strncasecmp(fgets(STDIN), 'y', 1) !== 0) {
		echo "no change is made.\n";
		exit();
	}
} else {
	$signal = '/tmp/github-yii2.lock';
	if (!@unlink($signal)) {
		return;
	}
}

require(__DIR__ . '/Subsplit.php');

$branches = array('master', '2.1');
$subsplits = array(
	'framework' => 'yiisoft/yii2-framework',
/*
	'extensions/apidoc' => 'yiisoft/yii2-apidoc',
	'extensions/authclient' => 'yiisoft/yii2-authclient',
	'extensions/bootstrap' => 'yiisoft/yii2-bootstrap',
	'extensions/codeception' => 'yiisoft/yii2-codeception',
	'extensions/composer' => 'yiisoft/yii2-composer',
	'extensions/debug' => 'yiisoft/yii2-debug',
	'extensions/elasticsearch' => 'yiisoft/yii2-elasticsearch',
	'extensions/faker' => 'yiisoft/yii2-faker',
	'extensions/gii' => 'yiisoft/yii2-gii',
	'extensions/imagine' => 'yiisoft/yii2-imagine',
	'extensions/jui' => 'yiisoft/yii2-jui',
	'extensions/mongodb' => 'yiisoft/yii2-mongodb',
	'extensions/redis' => 'yiisoft/yii2-redis',
	'extensions/smarty' => 'yiisoft/yii2-smarty',
	'extensions/sphinx' => 'yiisoft/yii2-sphinx',
	'extensions/swiftmailer' => 'yiisoft/yii2-swiftmailer',
	'extensions/twig' => 'yiisoft/yii2-twig',
	'apps/basic' => 'yiisoft/yii2-app-basic',
	'apps/advanced' => 'yiisoft/yii2-app-advanced',
	'apps/benchmark' => 'yiisoft/yii2-app-benchmark',
*/
);

$root = __DIR__;
$repo = 'yiisoft/yii2';
$githubToken = '{{ pillar.yiibot.github_subsplit_token }}';
$git = 'git';

echo date('Y-m-d H:i:s') . " running subsplit script...\n";
try {
	$subsplit = new Subsplit(
		$repo,
		$root,
		$branches,
		$subsplits,
		$githubToken,
		$git
	);
	$subsplit->update(isset($tag) ? $tag : null);
} catch (Exception $e) {
	echo "Error: " . $e->getMessage() . "\n";
}

echo date('Y-m-d H:i:s') . " finished subsplit script.\n";

flock($fp, LOCK_UN);
fclose($fp);

