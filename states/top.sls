base:
  # base states for all servers
  '*':
    - basic

  'forum.*':
    # mailserver to deliver emails
    - mail.simple
    # install discourse on the forum server
    - discourse

  'site.*':
    # mailserver to deliver emails
    - mail.simple
    # install website on the site server
    - yiiframework

  'bot.*':
    # mailserver to deliver emails
    - mail.simple
    # install github bot on the bot server
    - yiibot
    # install subsplit service for yii2-framework repo
    - yiibot.subsplit

