

Setup the bot after applying the state:

- add the SSH public key of yii-bot to the yiisoft/yii2-framework repo as deploy-key with push access
- add webhook to `yiisoft/yii2` to ping `https://bot.yiiframework.com/subsplit-hook.php?token=...` on push (token is the one defined in `yiibot.github_subsplit_secret` saltstack pillar)



