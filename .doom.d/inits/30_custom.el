;;; -*- lexical-binding: t; -*-

(doom-load-envvars-file (expand-file-name "myenv" doom-user-dir) 'noerror)
(load! (concat "custom-" (file-name-nondirectory load-file-name)) doom-user-dir 'noerror)
