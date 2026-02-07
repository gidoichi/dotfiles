;;; -*- lexical-binding: t; -*-

(doom-load-envvars-file (expand-file-name "myenv" doom-user-dir) 'noerror)
(load! "custom-config.el" doom-user-dir 'noerror)
