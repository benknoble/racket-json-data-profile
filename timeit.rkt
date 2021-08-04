#lang racket

(require syntax/parse/define
         json
         racket/fasl
         compiler/cm)

(define-syntax-parse-rule (timeit type:expr file:expr)
  (begin
    (displayln type)
    (time (dynamic-require file 'json)
          (void))))

;; make sure jsond is installed
(with-handlers ([exn:fail? (thunk* (system "raco pkg install ./jsond"))])
  (dynamic-require 'jsond #f))

;; generate files
(define the-json
  (with-input-from-file "data.json"
    read-json))

(display-lines-to-file
  (list
    "#lang racket/base"
    "(provide json)"
    "(require json)"
    "(define json (with-input-from-file \"data.json\" read-json))")
  "with-read-json.rkt"
  #:exists 'truncate)

(display-lines-to-file
  (list
    "#lang racket/base"
    "(provide json)"
    (format "(define json ~v)" the-json))
  "with-hash.rkt"
  #:exists 'truncate)

(display-lines-to-file
  (list
    "#lang racket/base"
    "(provide json)"
    "(require racket/fasl)"
    (format "(define json (fasl->s-exp ~v))" (s-exp->fasl the-json)))
  "with-fasl.rkt"
  #:exists 'truncate)

(display-lines-to-file
  (list
    "#lang jsond"
    (jsexpr->string the-json))
  "with-lang.rkt"
  #:exists 'truncate)

;; compile for appropriate speed
(for-each managed-compile-zo
          '("with-read-json.rkt"
            "with-hash.rkt"
            "with-fasl.rkt"
            "with-lang.rkt"))

;; time
(timeit "read-json from file" "with-read-json.rkt")
(timeit "direct value" "with-hash.rkt")
(timeit "fasl->sexp (embedded)" "with-fasl.rkt")
(timeit "custom #lang" "with-lang.rkt")
