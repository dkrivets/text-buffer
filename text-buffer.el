;;; text-buffer.el --- Creating named buffer -*- coding: utf-8; lexical-binding: t -*-

;; Author: DKrivets
;; Created: 29 Dec 2018
;; Version: 0.0.1
;; Keywords: text-buffer, languages, programming
;; Homepage: https://github.com/dkrivets/text-buffer
;; Package-Require: ((emacs "24")(dash "2.14.1"))

;;; Commentary:
;;  Simple way to create new buffer does not think about it name.
;;  Have 2 parameters:
;;  1. TEXT-PREFIX-NAME: Prefix of buffer name.
;;  2. TEXT-SPLITTER: Splitter of buffer name.
;;  By default, it looks like "TEMP-".
;;  When buffer will be created it name will be "TEMP-1".
;;  Package has an one key-binding to create a buffer: C-x n

;;; Code:
(require 'dash)

(defgroup text-buffer nil "Simple way to create new buffer does not think about it name." :group 'applications)


(defcustom text-buffer-prefix-name "TEMP"
  "Prefix of buffer name."
  :type 'string
  :group 'text-buffer)


(defcustom text-buffer-splitter-name "-"
  "Splitter of buffer name."
  :type 'string
  :group 'text-buffer)


(defvar text-buffer-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-x n") 'text-buffer-create-buffer))
  "Keymap for text-buffer.")


(defun text-buffer--get-template-name ()
  "Get template for buffer name."
  (concat text-buffer-prefix-name text-buffer-splitter-name))


(defun text-buffer--base-create-buffer (name)
  "Create buffer with NAME and switch to it."
  (switch-to-buffer (get-buffer-create name)))


(defun text-buffer--get-buffer-list ()
  "Get list of buffers with template name."
  (delq nil
	(mapcar
	 (lambda (i)
	   (let ((buf          (buffer-name i))
		 (template     (text-buffer--get-template-name))
		 (template-len (length (text-buffer--get-template-name))))
	     (if (< template-len (length buf))
		 (if (string= template (substring buf 0 template-len))
		     i
		   nil))))
	   (append (buffer-list) ()))))


(defun text-buffer--get-max-buf-num (buf-list)
  "Get max exists bufer num with template name in BUF-LIST."
  ;; Check size of list
  ;; Return 0 or work with buffer list
  (if (= 0 (length buf-list))
      0
    (-max
     (-map
      (lambda (i)
	;; Get exists postfix of buffer
	(let ((num (substring (buffer-name i) (length (text-buffer--get-template-name)))))
	  ;; Convert postfix to number
	  (string-to-number num)))
      buf-list))))


(defun text-buffer--make-default-name ()
  "Make default name.
Uses format %s%d where %s - is a concatination of values
of text-prefix-name text-splitter and %d count + 1 of same buffers."
  (format "%s%d"
	  ;; Get template name
	  (text-buffer--get-template-name)
	  ;; Count of same buffers with apply 1
	  (1+ (text-buffer--get-max-buf-num (text-buffer--get-buffer-list)))))


;;;###autoload
(defun text-buffer-create-buffer ()
  "Create buffer with NAME interactivly.
Main function which creates buffer with name you can input or default
which count from exist buffer."
  (interactive)
  ;; Create user helper with buffer-name
  (let ((desc (format "New buffer name:[%s] " (text-buffer--make-default-name))))
    ;; Read user data from mini-buffer
    (let ((name (read-string desc)))
      ;; Check which data we will be use: users or default
      (let ((buf-name
	     (if (> 0 (length name))
		 name
	       (text-buffer--make-default-name))))
	;; Run process
	(text-buffer--base-create-buffer buf-name)))))


;;;###autoload
(define-minor-mode text-buffer
  "TEXT-BUFFER mode."
  :group 'text-buffer
  :require 'text-buffer
  :lighter " TB"
  :keymap text-buffer-map
  :global t
  (make-local-variable 'text-buffer-map)
  )

(provide 'text-buffer)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; text-buffer.el ends here
