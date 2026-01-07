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
		'cebe/testrepo',

                // Yii 3.0 repositories
                'yiisoft/yii-core',
                'yiisoft/yii-console',
                'yiisoft/yii-web',
                'yiisoft/yii-rest',

                'yiisoft/yii-project-template',
                'yiisoft/yii-base-web',
                'yiisoft/yii-base-api',
                //'yiisoft/yii-base-cli',

                'yiisoft/yii-bootstrap3',
                'yiisoft/yii-bootstrap4',
                'yiisoft/yii-masked-input',
                'yiisoft/yii-debug',
                'yiisoft/yii-gii',
                'yiisoft/yii-jquery',
                'yiisoft/yii-captcha',
                'yiisoft/yii-swiftmailer',
                'yiisoft/yii-twig',
                'yiisoft/yii-http-client',
                'yiisoft/yii-auth-client',

                'yiisoft/log',
                'yiisoft/di',
                'yiisoft/cache',
                'yiisoft/db',
                'yiisoft/active-record',
                'yiisoft/rbac',

                'yiisoft/db-mysql',
                'yiisoft/db-mssql',
                'yiisoft/db-pgsql',
                'yiisoft/db-sqlite',
                'yiisoft/db-oracle',

                'yiisoft/db-sphinx',
                'yiisoft/db-redis',
                'yiisoft/db-mongodb',
                'yiisoft/db-elasticsearch',
	],
	'github_token' => '{{ pillar.yiibot.github_token }}', // yii-bot
	'github_username' => '{{ pillar.yiibot.github_username }}',

	'hook_secret' => '{{ pillar.yiibot.github_hook_secret }}',
];


