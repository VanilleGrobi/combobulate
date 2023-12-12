;;; combobulate-generate-envelopes.el --- generate envelope tests  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Mickey Petersen

;; Author: Mickey Petersen <mickey@masteringemacs.org>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'combobulate)
(require 'combobulate-test-prelude)
(require 'combobulate-generate-tests)
(eval-when-compile
  (require 'cl-lib))


(defun make-envelope-tests ()
  (let ((tests))
    (dolist (instruction
             '(;; test string insertion
               ("string-basic"  ("test string"))
               ("string-multiple"  ("a" "b" "c"))
               ;; newline / indentation
               ("newline"  ("a = 1" n "b = 1"))
               ("newline-and-indent-simple"  ("a = 1" n> "b = 1"))
               ("newline-and-indent-inside-block-then-outside"  ("if 1:" n> "b = 1" n "c = 1"))
               ("newline-and-indent-inside-block-both"
                ("if 1:" n>
                 "b = 1" n>
                 "c = 1" n>
                 "while True:" n>
                 "d = 3"))
               ("save-column"  ("def Foo():" n>
                                (save-column "try:" n>
                                             "do_something()" n>)
                                "except:" n> "pass"))
               ("save-column-nested"  ("def Foo():" n>
                                       (save-column "try:" n>
                                                    (save-column "with some_stuff() as foo:" n>
                                                                 "pass" n>))
                                       "except:" n> "pass"))
               ;; register stuff
               ("insert-region-register"  (r))
               ("insert-region-register-then-indent"
                ("if True:" n> r) ((combobulate-envelope-registers '((region . "random = 1")))))
               ("insert-region-register-2-then-indent"
                ("if True:" n> (r some-register)) ((combobulate-envelope-registers '((some-register . "my_register = 1")))))
               ("insert-missing-register-with-default"
                ("if True:" n> (r some-register "foo")) ((combobulate-envelope-registers)))
               ;; prompting with preset prompt register values
               ("prompt-register-once" ("a = " (p some-prompt "Pick a value")) ((combobulate-envelope-registers '((some-prompt . "foo")))))
               ("prompt-register-reused" ("a = " (p some-prompt "Pick a value")
                                          n>
                                          "b = " (f some-prompt))
                ((combobulate-envelope-registers '((some-prompt . "this is a prompt value")))))
               ("prompt-manual-input-once" ("a = " (p some-prompt "Pick a value"))
                ((combobulate-envelope-prompt-actions '("simulated prompt value"))))
               ("prompt-manual-input-twice" ("a = " (p some-prompt "Pick a value") n>
                                             "b = " (p another-prompt "Pick a second value"))
                ((combobulate-envelope-prompt-actions '("simulated prompt value"
                                                        "second value"))))
               ("prompt-manual-keyboard-quit" ("a = " (p some-prompt "Pick a value") n>
                                               "b = " (p another-prompt "Pick a value"))
                ((combobulate-envelope-prompt-actions '("foo" keyboard-quit))))
               ("field-before-prompt" ("a = " (f some-prompt) n>
                                       "b = " (p some-prompt "Pick a value"))
                ((combobulate-envelope-prompt-actions '("blah"))))
      (push (pcase instruction
              (`(,name ,instruction  ,rest)
               (cons name `(let ,rest (combobulate-envelope-expand-instructions '(,@instruction)))))
              (`(,name . ,instruction)
               (cons name `(combobulate-envelope-expand-instructions ',@instruction))))
            tests))
    tests))

(defun combobulate-test-build-envelope-test (test-name language mode fixture-filename number action-fn
                                                       command-error action-fn-name)
  (let ((fixture-delta-fn (combobulate-test-get-fixture-delta-filename
                           fixture-filename action-fn-name number)))
    (combobulate-test-build-ert-stub
     test-name
     language
     mode
     fixture-filename
     action-fn-name
     number
     `((goto-marker ,number)
       delete-markers
       ,action-fn
       (combobulate-compare-action-with-fixture-delta ,fixture-delta-fn)))))


(provide 'combobulate-generate-envelopes)
;;; combobulate-generate-envelopes.el ends here
