<?php

return [

	'webUrl' => 'https://bot.yiiframework.com/',

	'repositories' => [
		'yiisoft/yii2',

		'yiisoft/yii2-app',
		'yiisoft/yii2-app-basic',
		'yiisoft/yii2-app-advanced',

		'yiisoft/yii2-apidoc',
		'yiisoft/yii2-authclient',
		'yiisoft/yii2-bootstrap',
		'yiisoft/yii2-captcha',
		'yiisoft/yii2-codeception',
		'yiisoft/yii2-composer',
		'yiisoft/yii2-debug',
		'yiisoft/yii2-elasticsearch',
		'yiisoft/yii2-faker',
		'yiisoft/yii2-gii',
		'yiisoft/yii2-httpclient',
		'yiisoft/yii2-imagine',
		'yiisoft/yii2-jquery',
		'yiisoft/yii2-jui',
		'yiisoft/yii2-mongodb',
		'yiisoft/yii2-queue',
		'yiisoft/yii2-redis',
		'yiisoft/yii2-rest',
		'yiisoft/yii2-smarty',
		'yiisoft/yii2-sphinx',
		'yiisoft/yii2-swiftmailer',
		'yiisoft/yii2-shell',
		'yiisoft/yii2-twig',
	//	'cebe/testrepo',
	],
	'github_token' => '{{ pillar.yiibot.github_token }}', // yii-bot
	'github_username' => '{{ pillar.yiibot.github_username }}',

	'hook_secret' => '{{ pillar.yiibot.github_hook_secret }}',
];


