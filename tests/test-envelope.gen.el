;; This file is generated auto generated. Do not edit directly.

(require 'combobulate)

(require 'combobulate-test-prelude)

(ert-deftest combobulate-test-python-prompt-once-blank-1 ()
  "Test `prompt-once' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "prompt-once")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (let ((combobulate-envelope-registers '((some-prompt . "foo"))))
      (combobulate-envelope-expand-instructions
       '("a = " (p some-prompt "Pick a value"))))
    debug-show
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/prompt-once/blank.py[prompt-once@1~after].py")))


(ert-deftest
    combobulate-test-python-insert-missing-register-with-default-blank-1
    ()
  "Test `insert-missing-register-with-default' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags
  '(python python-ts-mode "insert-missing-register-with-default")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (let ((combobulate-envelope-registers))
      (combobulate-envelope-expand-instructions
       '("if True:" n> (r some-register "foo"))))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/insert-missing-register-with-default/blank.py[insert-missing-register-with-default@1~after].py")))


(ert-deftest
    combobulate-test-python-insert-region-register-2-then-indent-blank-1
    ()
  "Test `insert-region-register-2-then-indent' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags
  '(python python-ts-mode "insert-region-register-2-then-indent")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (let
        ((combobulate-envelope-registers
          '((some-register . "my_register = 1"))))
      (combobulate-envelope-expand-instructions
       '("if True:" n> (r some-register))))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/insert-region-register-2-then-indent/blank.py[insert-region-register-2-then-indent@1~after].py")))


(ert-deftest
    combobulate-test-python-insert-region-register-then-indent-blank-1
    ()
  "Test `insert-region-register-then-indent' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "insert-region-register-then-indent")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (let ((combobulate-envelope-registers '((region . "random = 1"))))
      (combobulate-envelope-expand-instructions '("if True:" n> r)))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/insert-region-register-then-indent/blank.py[insert-region-register-then-indent@1~after].py")))


(ert-deftest combobulate-test-python-insert-region-register-blank-1
    ()
  "Test `insert-region-register' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "insert-region-register")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions '(r))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/insert-region-register/blank.py[insert-region-register@1~after].py")))


(ert-deftest combobulate-test-python-save-column-nested-blank-1 ()
  "Test `save-column-nested' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "save-column-nested")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions
     '("def Foo():" n>
       (save-column "try:" n>
                    (save-column "with some_stuff() as foo:" n> "pass"
                                 n>))
       "except:" n> "pass"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/save-column-nested/blank.py[save-column-nested@1~after].py")))


(ert-deftest combobulate-test-python-save-column-blank-1 ()
  "Test `save-column' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "save-column")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions
     '("def Foo():" n> (save-column "try:" n> "do_something()" n>)
       "except:" n> "pass"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/save-column/blank.py[save-column@1~after].py")))


(ert-deftest
    combobulate-test-python-newline-and-indent-inside-block-both-blank-1
    ()
  "Test `newline-and-indent-inside-block-both' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags
  '(python python-ts-mode "newline-and-indent-inside-block-both")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions
     '("if 1:" n> "b = 1" n> "c = 1" n> "while True:" n> "d = 3"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/newline-and-indent-inside-block-both/blank.py[newline-and-indent-inside-block-both@1~after].py")))


(ert-deftest
    combobulate-test-python-newline-and-indent-inside-block-then-outside-blank-1
    ()
  "Test `newline-and-indent-inside-block-then-outside' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags
  '(python python-ts-mode
           "newline-and-indent-inside-block-then-outside")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions
     '("if 1:" n> "b = 1" n "c = 1"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/newline-and-indent-inside-block-then-outside/blank.py[newline-and-indent-inside-block-then-outside@1~after].py")))


(ert-deftest combobulate-test-python-newline-and-indent-simple-blank-1
    ()
  "Test `newline-and-indent-simple' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "newline-and-indent-simple")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions '("a = 1" n> "b = 1"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/newline-and-indent-simple/blank.py[newline-and-indent-simple@1~after].py")))


(ert-deftest combobulate-test-python-newline-blank-1 ()
  "Test `newline' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "newline")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions '("a = 1" n "b = 1"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/newline/blank.py[newline@1~after].py")))


(ert-deftest combobulate-test-python-string-multiple-blank-1 ()
  "Test `string-multiple' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "string-multiple")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions '("a" "b" "c"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/string-multiple/blank.py[string-multiple@1~after].py")))


(ert-deftest combobulate-test-python-string-basic-blank-1 ()
  "Test `string-basic' on `./fixtures/envelope/blank.py' at point marker number `1'."
  :tags '(python python-ts-mode "string-basic")
  (combobulate-test
      (:language python :mode python-ts-mode :fixture
                 "./fixtures/envelope/blank.py")
    (goto-marker 1) delete-markers
    (combobulate-envelope-expand-instructions '("test string"))
    (combobulate-compare-action-with-fixture-delta
     "./fixture-deltas/envelope/string-basic/blank.py[string-basic@1~after].py")))



