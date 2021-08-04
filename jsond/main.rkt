#lang racket/base

(module+ reader
  (provide read-syntax)

  (require json
           syntax/strip-context)

  (define (read-syntax src in)
    (define jsexpr (read-json in))
    (strip-context
      #`(module jsond-module racket/base
          (provide json)
          (define json #,jsexpr)))))
