;;; d2.el --- D2 diagram support -*- lexical-binding: t -*-

;; Copyright (C) 2024 liuyinz

;; Author: liuyinz <liuyinz95@gmail.com>
;; Maintainer: liuyinz <liuyinz95@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: d2 languages tree-sitter
;; Homepage: https://github.com/liuyinz/d2.el

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; See https://d2lang.com/
;; See https://codeberg.org/p8i/tree-sitter-d2.git

;;; Code:

(require 'treesit)
(require 'rx)

(declare-function treesit-parser-create "treesit.c")
;; (declare-function treesit-induce-sparse-tree "treesit.c")
;; (declare-function treesit-node-start "treesit.c")
;; (declare-function treesit-node-type "treesit.c")
;; (declare-function treesit-node-child-by-field-name "treesit.c")

(defgroup d2 nil
  "docstring"
  :group 'languages
  :version "29.1")

(defconst d2--treesit-config-keywords
  '("vars" "d2-config" "layout-engine" "theme-id")
  "D2 keyword configs.")

(defvar d2--treesit-syntax-table
  (let ((table (make-syntax-table)))
    ;; (modify-syntax-entry ?# "<" table)
    ;; (modify-syntax-entry ?\n ">" table)
    table)
  "Syntax table for D2 files.")

(defvar d2--treesit-font-lock-settings
  (treesit-font-lock-rules
   :default-language 'd2
   :feature 'comment
   '([(line_comment)
      (block_comment)]
     @font-lock-comment-face)

   :feature 'builtin
   '((boolean) @font-lock-builtin-face)

   :feature 'keyword
   :override t
   `([(keyword_style)
      (keyword_classes)
      (keyword_class)
      (keyword_underscore)]
     @font-lock-keyword-face

     (source_file
      (container
       (container_key) @font-lock-keyword-face
       (:equal @font-lock-keyword-face "vars"))))

   :feature 'key
   '([(shape_key) (container_key)] @font-lock-function-name-face
     (attr_key) @font-lock-property-name-face)

   :feature 'operator
   '((arrow) @font-lock-operator-face)

   :feature 'number
   '([(float) (integer)] @font-lock-number-face)

   :feature 'escape
   '((escape_sequence) @font-lock-escape-face)

   :feature 'constant
   '((class_name) @font-lock-constant-face)

   :feature 'delimiter
   '([(dot) (colon) ";" "|"] @font-lock-delimiter-face)

   :feature 'bracket
   '(["[" "]" "{" "}"] @font-lock-bracket-face)

   :feature 'string
   '((label) @font-lock-type-face
     (language) @font-lock-preprocessor-face
     [(string) (attr_value) (label)] @font-lock-string-face
     (container_key
      (string
       (string_fragment) @font-lock-string-face))
     (shape_key
      (string
       (string_fragment) @font-lock-string-face)))

   :feature 'error
   '([(reserved) (ERROR)] @font-lock-warning-face))
  "Tree-sitter font-lock settings.")

(defvar d2--treesit-indent-rules
  `((d2
     ((node-is "}") parent-bol 0)
     ((parent-is "block") parent-bol 2)))
  "Tree-sitter indent rules.")

;;;###autoload
(define-derived-mode d2-ts-mode prog-mode "D2"
  "Major mode for editing D2 files, using tree-sitter library.

\\{d2-ts-mode-map}"
  :syntax-table d2--treesit-syntax-table

  (unless (treesit-ready-p 'd2)
    (error "Tree-sitter for D2 isn't available"))

  (setq-local treesit-primary-parser (treesit-parser-create 'd2))

  ;; Comments.
  (setq-local comment-start "# ")
  (setq-local comment-start-skip "#+\\s-*")
  (setq-local comment-end "")

  ;; Indent.
  (setq-local treesit-simple-indent-rules d2--treesit-indent-rules)

  ;; Font-lock.

  (setq-local treesit-font-lock-settings d2--treesit-font-lock-settings)
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (builtin keyword string)
                (key constant number operator delimiter)
                (escape bracket error)))

  (treesit-major-mode-setup))

(if (treesit-ready-p 'd2)
    (add-to-list 'auto-mode-alist
                 '("\\.d2\\'" . d2-ts-mode)))

(provide 'd2)

;;; d2.el ends here
