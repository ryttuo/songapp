<?php

var_dump(in_array('mod_rewrite', apache_get_modules()));

var_dump(strpos(shell_exec('/usr/local/apache/bin/apachectl -l'), 'mod_rewrite') !== false);

phpinfo();
