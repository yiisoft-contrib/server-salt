<?php

// github post receive hook for yii2 repository 
// it creates a file to so that yii2sync knows a sync is pending

if (isset($_GET['token']) && $_GET['token'] === '{{ pillar.yiibot.github_subsplit_secret }}') {
  file_put_contents('/tmp/github-yii2.lock', 'ok');
}
